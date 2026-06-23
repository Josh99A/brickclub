import {createHash, randomUUID} from "crypto";
import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {logger} from "firebase-functions";
import {setGlobalOptions} from "firebase-functions/v2";
import {defineSecret, defineString} from "firebase-functions/params";
import {initializeApp} from "firebase-admin/app";
import {getAuth, UserRecord} from "firebase-admin/auth";
import {FieldValue, getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {getStorage} from "firebase-admin/storage";
import {ImageAnnotatorClient} from "@google-cloud/vision";
import {v2 as translateV2} from "@google-cloud/translate";
import * as nodemailer from "nodemailer";

// Production SMTP configuration. These are bound at deploy time so operational
// emails (deposit/withdrawal/support/KYC notifications) can reach real users.
// Non-secret values are plain params; the password is a Secret Manager secret.
// See README "Production email" for the one-time setup commands. When SMTP_HOST
// is empty (e.g. SMTP not yet provisioned) email is skipped, never attempted
// against localhost.
const smtpHost = defineString("SMTP_HOST", {default: ""});
const smtpPort = defineString("SMTP_PORT", {default: "587"});
const smtpSecure = defineString("SMTP_SECURE", {default: "false"});
const smtpUser = defineString("SMTP_USER", {default: ""});
const smtpFrom = defineString("SMTP_FROM", {
  default: "BrickClub <no-reply@brickclub.app>",
});
const smtpPass = defineSecret("SMTP_PASS");

// Bind the SMTP secret to every function so any callable that triggers an
// operational email has the credential available at runtime.
setGlobalOptions({secrets: [smtpPass]});

initializeApp();

const isFunctionsEmulator = process.env.FUNCTIONS_EMULATOR === "true";

const db = getFirestore();
const auth = getAuth();
const messaging = getMessaging();
const storage = getStorage();
const vision = new ImageAnnotatorClient();
const translate = new translateV2.Translate();

// Locales we auto-translate admin content into (source content is English).
// Mirrors the client's supported locales minus `en`.
const TRANSLATION_LOCALES = ["zh", "es", "it", "ru", "ar", "sw", "hi"];

// Free-text asset fields worth translating. Enum-like fields (assetClass,
// riskLevel, category, paymentMethods) are intentionally excluded: members
// filter on their raw values, so translating them would break matching — those
// are localized client-side via ARB value maps instead.
const TRANSLATABLE_ASSET_FIELDS = [
  "title",
  "location",
  "description",
  "assetType",
  "strategy",
];

// Brand/technical terms that must survive translation verbatim.
const TRANSLATION_PROTECTED_TERMS = ["BrickShares", "BrickClub", "USDT", "KYC"];

type AdminAsset = {
  id: string;
  title: string;
  location: string;
  type: string;
  fundedPercent: number;
  reviewStatus: string;
  publishedStatus: string;
  // Expanded investment-opportunity data. Older Firestore documents will not
  // carry these fields, so every reader applies a safe default.
  description: string;
  category: string;
  assetType: string;
  images: string[];
  purchasePrice: number;
  fundingTarget: number;
  amountFunded: number;
  pricePerShare: number;
  totalShares: number;
  availableShares: number;
  expectedAnnualYield: number;
  projectedNetYield: number;
  strategy: string;
  riskLevel: string;
  exitPeriod: string;
  documents: string[];
  status: string;
  regulationNote: string;
  currentAssetValue: number;
  minimumInvestment: number;
};

type PaymentAccountField = {
  label: string;
  value: string;
};

// Models any payment method, crypto or otherwise. `type` discriminates: "crypto"
// uses network/walletAddress; "payoneer"/"wise"/"paytm" use accountDetails rows.
// `assetSymbol` doubles as the member-selectable method code for every type.
type CryptoPaymentOption = {
  id: string;
  type: string;
  network: string;
  assetSymbol: string;
  walletAddress: string;
  qrCodeUrl: string;
  accountDetails: PaymentAccountField[];
  enabled: boolean;
  minimumAmount: number;
};

type MemberOpportunity = {
  id: string;
  assetClass: string;
  riskLevel: string;
  paymentMethods: string[];
  title: string;
  location: string;
  minimumInvestment: number;
  targetReturn: number;
  fundedPercent: number;
  // Expanded fields surfaced to members. Defaults keep older assets valid.
  description: string;
  category: string;
  assetType: string;
  images: string[];
  purchasePrice: number;
  fundingTarget: number;
  amountFunded: number;
  pricePerShare: number;
  totalShares: number;
  availableShares: number;
  expectedAnnualYield: number;
  projectedNetYield: number;
  strategy: string;
  exitPeriod: string;
  documents: string[];
  status: string;
  regulationNote: string;
  currentAssetValue: number;
};

type WithdrawalPolicy = {
  minimumAmountUsd: number;
  flatFeeUsd: number;
  percentageFee: number;
  requiresDestinationWalletVerification: boolean;
  requiredApprovals: number;
  processingTime: string;
  enabled: boolean;
  notes: string;
};

type ReferralPolicy = {
  enabled: boolean;
  commissionPercent: number;
  firstInvestmentOnly: boolean;
};

type UserPayload = {
  email: string;
  password?: string;
  displayName?: string;
  disabled?: boolean;
  admin?: boolean;
  emailVerified?: boolean;
  phoneNumber?: string;
};

type KycDocumentPayload = {
  path: string;
  downloadUrl: string;
  contentType: string;
  originalName: string;
};

type KycDocumentSet = {
  governmentId: KycDocumentPayload;
  selfie: KycDocumentPayload;
  addressProof: KycDocumentPayload;
};

type KycAutomationResult = {
  status: "approved" | "rejected" | "manual_review";
  checks: {
    selfieFaceDetected: boolean;
    selfieSingleFace: boolean;
    idTextDetected: boolean;
    idNameMatched: boolean;
    idDateOfBirthMatched: boolean;
    idFaceDetected: boolean;
    addressProofUploaded: boolean;
  };
  confidence: number;
  reasons: string[];
};

const assetsCollection = db.collection("adminAssets");
const paymentOptionsCollection = db.collection("cryptoPaymentOptions");
const purchaseOrdersCollection = db.collection("purchaseOrders");
const memberHoldingsCollection = db.collection("memberHoldings");
const memberActivitiesCollection = db.collection("memberActivities");
const memberWalletsCollection = db.collection("memberWallets");
const walletTransactionsCollection = db.collection("walletTransactions");
const kycProfilesCollection = db.collection("kycProfiles");
const notificationTokensCollection = db.collection("notificationTokens");
const adminNotificationsCollection = db.collection("adminNotifications");
const withdrawalRequestsCollection = db.collection("withdrawalRequests");
const supportTicketsCollection = db.collection("supportTickets");
const referralAccountsCollection = db.collection("referralAccounts");
const referralCodesCollection = db.collection("referralCodes");
const referralCommissionsCollection = db.collection("referralCommissions");
const withdrawalPolicyDoc = db.collection("platformSettings").doc("withdrawals");
const referralPolicyDoc = db.collection("platformSettings").doc("referrals");
const devMailFrom = "BrickClub Dev <no-reply@brickclub.local>";

export const getMemberProfile = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication is required.");
  }

  const user = await auth.getUser(request.auth.uid);

  logger.info("Loaded member profile", {uid: request.auth.uid});

  return userToJson(user);
});

export const sendDevelopmentEmailVerification = onCall(async (request) => {
  ensureFunctionsEmulator();
  if (!request.auth?.token.email) {
    throw new HttpsError("unauthenticated", "Authentication is required.");
  }

  const user = await auth.getUser(request.auth.uid);
  if (!user.email) {
    throw new HttpsError("failed-precondition", "User has no email address.");
  }

  const link = await auth.generateEmailVerificationLink(user.email);

  await sendDevelopmentEmail({
    to: user.email,
    subject: "Verify your BrickClub email",
    text: [
      `Hi ${user.displayName ?? "there"},`,
      "",
      "Use this local development link to verify your BrickClub email:",
      link,
      "",
      "This message was sent by the Firebase Functions emulator.",
    ].join("\n"),
    html: [
      `<p>Hi ${escapeHtml(user.displayName ?? "there")},</p>`,
      "<p>Use this local development link to verify your BrickClub email.</p>",
      `<p><a href="${link}">Verify email</a></p>`,
      "<p>This message was sent by the Firebase Functions emulator.</p>",
    ].join(""),
  });

  logger.info("Sent development email verification", {uid: user.uid});

  return {email: user.email};
});

export const sendDevelopmentPasswordResetEmail = onCall(async (request) => {
  ensureFunctionsEmulator();
  const email = readEmail(readObject(request.data), "email");
  const link = await auth.generatePasswordResetLink(email);

  await sendDevelopmentEmail({
    to: email,
    subject: "Reset your BrickClub password",
    text: [
      "Use this local development link to reset your BrickClub password:",
      link,
      "",
      "This message was sent by the Firebase Functions emulator.",
    ].join("\n"),
    html: [
      "<p>Use this local development link to reset your BrickClub password.</p>",
      `<p><a href="${link}">Reset password</a></p>`,
      "<p>This message was sent by the Firebase Functions emulator.</p>",
    ].join(""),
  });

  logger.info("Sent development password reset email", {email});

  return {email};
});

export const listAdminDashboard = onAdminCall(async () => {
  const [usersResult, assetsSnapshot, paymentOptionsSnapshot, kycSnapshot] =
    await Promise.all([
      auth.listUsers(1000),
      assetsCollection.get(),
      paymentOptionsCollection.get(),
      kycProfilesCollection.get(),
    ]);
  const depositRequestsSnapshot = await purchaseOrdersCollection
    .where("status", "in", [
      "pending_payment",
      "proof_submitted",
      "deposit_verified",
      "deposit_rejected",
    ])
    .get();
  const supportTicketsSnapshot = await supportTicketsCollection
    .orderBy("updatedAt", "desc")
    .limit(100)
    .get();
  const notificationsSnapshot = await adminNotificationsCollection
    .orderBy("createdAt", "desc")
    .limit(25)
    .get();
  const withdrawalPolicy = await loadWithdrawalPolicy();
  const referralPolicy = await loadReferralPolicy();

  return {
    users: usersResult.users.map(userToJson),
    assets: assetsSnapshot.docs.map(assetFromDoc),
    cryptoPaymentOptions: paymentOptionsSnapshot.docs.map(paymentOptionFromDoc),
    depositRequests: depositRequestsSnapshot.docs.map(depositRequestFromDoc),
    supportTickets: supportTicketsSnapshot.docs.map(supportTicketFromDoc),
    notifications: notificationsSnapshot.docs.map(adminNotificationFromDoc),
    withdrawalPolicy,
    referralPolicy,
    kycProfiles: kycSnapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        uid: doc.id,
        fullLegalName: String(data.fullLegalName ?? ""),
        email: String(data.email ?? ""),
        phoneNumber: String(data.phoneNumber ?? ""),
        status: String(data.status ?? "notStarted"),
        rejectionReason: String(data.rejectionReason ?? ""),
        submittedAt: data.submittedAt?.toDate?.()?.toISOString() ?? "",
      };
    }),
  };
});

export const markAdminNotificationsRead = onAdminCall(async () => {
  const snapshot = await adminNotificationsCollection
    .where("read", "==", false)
    .get();
  if (snapshot.empty) {
    return {updated: 0};
  }

  const batch = db.batch();
  for (const doc of snapshot.docs) {
    batch.update(doc.ref, {
      read: true,
      readAt: FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();

  return {updated: snapshot.size};
});

export const listMemberOpportunities = onMemberCall(async (request) => {
  const locale = readLocale(request.data);
  const [assetsSnapshot, paymentOptionsSnapshot] = await Promise.all([
    assetsCollection
      .where("reviewStatus", "==", "Verified")
      .where("publishedStatus", "==", "Live")
      .get(),
    paymentOptionsCollection.where("enabled", "==", true).get(),
  ]);

  const paymentMethods = paymentOptionsSnapshot.docs
    .map((doc) => paymentOptionFromDoc(doc).assetSymbol)
    .filter((value, index, values) => values.indexOf(value) === index);

  return {
    opportunities: assetsSnapshot.docs.map((doc) =>
      opportunityFromDoc(doc, paymentMethods, locale),
    ),
  };
});

export const getMemberDashboard = onMemberCall(async (request) => {
  const uid = request.auth!.uid;
  const locale = readLocale(request.data);
  const [
    ordersSnapshot,
    assetsSnapshot,
    paymentOptionsSnapshot,
    holdingsSnapshot,
    walletSnapshot,
  ] = await Promise.all([
    purchaseOrdersCollection.where("uid", "==", uid).get(),
    assetsCollection.get(),
    paymentOptionsCollection.where("enabled", "==", true).get(),
    memberHoldingsCollection.where("userId", "==", uid).get(),
    memberWalletsCollection.doc(uid).get(),
  ]);
  const walletBalanceUsd = roundMoney(
    Number(walletSnapshot.data()?.balanceUsd ?? 0),
  );

  const assetsById = new Map(
    assetsSnapshot.docs.map((doc) => [
      doc.id,
      opportunityFromDoc(doc, [], locale),
    ]),
  );
  const orders = ordersSnapshot.docs
    .map((doc) => memberOrderFromDoc(doc))
    .sort((a, b) => b.updatedAt.localeCompare(a.updatedAt));
  const verifiedOrders = orders.filter(
    (order) => order.status === "deposit_verified",
  );

  // Prefer persisted holdings created at approval time. Fall back to deriving
  // them from verified orders for accounts created before holdings were stored.
  const holdings = holdingsSnapshot.empty ?
    buildMemberHoldings(verifiedOrders, assetsById) :
    holdingsSnapshot.docs.map((doc) => holdingFromDoc(doc));

  const totalInvested = roundMoney(
    holdings.reduce((total, holding) => total + holding.amountInvested, 0),
  );
  const totalCurrentValue = roundMoney(
    holdings.reduce((total, holding) => total + holding.currentValue, 0),
  );
  const totalDividends = roundMoney(
    holdings.reduce((total, holding) => total + holding.dividendsReceived, 0),
  );
  const totalProfitLoss = roundMoney(
    totalCurrentValue + totalDividends - totalInvested,
  );
  const overallReturnPercentage = totalInvested > 0 ?
    roundMoney((totalProfitLoss / totalInvested) * 100) :
    0;

  return {
    portfolioValueUsd: totalCurrentValue,
    walletBalanceUsd,
    yearReturnPercent: overallReturnPercentage,
    totalInvested,
    totalCurrentValue,
    totalDividends,
    totalProfitLoss,
    overallReturnPercentage,
    cryptoRails: paymentOptionsSnapshot.docs
      .map((doc) => paymentOptionFromDoc(doc))
      .map((option) => `${option.assetSymbol} on ${option.network}`),
    holdings,
    activity: orders.slice(0, 6).map(memberActivityFromOrder),
    allocation: buildMemberAllocation(holdings),
    chartValues: buildMemberChartValues(verifiedOrders),
    chartLabels: buildMemberChartLabels(),
  };
});

export const createPurchaseOrder = onMemberCall(async (request) => {
  const data = readObject(request.data);
  const opportunityId = readString(data, "opportunityId");
  const amountUsd = readPositiveNumber(data, "amountUsd");
  const paymentAsset = readString(data, "paymentAsset").toUpperCase();

  const uid = request.auth!.uid;
  const kycSnapshot = await kycProfilesCollection.doc(uid).get();
  if (kycSnapshot.data()?.status !== "approved") {
    throw new HttpsError(
      "failed-precondition",
      "KYC approval is required before investing.",
    );
  }

  const assetSnapshot = await assetsCollection.doc(opportunityId).get();
  if (!assetSnapshot.exists) {
    throw new HttpsError("not-found", "Opportunity was not found.");
  }

  // Canonical English here so denormalized order/notification copy stays
  // language-neutral; members see localized opportunity text via the list call.
  const asset = opportunityFromDoc(
    assetSnapshot,
    [paymentAsset],
    "en",
  );
  if (
    assetSnapshot.data()?.reviewStatus !== "Verified" ||
    assetSnapshot.data()?.publishedStatus !== "Live"
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Opportunity is not available for investment.",
    );
  }
  if (amountUsd < asset.minimumInvestment) {
    throw new HttpsError(
      "invalid-argument",
      "Amount is below the opportunity minimum.",
    );
  }

  const paymentOptionSnapshot = await paymentOptionsCollection
    .where("enabled", "==", true)
    .where("assetSymbol", "==", paymentAsset)
    .limit(1)
    .get();
  if (paymentOptionSnapshot.empty) {
    throw new HttpsError(
      "failed-precondition",
      "Selected payment asset is not enabled.",
    );
  }

  const paymentOption = paymentOptionFromDoc(paymentOptionSnapshot.docs[0]);
  if (amountUsd < paymentOption.minimumAmount) {
    throw new HttpsError(
      "invalid-argument",
      "Amount is below the payment option minimum.",
    );
  }

  const id = randomUUID();
  // Stablecoins (USDT/USDC) settle ~1:1 with USD, so the quote equals the USD
  // amount. Non-stablecoin assets (e.g. BTC) need a live price feed before
  // launch; until then they are quoted 1:1 as a placeholder.
  const quoteAmount = roundMoney(amountUsd);
  const isCrypto = paymentOption.type === "crypto";
  // Network fees are a crypto concept; non-crypto wire transfers carry none here.
  const networkFee = !isCrypto ? 0 : paymentAsset === "BTC" ? 0.0001 : 1;
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
  // Pre-compute the ownership and share figures the member is shown before
  // payment. The real holding is only written after admin approval.
  const sharesExpected = asset.pricePerShare > 0 ?
    roundShares(amountUsd / asset.pricePerShare) :
    0;
  const ownershipPercentage = asset.purchasePrice > 0 ?
    roundMoney((amountUsd / asset.purchasePrice) * 100) :
    0;

  const order = {
    id,
    uid,
    opportunityId,
    opportunityTitle: asset.title,
    amountUsd,
    paymentNetwork: paymentOption.network,
    paymentAsset,
    // Crypto-only aliases matching the upgraded PurchaseOrder model.
    cryptoCurrency: paymentAsset,
    cryptoNetwork: paymentOption.network,
    cryptoAmountExpected: quoteAmount,
    quoteAmount,
    networkFee,
    sharesExpected,
    ownershipPercentage,
    paymentWalletAddress: paymentOption.walletAddress,
    paymentQrCodeUrl: paymentOption.qrCodeUrl,
    paymentType: paymentOption.type,
    paymentAccountDetails: paymentOption.accountDetails,
    status: "pending_payment",
    expiresAt: expiresAt.toISOString(),
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };

  await purchaseOrdersCollection.doc(id).set(order);

  await notifyAdmins({
    type: "deposit_request_created",
    title: "New deposit request",
    body: `${asset.title} deposit request created for ${formatUsd(amountUsd)}.`,
    data: {orderId: id, uid, opportunityId},
  });

  return order;
});

export const submitDepositProof = onMemberCall(async (request) => {
  const data = readObject(request.data);
  const orderId = readString(data, "orderId");
  const transactionHash = readString(data, "transactionHash");
  const proofUrl = readString(data, "proofUrl");
  const uid = request.auth!.uid;

  const orderRef = purchaseOrdersCollection.doc(orderId);
  const orderSnapshot = await orderRef.get();
  const order = orderSnapshot.data();
  if (!orderSnapshot.exists || !order) {
    throw new HttpsError("not-found", "Deposit request was not found.");
  }
  if (order.uid !== uid) {
    throw new HttpsError(
      "permission-denied",
      "You can only update your own deposit request.",
    );
  }
  if (order.status !== "pending_payment") {
    throw new HttpsError(
      "failed-precondition",
      "This deposit request is no longer awaiting proof.",
    );
  }

  await orderRef.set(
    {
      transactionHash,
      proofUrl,
      status: "proof_submitted",
      proofSubmittedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  await notifyAdmins({
    type: "deposit_proof_submitted",
    title: "Deposit proof submitted",
    body: `${String(order.opportunityTitle ?? "BrickShares")} proof is ready for verification.`,
    data: {orderId, uid},
  });

  return {
    ...order,
    id: orderId,
    transactionHash,
    proofUrl,
    status: "proof_submitted",
  };
});

export const verifyDepositProof = onAdminCall(async (data, context) => {
  const orderId = readString(data, "orderId");
  const orderRef = purchaseOrdersCollection.doc(orderId);

  // Run approval as a single transaction so the order status, member holding,
  // asset funding totals, and activity log stay consistent. The MemberHolding
  // is created here and only here — never when proof is first submitted.
  const result = await db.runTransaction(async (tx) => {
    const orderSnapshot = await tx.get(orderRef);
    const order = orderSnapshot.data();
    if (!orderSnapshot.exists || !order) {
      throw new HttpsError("not-found", "Deposit request was not found.");
    }
    // Admins may approve a submitted proof, or manually approve a request that
    // is still awaiting payment/proof (e.g. funds confirmed off-platform).
    if (
      order.status !== "proof_submitted" &&
      order.status !== "pending_payment"
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Only pending or submitted deposit requests can be verified.",
      );
    }
    const manuallyApproved = order.status === "pending_payment";

    const uid = String(order.uid);
    const opportunityId = String(order.opportunityId);
    const amountUsd = Number(order.amountUsd ?? 0);

    const assetRef = assetsCollection.doc(opportunityId);
    const assetSnapshot = await tx.get(assetRef);
    const asset = assetSnapshot.exists ?
      assetFromData(assetSnapshot.id, assetSnapshot.data()!) :
      null;

    const holdingRef = memberHoldingsCollection.doc(`${uid}_${opportunityId}`);
    const holdingSnapshot = await tx.get(holdingRef);
    const existingHolding = holdingSnapshot.data();

    // Accumulate onto any prior holding for the same asset.
    const priorInvested = Number(existingHolding?.amountInvested ?? 0);
    const priorShares = Number(existingHolding?.sharesOwned ?? 0);
    const priorDividends = Number(existingHolding?.dividendsReceived ?? 0);

    const pricePerShare = asset?.pricePerShare ?? 0;
    const purchasePrice = asset?.purchasePrice ?? 0;
    const currentAssetValue = asset?.currentAssetValue ?? purchasePrice;

    const sharesPurchased = pricePerShare > 0 ?
      roundShares(amountUsd / pricePerShare) :
      0;
    const amountInvested = roundMoney(priorInvested + amountUsd);
    const sharesOwned = roundShares(priorShares + sharesPurchased);
    const figures = computeHoldingFigures({
      amountInvested,
      purchasePrice,
      currentAssetValue,
      dividendsReceived: priorDividends,
    });

    // Write order approval state.
    tx.set(
      orderRef,
      {
        status: "deposit_verified",
        approvedAt: FieldValue.serverTimestamp(),
        approvedBy: context.uid,
        manuallyApproved,
        verifiedAt: FieldValue.serverTimestamp(),
        rejectionReason: FieldValue.delete(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );

    // Create or update the member holding.
    tx.set(
      holdingRef,
      {
        holdingId: holdingRef.id,
        userId: uid,
        assetId: opportunityId,
        assetTitle: asset?.title ?? String(order.opportunityTitle ?? ""),
        assetImageUrl: asset?.images?.[0] ?? "",
        assetCategory: asset?.category ?? "",
        assetStrategy: asset?.strategy ?? "",
        assetStatus: asset?.status ?? "available",
        amountInvested,
        sharesOwned,
        ownershipPercentage: figures.ownershipPercentage,
        currentValue: figures.currentValue,
        dividendsReceived: priorDividends,
        profitLoss: figures.profitLoss,
        returnPercentage: figures.returnPercentage,
        createdAt: existingHolding?.createdAt ?? FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );

    // Update asset funding totals when the asset still exists.
    if (asset) {
      const fundingTarget = asset.fundingTarget;
      const newAmountFunded = roundMoney(asset.amountFunded + amountUsd);
      const newAvailableShares = asset.totalShares > 0 ?
        Math.max(0, roundShares(asset.availableShares - sharesPurchased)) :
        asset.availableShares;
      const newFundedPercent = fundingTarget > 0 ?
        roundMoney((newAmountFunded / fundingTarget) * 100) :
        asset.fundedPercent;
      tx.set(
        assetRef,
        {
          amountFunded: newAmountFunded,
          availableShares: newAvailableShares,
          fundedPercent: newFundedPercent,
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true},
      );
    }

    // Record the member activity entry.
    const activityRef = memberActivitiesCollection.doc();
    tx.set(activityRef, {
      id: activityRef.id,
      uid,
      type: "investment_approved",
      title: "Investment approved",
      subtitle: asset?.title ?? String(order.opportunityTitle ?? ""),
      value: formatUsd(amountUsd),
      status: "deposit_verified",
      opportunityId,
      orderId,
      amountUsd,
      createdAt: FieldValue.serverTimestamp(),
    });

    return {uid, opportunityId, amountUsd};
  });

  // Best-effort referral commission. A failure here must never undo the
  // already-committed deposit verification, so it is isolated and logged.
  try {
    await accrueReferralCommission({
      refereeUid: result.uid,
      orderId,
      opportunityId: result.opportunityId,
      amountUsd: result.amountUsd,
    });
  } catch (error) {
    logger.error("Referral commission accrual failed", {orderId, error});
  }

  await notifyMember(result.uid, {
    type: "deposit_verified",
    title: "Deposit verified",
    body: "Your crypto deposit proof has been verified and added to your portfolio.",
    data: {orderId},
  });

  return {orderId, status: "deposit_verified"};
});

export const rejectDepositProof = onAdminCall(async (data) => {
  const value = readObject(data);
  const orderId = readString(value, "orderId");
  const reason = readString(value, "reason");
  const orderRef = purchaseOrdersCollection.doc(orderId);
  const orderSnapshot = await orderRef.get();
  const order = orderSnapshot.data();
  if (!orderSnapshot.exists || !order) {
    throw new HttpsError("not-found", "Deposit request was not found.");
  }
  // Only submitted proofs may be rejected. This prevents rejecting an order
  // that was already verified (and therefore already has a holding).
  if (order.status !== "proof_submitted") {
    throw new HttpsError(
      "failed-precondition",
      "Only submitted deposit proofs can be rejected.",
    );
  }

  await orderRef.set(
    {
      status: "deposit_rejected",
      rejectionReason: reason,
      reviewedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  await notifyMember(String(order.uid), {
    type: "deposit_rejected",
    title: "Deposit proof needs attention",
    body: reason,
    data: {orderId},
  });

  return {orderId, status: "deposit_rejected", reason};
});

// Admin-initiated wallet adjustment. A `credit` is a manual deposit (e.g. funds
// received off-platform); a `debit` is a correction. Every adjustment requires a
// reason and is recorded in the walletTransactions ledger for audit.
export const adjustMemberWallet = onAdminCall(async (data, context) => {
  const value = readObject(data);
  const uid = readString(value, "uid");
  const amountUsd = readPositiveNumber(value, "amountUsd");
  const direction = readString(value, "direction").toLowerCase();
  const reason = readString(value, "reason");
  if (direction !== "credit" && direction !== "debit") {
    throw new HttpsError(
      "invalid-argument",
      "direction must be either credit or debit.",
    );
  }

  // Ensure the target user exists before mutating their wallet.
  await auth.getUser(uid);

  const result = await applyWalletAdjustment({
    uid,
    amountUsd,
    direction,
    reason,
    createdBy: context.uid,
  });

  await notifyMember(uid, {
    type: direction === "credit" ? "wallet_credited" : "wallet_debited",
    title: direction === "credit" ?
      "Funds added to your wallet" :
      "Wallet balance adjusted",
    body: direction === "credit" ?
      `${formatUsd(amountUsd)} was added to your wallet balance. ${reason}` :
      `${formatUsd(amountUsd)} was deducted from your wallet balance. ${reason}`,
    data: {transactionId: result.transactionId},
  });

  return {
    uid,
    balanceUsd: result.balanceUsd,
    transactionId: result.transactionId,
  };
});

export const createWithdrawalRequest = onMemberCall(async (request) => {
  const data = readObject(request.data);
  const amountUsd = readPositiveNumber(data, "amountUsd");
  const destinationAddress = readString(data, "destinationAddress");
  const assetSymbol = readString(data, "assetSymbol").toUpperCase();
  const uid = request.auth!.uid;
  const policy = await loadWithdrawalPolicy();
  if (!policy.enabled) {
    throw new HttpsError(
      "failed-precondition",
      "Withdrawals are temporarily disabled.",
    );
  }
  if (amountUsd < policy.minimumAmountUsd) {
    throw new HttpsError(
      "invalid-argument",
      "Amount is below the withdrawal minimum.",
    );
  }
  if (
    policy.requiresDestinationWalletVerification &&
    !isLikelyWalletAddress(destinationAddress)
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Enter a valid destination wallet address.",
    );
  }
  const id = randomUUID();
  const feeUsd = roundMoney(
    policy.flatFeeUsd + (amountUsd * policy.percentageFee / 100),
  );

  const requestData = {
    id,
    uid,
    amountUsd,
    feeUsd,
    netAmountUsd: roundMoney(amountUsd - feeUsd),
    destinationAddress,
    assetSymbol,
    status: "submitted",
    requiredApprovals: policy.requiredApprovals,
    approvalsCompleted: 0,
    processingTime: policy.processingTime,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };
  await withdrawalRequestsCollection.doc(id).set(requestData);

  await notifyAdmins({
    type: "withdrawal_request_created",
    title: "New withdrawal request",
    body: `${formatUsd(amountUsd)} ${assetSymbol} withdrawal request submitted.`,
    data: {withdrawalRequestId: id, uid},
  });

  return requestData;
});

export const updateWithdrawalPolicy = onAdminCall(async (data) => {
  const policy = readWithdrawalPolicy(data);
  await withdrawalPolicyDoc.set(
    {
      ...policy,
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  return policy;
});

export const updateReferralPolicy = onAdminCall(async (data) => {
  const policy = readReferralPolicy(data);
  await referralPolicyDoc.set(
    {
      ...policy,
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  return policy;
});

// Returns the caller's referral profile, lazily creating their account (with a
// unique share code) on first access so existing members get a code too. Also
// returns the referrer's lifetime earnings, referral count, current commission
// rate, and recent commission history.
export const getReferralProfile = onMemberCall(async (request) => {
  const uid = request.auth!.uid;
  const [account, policy, commissionsSnapshot] = await Promise.all([
    ensureReferralAccount(uid),
    loadReferralPolicy(),
    referralCommissionsCollection
      .where("referrerUid", "==", uid)
      .orderBy("createdAt", "desc")
      .limit(25)
      .get(),
  ]);

  return {
    referralCode: account.referralCode,
    referredBy: account.referredBy ?? "",
    referredByCode: account.referredByCode ?? "",
    referralCount: account.referralCount,
    totalEarnedUsd: roundMoney(account.totalEarnedUsd),
    commissionPercent: policy.commissionPercent,
    referralsEnabled: policy.enabled,
    commissions: commissionsSnapshot.docs.map(referralCommissionFromDoc),
  };
});

// Records the inviter for the caller from a shared referral code. Idempotent and
// guarded: a member may only ever set their referrer once, may not refer
// themselves, and may not attach a referrer after they have already invested.
export const claimReferralCode = onMemberCall(async (request) => {
  const uid = request.auth!.uid;
  const code = readString(request.data, "code").toUpperCase();

  const codeSnapshot = await referralCodesCollection.doc(code).get();
  const referrerUid = codeSnapshot.data()?.uid as string | undefined;
  if (!codeSnapshot.exists || !referrerUid) {
    throw new HttpsError("not-found", "That referral code was not found.");
  }
  if (referrerUid === uid) {
    throw new HttpsError(
      "failed-precondition",
      "You cannot use your own referral code.",
    );
  }

  // Block attaching a referrer once the member has verified investments — this
  // stops retroactive credit grabs after the fact.
  const verifiedOrders = await purchaseOrdersCollection
    .where("uid", "==", uid)
    .where("status", "==", "deposit_verified")
    .limit(1)
    .get();
  if (!verifiedOrders.empty) {
    throw new HttpsError(
      "failed-precondition",
      "A referrer can only be set before your first investment.",
    );
  }

  // Ensure both accounts exist, then set referredBy once inside a transaction.
  await ensureReferralAccount(uid);
  const refereeRef = referralAccountsCollection.doc(uid);
  const referrerRef = referralAccountsCollection.doc(referrerUid);
  const applied = await db.runTransaction(async (tx) => {
    const refereeSnap = await tx.get(refereeRef);
    if (refereeSnap.data()?.referredBy) {
      return false; // Already attributed — leave as-is.
    }
    tx.set(
      refereeRef,
      {
        referredBy: referrerUid,
        referredByCode: code,
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );
    tx.set(
      referrerRef,
      {
        referralCount: FieldValue.increment(1),
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );
    return true;
  });

  return {applied, referredBy: referrerUid};
});

export const registerMessagingToken = onMemberCall(async (request) => {
  const data = readObject(request.data);
  const token = readString(data, "token");
  const platform = readOptionalString(data, "platform") ?? "unknown";

  await notificationTokensCollection.doc(token).set(
    {
      uid: request.auth!.uid,
      admin: request.auth!.token.admin === true,
      platform,
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  return {registered: true};
});

export const createSupportTicket = onMemberCall(async (request) => {
  const data = readObject(request.data);
  const subject = readString(data, "subject");
  const message = readString(data, "message");
  const uid = request.auth!.uid;
  const user = await auth.getUser(uid);
  const id = randomUUID();
  const now = new Date().toISOString();

  const ticket = {
    id,
    uid,
    subject,
    status: "waiting_for_admin",
    userEmail: user.email ?? "",
    userDisplayName: user.displayName ?? "",
    messages: [
      supportMessage({
        senderUid: uid,
        senderRole: "member",
        body: message,
        createdAt: now,
      }),
    ],
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };

  await supportTicketsCollection.doc(id).set(ticket);

  await notifyAdmins({
    type: "support_ticket_created",
    title: "New support request",
    body: `${subject}: ${message}`,
    data: {ticketId: id, uid},
  });

  return {id};
});

export const replyToSupportTicket = onMemberCall(async (request) => {
  const data = readObject(request.data);
  const ticketId = readString(data, "ticketId");
  const message = readString(data, "message");
  const uid = request.auth!.uid;
  const ticketRef = supportTicketsCollection.doc(ticketId);
  const snapshot = await ticketRef.get();
  const ticket = snapshot.data();

  if (!snapshot.exists || !ticket) {
    throw new HttpsError("not-found", "Support ticket was not found.");
  }
  if (ticket.uid !== uid) {
    throw new HttpsError(
      "permission-denied",
      "You can only reply to your own support tickets.",
    );
  }
  if (ticket.status === "closed") {
    throw new HttpsError(
      "failed-precondition",
      "This support ticket is already closed.",
    );
  }

  await ticketRef.set(
    {
      status: "waiting_for_admin",
      messages: FieldValue.arrayUnion(
        supportMessage({
          senderUid: uid,
          senderRole: "member",
          body: message,
          createdAt: new Date().toISOString(),
        }),
      ),
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  await notifyAdmins({
    type: "support_ticket_replied",
    title: "Support reply from member",
    body: `${String(ticket.subject ?? "Support request")}: ${message}`,
    data: {ticketId, uid},
  });

  return {ticketId};
});

export const adminReplyToSupportTicket = onAdminCall(async (data) => {
  const value = readObject(data);
  const ticketId = readString(value, "ticketId");
  const message = readString(value, "message");
  const ticketRef = supportTicketsCollection.doc(ticketId);
  const snapshot = await ticketRef.get();
  const ticket = snapshot.data();

  if (!snapshot.exists || !ticket) {
    throw new HttpsError("not-found", "Support ticket was not found.");
  }
  if (ticket.status === "closed") {
    throw new HttpsError(
      "failed-precondition",
      "This support ticket is already closed.",
    );
  }

  await ticketRef.set(
    {
      status: "waiting_for_member",
      messages: FieldValue.arrayUnion(
        supportMessage({
          senderUid: "",
          senderRole: "admin",
          body: message,
          createdAt: new Date().toISOString(),
        }),
      ),
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  await notifyMember(String(ticket.uid), {
    type: "support_ticket_replied",
    title: "Support replied",
    body: message,
    data: {ticketId},
  });

  return {ticketId};
});

export const closeSupportTicket = onAdminCall(async (data) => {
  const ticketId = readString(data, "ticketId");
  const ticketRef = supportTicketsCollection.doc(ticketId);
  const snapshot = await ticketRef.get();
  const ticket = snapshot.data();

  if (!snapshot.exists || !ticket) {
    throw new HttpsError("not-found", "Support ticket was not found.");
  }

  await ticketRef.set(
    {
      status: "closed",
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  await notifyMember(String(ticket.uid), {
    type: "support_ticket_closed",
    title: "Support request closed",
    body: String(ticket.subject ?? "Your support request was closed."),
    data: {ticketId},
  });

  return {ticketId, status: "closed"};
});

export const createAdminUser = onAdminCall(async (data) => {
  const payload = readUserPayload(data);
  if (!payload.password) {
    throw new HttpsError("invalid-argument", "Password is required.");
  }

  const phoneNumber = normalizePhoneNumber(payload.phoneNumber, {
    allowClear: false,
  });

  const user = await auth.createUser({
    email: payload.email,
    password: payload.password,
    displayName: payload.displayName,
    disabled: payload.disabled ?? false,
    emailVerified: payload.emailVerified ?? false,
    ...(phoneNumber ? {phoneNumber} : {}),
  });

  if (payload.admin) {
    await auth.setCustomUserClaims(user.uid, {admin: true});
  }

  return userToJson(await auth.getUser(user.uid));
});

export const updateAdminUser = onAdminCall(async (data) => {
  const uid = readString(data, "uid");
  const payload = readUserPayload(data, {passwordOptional: true});

  const phoneNumber = normalizePhoneNumber(payload.phoneNumber, {
    allowClear: true,
  });

  await auth.updateUser(uid, {
    email: payload.email,
    password: payload.password,
    displayName: payload.displayName,
    disabled: payload.disabled,
    ...(payload.emailVerified !== undefined ?
      {emailVerified: payload.emailVerified} :
      {}),
    ...(phoneNumber !== undefined ? {phoneNumber} : {}),
  });

  if (payload.admin !== undefined) {
    await auth.setCustomUserClaims(uid, payload.admin ? {admin: true} : null);
  }

  return userToJson(await auth.getUser(uid));
});

export const deleteAdminUser = onAdminCall(async (data) => {
  const uid = readString(data, "uid");
  await auth.deleteUser(uid);
  return {uid};
});

export const setUserAdmin = onAdminCall(async (data) => {
  const uid = readString(data, "uid");
  const admin = readBoolean(data, "admin");

  await auth.setCustomUserClaims(uid, admin ? {admin: true} : null);

  return userToJson(await auth.getUser(uid));
});

export const getAdminUserDetail = onAdminCall(async (data) => {
  const uid = readString(data, "uid");

  const [
    user,
    kycSnapshot,
    holdingsSnapshot,
    ordersSnapshot,
    walletSnapshot,
    walletTxSnapshot,
  ] = await Promise.all([
    auth.getUser(uid),
    kycProfilesCollection.doc(uid).get(),
    memberHoldingsCollection.where("userId", "==", uid).get(),
    purchaseOrdersCollection.where("uid", "==", uid).get(),
    memberWalletsCollection.doc(uid).get(),
    walletTransactionsCollection
      .where("uid", "==", uid)
      .orderBy("createdAt", "desc")
      .limit(20)
      .get(),
  ]);

  const holdings = holdingsSnapshot.docs.map((doc) => holdingFromDoc(doc));
  const totalInvested = roundMoney(
    holdings.reduce((total, holding) => total + holding.amountInvested, 0),
  );
  const totalCurrentValue = roundMoney(
    holdings.reduce((total, holding) => total + holding.currentValue, 0),
  );
  const totalDividends = roundMoney(
    holdings.reduce((total, holding) => total + holding.dividendsReceived, 0),
  );
  const totalProfitLoss = roundMoney(
    totalCurrentValue + totalDividends - totalInvested,
  );
  const overallReturnPercentage = totalInvested > 0 ?
    roundMoney((totalProfitLoss / totalInvested) * 100) :
    0;

  const orders = ordersSnapshot.docs
    .map((doc) => memberOrderFromDoc(doc))
    .sort((a, b) => b.updatedAt.localeCompare(a.updatedAt));

  const kyc = kycSnapshot.exists ? kycSnapshot.data()! : undefined;

  return {
    user: userToJson(user),
    wallet: {
      balanceUsd: roundMoney(Number(walletSnapshot.data()?.balanceUsd ?? 0)),
      transactions: walletTxSnapshot.docs.map(walletTransactionFromDoc),
    },
    kyc: kyc ?
      {
        uid,
        fullLegalName: String(kyc.fullLegalName ?? ""),
        email: String(kyc.email ?? user.email ?? ""),
        phoneNumber: String(kyc.phoneNumber ?? ""),
        dateOfBirth: readSerializableDate(kyc.dateOfBirth),
        status: String(kyc.status ?? "notStarted"),
        rejectionReason: String(kyc.rejectionReason ?? ""),
        phoneVerified: kyc.phoneVerified === true,
        governmentIdUrl: String(kyc.documents?.governmentIdUrl ?? ""),
        selfieUrl: String(kyc.documents?.selfieUrl ?? ""),
        addressProofUrl: String(kyc.documents?.addressProofUrl ?? ""),
        submittedAt: readSerializableDate(kyc.submittedAt),
      } :
      null,
    portfolio: {
      totalInvested,
      totalCurrentValue,
      totalDividends,
      totalProfitLoss,
      overallReturnPercentage,
      holdings: holdings.map((holding) => ({
        assetId: holding.assetId,
        assetTitle: holding.assetTitle,
        amountInvested: holding.amountInvested,
        currentValue: holding.currentValue,
        profitLoss: holding.profitLoss,
        returnPercentage: holding.returnPercentage,
      })),
    },
    orders: orders.map((order) => ({
      id: order.id,
      opportunityTitle: order.opportunityTitle,
      amountUsd: order.amountUsd,
      status: order.status,
      updatedAt: order.updatedAt,
    })),
  };
});

export const submitKycProfile = onMemberCall(async (request) => {
  const uid = request.auth!.uid;
  const data = readObject(request.data);
  const fullLegalName = readString(data, "fullLegalName");
  const dateOfBirth = readDateString(data, "dateOfBirth");
  const phoneNumber = readString(data, "phoneNumber");
  const documents = readKycDocumentSet(readObject(data.documents));
  validateKycDocumentOwnership(uid, documents);

  const user = await auth.getUser(uid);
  const automation = await runKycAutomation({
    fullLegalName,
    dateOfBirth,
    documents,
  });
  const identityVerified = user.emailVerified && user.phoneNumber === phoneNumber;
  const approved =
    automation.status === "approved" &&
    identityVerified;
  // Anything that is neither auto-approved nor a hard automation rejection
  // goes into the human review queue as "submitted". This is the status the
  // member app renders as "under review" and that listSubmittedKycProfiles
  // surfaces to admins.
  const status = approved ?
    "approved" :
    automation.status === "rejected" ?
      "rejected" :
      "submitted";
  const rejectionReason = status === "rejected" ?
    automation.reasons.join(" ") :
    undefined;

  await kycProfilesCollection.doc(uid).set(
    {
      uid,
      fullLegalName,
      dateOfBirth: new Date(dateOfBirth),
      phoneNumber,
      email: user.email,
      emailVerified: user.emailVerified,
      phoneVerified: user.phoneNumber === phoneNumber,
      status,
      documents: {
        governmentIdUrl: documents.governmentId.downloadUrl,
        governmentIdPath: documents.governmentId.path,
        selfieUrl: documents.selfie.downloadUrl,
        selfiePath: documents.selfie.path,
        addressProofUrl: documents.addressProof.downloadUrl,
        addressProofPath: documents.addressProof.path,
      },
      automatedKyc: {
        ...automation,
        provider: "google-cloud-vision",
        reviewedAt: FieldValue.serverTimestamp(),
      },
      rejectionReason: rejectionReason ?? FieldValue.delete(),
      submittedAt: FieldValue.serverTimestamp(),
      reviewedAt: status === "submitted" ?
        FieldValue.delete() :
        FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  if (status === "submitted") {
    await notifyAdmins({
      type: "kyc_manual_review_required",
      title: "KYC needs manual review",
      body: `${fullLegalName} submitted KYC documents that need review.`,
      data: {uid},
    });
  }

  return {uid, status, automation};
});

export const approveKycProfile = onAdminCall(async (data) => {
  const uid = readString(data, "uid");
  await kycProfilesCollection.doc(uid).set(
    {
      status: "approved",
      rejectionReason: FieldValue.delete(),
      reviewedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  return {uid, status: "approved"};
});

export const rejectKycProfile = onAdminCall(async (data) => {
  const value = readObject(data);
  const uid = readString(value, "uid");
  const rejectionReason = readString(value, "rejectionReason");
  await kycProfilesCollection.doc(uid).set(
    {
      status: "rejected",
      rejectionReason,
      reviewedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  return {uid, status: "rejected", rejectionReason};
});

export const listSubmittedKycProfiles = onAdminCall(async () => {
  const snapshot = await kycProfilesCollection
    .where("status", "in", ["submitted", "rejected"])
    .get();

  return {
    profiles: snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        uid: doc.id,
        fullLegalName: String(data.fullLegalName ?? ""),
        email: String(data.email ?? ""),
        phoneNumber: String(data.phoneNumber ?? ""),
        status: String(data.status ?? "notStarted"),
        rejectionReason: String(data.rejectionReason ?? ""),
      };
    }),
  };
});

export const createAdminAsset = onAdminCall(async (data) => {
  const payload = readAssetPayload(data);
  const id = randomUUID();

  await assetsCollection.doc(id).set({
    ...payload,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });

  return {id, ...payload};
});

export const updateAdminAsset = onAdminCall(async (data) => {
  const id = readString(data, "id");
  const payload = readAssetPayload(data);

  await assetsCollection.doc(id).set(
    {
      ...payload,
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  return {id, ...payload};
});

export const deleteAdminAsset = onAdminCall(async (data) => {
  const id = readString(data, "id");
  await assetsCollection.doc(id).delete();
  return {id};
});

export const updateAssetValuation = onAdminCall(async (data) => {
  const value = readObject(data);
  const id = readString(value, "id");
  const currentAssetValue = readPositiveNumber(value, "currentAssetValue");
  const valuationDate = readOptionalString(value, "valuationDate") ?? "";
  const performanceNotes = readOptionalString(value, "performanceNotes") ?? "";

  const assetRef = assetsCollection.doc(id);
  const assetSnapshot = await assetRef.get();
  if (!assetSnapshot.exists) {
    throw new HttpsError("not-found", "Asset was not found.");
  }
  const asset = assetFromData(assetSnapshot.id, assetSnapshot.data()!);

  // Persist the valuation plus optional performance inputs. Dividends are not
  // implemented yet, so the income figures are stored for reporting only.
  await assetRef.set(
    {
      currentAssetValue,
      performance: {
        currentValue: currentAssetValue,
        assetIncome: readNumberOrDefault(value, "assetIncome", 0),
        expenses: readNumberOrDefault(value, "expenses", 0),
        netIncome: readNumberOrDefault(value, "netIncome", 0),
        occupancyRate: readNumberOrDefault(value, "occupancyRate", 0),
        valuationDate,
        performanceNotes,
        updatedAt: FieldValue.serverTimestamp(),
      },
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  // Recompute profit/loss for every holding tied to this asset so member
  // portfolios reflect the new valuation. Batched for consistency.
  const holdingsSnapshot = await memberHoldingsCollection
    .where("assetId", "==", id)
    .get();
  if (!holdingsSnapshot.empty) {
    const batch = db.batch();
    for (const doc of holdingsSnapshot.docs) {
      const holding = doc.data();
      const figures = computeHoldingFigures({
        amountInvested: Number(holding.amountInvested ?? 0),
        purchasePrice: asset.purchasePrice,
        currentAssetValue,
        dividendsReceived: Number(holding.dividendsReceived ?? 0),
      });
      batch.set(
        doc.ref,
        {
          currentValue: figures.currentValue,
          profitLoss: figures.profitLoss,
          returnPercentage: figures.returnPercentage,
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true},
      );
    }
    await batch.commit();
  }

  return {id, currentAssetValue, holdingsUpdated: holdingsSnapshot.size};
});

export const createCryptoPaymentOption = onAdminCall(async (data) => {
  const payload = readPaymentOptionPayload(data);
  const id = randomUUID();

  await paymentOptionsCollection.doc(id).set({
    ...payload,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });

  return {id, ...payload};
});

export const updateCryptoPaymentOption = onAdminCall(async (data) => {
  const id = readString(data, "id");
  const payload = readPaymentOptionPayload(data);

  await paymentOptionsCollection.doc(id).set(
    {
      ...payload,
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  return {id, ...payload};
});

export const deleteCryptoPaymentOption = onAdminCall(async (data) => {
  const id = readString(data, "id");
  await paymentOptionsCollection.doc(id).delete();
  return {id};
});

function onAdminCall<T>(
  handler: (data: unknown, context: {uid: string}) => Promise<T>,
) {
  return onCall(async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication is required.");
    }

    if (request.auth.token.admin !== true) {
      throw new HttpsError("permission-denied", "Admin access is required.");
    }

    return handler(request.data, {uid: request.auth.uid});
  });
}

function onMemberCall<T>(
  handler: (request: CallableRequest<unknown>) => Promise<T>,
) {
  return onCall(async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication is required.");
    }

    return handler(request);
  });
}

function userToJson(user: UserRecord) {
  return {
    uid: user.uid,
    email: user.email,
    displayName: user.displayName,
    phoneNumber: user.phoneNumber ?? "",
    disabled: user.disabled,
    emailVerified: user.emailVerified,
    admin: user.customClaims?.admin === true,
    createdAt: user.metadata.creationTime,
    lastSignInAt: user.metadata.lastSignInTime,
  };
}

function assetFromDoc(
  doc: FirebaseFirestore.QueryDocumentSnapshot,
): AdminAsset {
  return assetFromData(doc.id, doc.data());
}

function assetFromData(
  id: string,
  data: FirebaseFirestore.DocumentData,
): AdminAsset {
  const purchasePrice = Number(data.purchasePrice ?? 0);
  const fundingTarget = Number(data.fundingTarget ?? 0);
  const amountFunded = Number(data.amountFunded ?? 0);
  // Prefer a derived funding percentage when a funding target exists, falling
  // back to the legacy admin-entered fundedPercent for older documents.
  const fundedPercent = fundingTarget > 0 ?
    roundMoney((amountFunded / fundingTarget) * 100) :
    Number(data.fundedPercent ?? 0);
  const type = String(data.type ?? data.assetType ?? "");

  return {
    id,
    title: String(data.title ?? ""),
    location: String(data.location ?? ""),
    type,
    fundedPercent,
    reviewStatus: String(data.reviewStatus ?? "Pending"),
    publishedStatus: String(data.publishedStatus ?? "Draft"),
    description: String(data.description ?? ""),
    category: String(data.category ?? "realEstate"),
    assetType: String(data.assetType ?? type),
    images: readStringArrayOrDefault(data.images, []),
    purchasePrice,
    fundingTarget,
    amountFunded,
    pricePerShare: Number(data.pricePerShare ?? 0),
    totalShares: Number(data.totalShares ?? 0),
    availableShares: Number(data.availableShares ?? data.totalShares ?? 0),
    expectedAnnualYield: Number(data.expectedAnnualYield ?? 0),
    projectedNetYield: Number(data.projectedNetYield ?? 0),
    strategy: String(data.strategy ?? "capitalGrowth"),
    riskLevel: String(data.riskLevel ?? "balanced"),
    exitPeriod: String(data.exitPeriod ?? ""),
    documents: readStringArrayOrDefault(data.documents, []),
    status: String(data.status ?? "available"),
    regulationNote: String(data.regulationNote ?? ""),
    currentAssetValue: Number(data.currentAssetValue ?? purchasePrice),
    minimumInvestment: Number(data.minimumInvestment ?? 50),
  };
}

// Normalize a client-sent locale to a supported language code, defaulting to
// English when missing/unsupported.
function readLocale(data: unknown): string {
  if (data && typeof data === "object") {
    const value = (data as Record<string, unknown>).locale;
    if (typeof value === "string") {
      const code = value.trim().toLowerCase().split(/[-_]/)[0];
      if (code === "en" || TRANSLATION_LOCALES.includes(code)) return code;
    }
  }
  return "en";
}

function decodeHtmlEntities(input: string): string {
  return input
    .replace(/&#39;/g, "'")
    .replace(/&quot;/g, "\"")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&");
}

// Wrap protected terms so the Translation API (in HTML mode) leaves them
// verbatim, then strip the wrappers from the result.
function protectTerms(text: string): string {
  let out = text;
  for (const term of TRANSLATION_PROTECTED_TERMS) {
    out = out.split(term).join(`<span translate="no">${term}</span>`);
  }
  return out;
}

function unprotectTerms(text: string): string {
  return decodeHtmlEntities(
    text.replace(/<span translate="no">(.*?)<\/span>/g, "$1"),
  );
}

function assetTranslationHash(source: Record<string, string>): string {
  const canonical = TRANSLATABLE_ASSET_FIELDS
    .map((field) => `${field}=${source[field] ?? ""}`)
    .join(" ");
  return createHash("sha1").update(canonical).digest("hex");
}

// Auto-translates an asset's free-text fields into every supported locale when
// its source text changes, storing the result on the doc under `i18n`. Members
// read these via listMemberOpportunities/getMemberDashboard. Best-effort: any
// locale that fails to translate simply falls back to the English source.
export const translateAdminAsset = onDocumentWritten(
  "adminAssets/{id}",
  async (event) => {
    const afterSnap = event.data?.after;
    const after = afterSnap?.data();
    if (!afterSnap || !after) return; // Deleted — nothing to translate.

    const source: Record<string, string> = {};
    for (const field of TRANSLATABLE_ASSET_FIELDS) {
      source[field] = String(after[field] ?? "").trim();
    }

    const hash = assetTranslationHash(source);
    // Unchanged source → skip. This caps Translation API cost and stops the
    // write-back below from re-triggering this function endlessly.
    if (after.i18nHash === hash) return;

    const fields = TRANSLATABLE_ASSET_FIELDS.filter((f) => source[f] !== "");
    if (fields.length === 0) {
      await afterSnap.ref.set({i18nHash: hash}, {merge: true});
      return;
    }

    const i18n: Record<string, Record<string, string>> = {};
    for (const field of fields) i18n[field] = {};

    for (const locale of TRANSLATION_LOCALES) {
      try {
        const inputs = fields.map((field) => protectTerms(source[field]));
        const [translated] = await translate.translate(inputs, {
          from: "en",
          to: locale,
          format: "html",
        });
        const values = Array.isArray(translated) ? translated : [translated];
        fields.forEach((field, index) => {
          const value = unprotectTerms(String(values[index] ?? "")).trim();
          if (value) i18n[field][locale] = value;
        });
      } catch (error) {
        logger.warn("Asset translation failed", {
          assetId: event.params.id,
          locale,
          error: error instanceof Error ? error.message : String(error),
        });
      }
    }

    await afterSnap.ref.set(
      {i18n, i18nHash: hash, i18nUpdatedAt: FieldValue.serverTimestamp()},
      {merge: true},
    );
  },
);

function opportunityFromDoc(
  doc: FirebaseFirestore.DocumentSnapshot,
  enabledPaymentMethods: string[],
  locale: string,
): MemberOpportunity {
  const data = doc.data();
  if (!data) {
    throw new HttpsError("not-found", "Opportunity was not found.");
  }

  const asset = assetFromData(doc.id, data);
  // Pick the member-locale translation when present, else the source text.
  const i18n = (data.i18n ?? {}) as Record<string, Record<string, string>>;
  const tr = (field: string, fallback: string): string => {
    if (!locale || locale === "en") return fallback;
    const value = i18n[field]?.[locale];
    return typeof value === "string" && value.trim() !== "" ? value : fallback;
  };
  return {
    id: doc.id,
    assetClass: String(data.assetClass ?? data.category ?? data.type ?? "Real Estate"),
    riskLevel: asset.riskLevel,
    paymentMethods: readStringArrayOrDefault(
      data.paymentMethods,
      enabledPaymentMethods.length === 0 ? ["USDT"] : enabledPaymentMethods,
    ),
    title: tr("title", asset.title),
    location: tr("location", asset.location),
    minimumInvestment: asset.minimumInvestment,
    targetReturn: Number(data.targetReturn ?? asset.expectedAnnualYield ?? 11.8),
    fundedPercent: asset.fundedPercent,
    description: tr("description", asset.description),
    category: asset.category,
    assetType: tr("assetType", asset.assetType),
    images: asset.images,
    purchasePrice: asset.purchasePrice,
    fundingTarget: asset.fundingTarget,
    amountFunded: asset.amountFunded,
    pricePerShare: asset.pricePerShare,
    totalShares: asset.totalShares,
    availableShares: asset.availableShares,
    expectedAnnualYield: asset.expectedAnnualYield,
    projectedNetYield: asset.projectedNetYield,
    strategy: tr("strategy", asset.strategy),
    exitPeriod: asset.exitPeriod,
    documents: asset.documents,
    status: asset.status,
    regulationNote: asset.regulationNote,
    currentAssetValue: asset.currentAssetValue,
  };
}

function paymentOptionFromDoc(
  doc: FirebaseFirestore.QueryDocumentSnapshot,
): CryptoPaymentOption {
  const data = doc.data();
  return {
    id: doc.id,
    type: String(data.type ?? "crypto"),
    network: String(data.network ?? ""),
    assetSymbol: String(data.assetSymbol ?? ""),
    walletAddress: String(data.walletAddress ?? ""),
    qrCodeUrl: String(data.qrCodeUrl ?? ""),
    accountDetails: accountDetailsFromData(data.accountDetails),
    enabled: Boolean(data.enabled ?? true),
    minimumAmount: Number(data.minimumAmount ?? 0),
  };
}

function accountDetailsFromData(raw: unknown): PaymentAccountField[] {
  if (!Array.isArray(raw)) return [];
  return raw
    .map((entry) => {
      const row = (entry ?? {}) as Record<string, unknown>;
      return {
        label: String(row.label ?? "").trim(),
        value: String(row.value ?? "").trim(),
      };
    })
    .filter((row) => row.label !== "" || row.value !== "");
}

function depositRequestFromDoc(
  doc: FirebaseFirestore.QueryDocumentSnapshot,
) {
  const data = doc.data();
  return {
    id: doc.id,
    uid: String(data.uid ?? ""),
    opportunityTitle: String(data.opportunityTitle ?? ""),
    amountUsd: Number(data.amountUsd ?? 0),
    paymentNetwork: String(data.paymentNetwork ?? ""),
    paymentAsset: String(data.paymentAsset ?? ""),
    paymentWalletAddress: String(data.paymentWalletAddress ?? ""),
    paymentType: String(data.paymentType ?? "crypto"),
    paymentAccountDetails: accountDetailsFromData(data.paymentAccountDetails),
    transactionHash: String(data.transactionHash ?? ""),
    proofUrl: String(data.proofUrl ?? ""),
    status: String(data.status ?? "pending_payment"),
  };
}

function memberOrderFromDoc(doc: FirebaseFirestore.QueryDocumentSnapshot) {
  const data = doc.data();
  return {
    id: doc.id,
    opportunityId: String(data.opportunityId ?? ""),
    opportunityTitle: String(data.opportunityTitle ?? ""),
    amountUsd: Number(data.amountUsd ?? 0),
    paymentAsset: String(data.paymentAsset ?? ""),
    paymentNetwork: String(data.paymentNetwork ?? ""),
    status: String(data.status ?? "pending_payment"),
    updatedAt: readSerializableDate(data.updatedAt ?? data.createdAt),
    createdAt: readSerializableDate(data.createdAt),
  };
}

type DashboardHolding = {
  // Legacy keys preserved for existing clients.
  opportunityId: string;
  title: string;
  assetClass: string;
  brickShares: number;
  valueUsd: number;
  returnPercent: number;
  // Expanded MemberHolding keys.
  assetId: string;
  assetTitle: string;
  assetImageUrl: string;
  assetCategory: string;
  assetStrategy: string;
  assetStatus: string;
  amountInvested: number;
  sharesOwned: number;
  ownershipPercentage: number;
  currentValue: number;
  dividendsReceived: number;
  profitLoss: number;
  returnPercentage: number;
};

function holdingFromDoc(
  doc: FirebaseFirestore.QueryDocumentSnapshot,
): DashboardHolding {
  const data = doc.data();
  const amountInvested = Number(data.amountInvested ?? 0);
  const currentValue = Number(data.currentValue ?? amountInvested);
  const returnPercentage = Number(data.returnPercentage ?? 0);
  const assetCategory = String(data.assetCategory ?? "BrickShares");
  return {
    opportunityId: String(data.assetId ?? ""),
    title: String(data.assetTitle ?? ""),
    assetClass: assetCategory,
    brickShares: Number(data.sharesOwned ?? 0),
    valueUsd: currentValue,
    returnPercent: returnPercentage,
    assetId: String(data.assetId ?? ""),
    assetTitle: String(data.assetTitle ?? ""),
    assetImageUrl: String(data.assetImageUrl ?? ""),
    assetCategory,
    assetStrategy: String(data.assetStrategy ?? ""),
    assetStatus: String(data.assetStatus ?? "available"),
    amountInvested,
    sharesOwned: Number(data.sharesOwned ?? 0),
    ownershipPercentage: Number(data.ownershipPercentage ?? 0),
    currentValue,
    dividendsReceived: Number(data.dividendsReceived ?? 0),
    profitLoss: Number(data.profitLoss ?? 0),
    returnPercentage,
  };
}

function buildMemberHoldings(
  orders: ReturnType<typeof memberOrderFromDoc>[],
  assetsById: Map<string, MemberOpportunity>,
): DashboardHolding[] {
  const investedByOpportunity = new Map<string, number>();
  for (const order of orders) {
    investedByOpportunity.set(
      order.opportunityId,
      (investedByOpportunity.get(order.opportunityId) ?? 0) + order.amountUsd,
    );
  }

  return Array.from(investedByOpportunity.entries()).map(
    ([opportunityId, invested]) => {
      const asset = assetsById.get(opportunityId);
      const amountInvested = roundMoney(invested);
      const purchasePrice = asset?.purchasePrice ?? 0;
      const currentAssetValue = asset?.currentAssetValue ?? purchasePrice;
      const pricePerShare = asset?.pricePerShare ?? 0;
      const minimumInvestment = asset?.minimumInvestment ?? amountInvested;
      const sharesOwned = pricePerShare > 0 ?
        roundShares(amountInvested / pricePerShare) :
        minimumInvestment > 0 ?
          roundShares(amountInvested / minimumInvestment) :
          0;
      const figures = computeHoldingFigures({
        amountInvested,
        purchasePrice,
        currentAssetValue,
        dividendsReceived: 0,
      });
      const assetCategory = asset?.assetClass ?? "BrickShares";
      return {
        opportunityId,
        title: asset?.title ?? "",
        assetClass: assetCategory,
        brickShares: sharesOwned,
        valueUsd: figures.currentValue,
        returnPercent: figures.returnPercentage,
        assetId: opportunityId,
        assetTitle: asset?.title ?? "",
        assetImageUrl: asset?.images?.[0] ?? "",
        assetCategory,
        assetStrategy: asset?.strategy ?? "",
        assetStatus: asset?.status ?? "available",
        amountInvested,
        sharesOwned,
        ownershipPercentage: figures.ownershipPercentage,
        currentValue: figures.currentValue,
        dividendsReceived: 0,
        profitLoss: figures.profitLoss,
        returnPercentage: figures.returnPercentage,
      };
    },
  );
}

function buildMemberAllocation(
  holdings: ReturnType<typeof buildMemberHoldings>,
) {
  const total = holdings.reduce((sum, holding) => sum + holding.valueUsd, 0);
  if (total <= 0) return [];

  const values = new Map<string, number>();
  for (const holding of holdings) {
    values.set(
      holding.assetClass,
      (values.get(holding.assetClass) ?? 0) + holding.valueUsd,
    );
  }

  return Array.from(values.entries()).map(([label, value]) => ({
    label,
    percent: roundMoney(value / total),
  }));
}

function buildMemberChartValues(
  orders: ReturnType<typeof memberOrderFromDoc>[],
) {
  const labels = buildMemberChartLabels();
  const totals = labels.map(() => 0);
  for (const order of orders) {
    const date = order.createdAt ? new Date(order.createdAt) : null;
    if (!date || Number.isNaN(date.getTime())) continue;
    const label = date.toLocaleString("en-US", {month: "short"});
    const index = labels.indexOf(label);
    if (index >= 0) {
      totals[index] += order.amountUsd;
    }
  }

  let runningTotal = 0;
  return totals.map((value) => {
    runningTotal += value;
    return roundMoney(runningTotal);
  });
}

function buildMemberChartLabels() {
  const labels: string[] = [];
  const now = new Date();
  for (let offset = 5; offset >= 0; offset--) {
    labels.push(
      new Date(now.getFullYear(), now.getMonth() - offset, 1)
        .toLocaleString("en-US", {month: "short"}),
    );
  }
  return labels;
}

function memberActivityFromOrder(order: ReturnType<typeof memberOrderFromDoc>) {
  return {
    title: memberOrderStatusTitle(order.status),
    subtitle: order.opportunityTitle,
    value: order.status === "deposit_verified" ?
      formatUsd(order.amountUsd) :
      memberOrderStatusLabel(order.status),
    status: order.status,
  };
}

function memberOrderStatusTitle(status: string): string {
  switch (status) {
  case "deposit_verified":
    return "Deposit verified";
  case "proof_submitted":
    return "Proof submitted";
  case "deposit_rejected":
    return "Proof needs attention";
  default:
    return "Deposit request created";
  }
}

function memberOrderStatusLabel(status: string): string {
  switch (status) {
  case "proof_submitted":
    return "Under review";
  case "deposit_rejected":
    return "Rejected";
  case "pending_payment":
    return "Awaiting proof";
  default:
    return status.replace(/_/g, " ");
  }
}

function supportTicketFromDoc(
  doc: FirebaseFirestore.QueryDocumentSnapshot,
) {
  const data = doc.data();
  const messages = Array.isArray(data.messages) ? data.messages : [];
  const latest = messages.at(-1) as Record<string, unknown> | undefined;

  return {
    id: doc.id,
    uid: String(data.uid ?? ""),
    subject: String(data.subject ?? ""),
    status: String(data.status ?? "open"),
    messageCount: messages.length,
    latestMessage: String(latest?.body ?? ""),
    userEmail: String(data.userEmail ?? ""),
    userDisplayName: String(data.userDisplayName ?? ""),
    updatedAt: readSerializableDate(data.updatedAt),
  };
}

function adminNotificationFromDoc(
  doc: FirebaseFirestore.QueryDocumentSnapshot,
) {
  const data = doc.data();
  return {
    id: doc.id,
    type: String(data.type ?? ""),
    title: String(data.title ?? ""),
    body: String(data.body ?? ""),
    read: Boolean(data.read ?? false),
    createdAt: readSerializableDate(data.createdAt),
  };
}

function supportMessage(message: {
  senderUid: string;
  senderRole: "member" | "admin";
  body: string;
  createdAt: string;
}) {
  return {
    id: randomUUID(),
    ...message,
  };
}

async function runKycAutomation(input: {
  fullLegalName: string;
  dateOfBirth: string;
  documents: KycDocumentSet;
}): Promise<KycAutomationResult> {
  try {
    const [
      selfieFaceCount,
      idFaceCount,
      idText,
      addressProofUploaded,
    ] = await Promise.all([
      detectFaceCount(input.documents.selfie),
      detectFaceCount(input.documents.governmentId),
      detectText(input.documents.governmentId),
      storageFileExists(input.documents.addressProof.path),
    ]);
    const idNameMatched = textContainsName(idText, input.fullLegalName);
    const idDateOfBirthMatched = textContainsDateOfBirth(
      idText,
      input.dateOfBirth,
    );
    const checks = {
      selfieFaceDetected: selfieFaceCount > 0,
      selfieSingleFace: selfieFaceCount === 1,
      idTextDetected: idText.trim().length > 20,
      idNameMatched,
      idDateOfBirthMatched,
      idFaceDetected: idFaceCount > 0,
      addressProofUploaded,
    };
    const reasons = kycAutomationReasons(checks);
    const passed = Object.values(checks).filter(Boolean).length;
    return {
      status: reasons.length === 0 ? "approved" : "rejected",
      checks,
      confidence: roundMoney(passed / Object.values(checks).length),
      reasons,
    };
  } catch (error) {
    logger.warn("KYC automation could not complete", {error});
    return {
      status: "manual_review",
      checks: {
        selfieFaceDetected: false,
        selfieSingleFace: false,
        idTextDetected: false,
        idNameMatched: false,
        idDateOfBirthMatched: false,
        idFaceDetected: false,
        addressProofUploaded: false,
      },
      confidence: 0,
      reasons: [
        "Automatic KYC checks could not complete. Manual review is required.",
      ],
    };
  }
}

async function detectFaceCount(document: KycDocumentPayload): Promise<number> {
  if (!document.contentType.startsWith("image/")) {
    return 0;
  }
  const [buffer] = await storage.bucket().file(document.path).download();
  const [result] = await vision.faceDetection({image: {content: buffer}});
  return result.faceAnnotations?.length ?? 0;
}

async function detectText(document: KycDocumentPayload): Promise<string> {
  if (!document.contentType.startsWith("image/")) {
    return "";
  }
  const [buffer] = await storage.bucket().file(document.path).download();
  const [result] = await vision.textDetection({image: {content: buffer}});
  return result.fullTextAnnotation?.text ??
    result.textAnnotations?.[0]?.description ??
    "";
}

async function storageFileExists(path: string): Promise<boolean> {
  const [exists] = await storage.bucket().file(path).exists();
  return exists;
}

function textContainsName(text: string, fullLegalName: string): boolean {
  const normalizedText = normalizeIdentityText(text);
  const tokens = normalizeIdentityText(fullLegalName)
    .split(" ")
    .filter((token) => token.length >= 3);
  if (tokens.length < 2) return false;
  return tokens.every((token) => normalizedText.includes(token));
}

function textContainsDateOfBirth(text: string, dateOfBirth: string): boolean {
  const birthDate = new Date(dateOfBirth);
  if (Number.isNaN(birthDate.getTime())) return false;
  const year = String(birthDate.getUTCFullYear());
  const month = String(birthDate.getUTCMonth() + 1).padStart(2, "0");
  const day = String(birthDate.getUTCDate()).padStart(2, "0");
  const normalizedText = normalizeIdentityText(text);
  const compactText = normalizedText.replace(/\s/g, "");
  const variants = [
    `${year}-${month}-${day}`,
    `${day}-${month}-${year}`,
    `${day}/${month}/${year}`,
    `${month}/${day}/${year}`,
    `${day}${month}${year}`,
    `${year}${month}${day}`,
  ].map((value) => normalizeIdentityText(value).replace(/\s/g, ""));

  return variants.some((variant) => compactText.includes(variant)) ||
    normalizedText.includes(year);
}

function normalizeIdentityText(value: string): string {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function kycAutomationReasons(
  checks: KycAutomationResult["checks"],
): string[] {
  const reasons: string[] = [];
  if (!checks.selfieFaceDetected) {
    reasons.push("No face was detected in the selfie.");
  } else if (!checks.selfieSingleFace) {
    reasons.push("The selfie must contain exactly one face.");
  }
  if (!checks.idTextDetected) {
    reasons.push("Readable ID text was not detected.");
  }
  if (!checks.idNameMatched) {
    reasons.push("The legal name did not match the ID document text.");
  }
  if (!checks.idDateOfBirthMatched) {
    reasons.push("The date of birth did not match the ID document text.");
  }
  if (!checks.idFaceDetected) {
    reasons.push("No face was detected on the ID document image.");
  }
  if (!checks.addressProofUploaded) {
    reasons.push("Address proof could not be found in Storage.");
  }
  return reasons;
}

function readKycDocumentSet(data: Record<string, unknown>): KycDocumentSet {
  return {
    governmentId: readKycDocumentPayload(data.governmentId),
    selfie: readKycDocumentPayload(data.selfie),
    addressProof: readKycDocumentPayload(data.addressProof),
  };
}

function readKycDocumentPayload(data: unknown): KycDocumentPayload {
  const value = readObject(data);
  return {
    path: readString(value, "path"),
    downloadUrl: readString(value, "downloadUrl"),
    contentType: readString(value, "contentType"),
    originalName: readString(value, "originalName"),
  };
}

function validateKycDocumentOwnership(uid: string, documents: KycDocumentSet) {
  for (const document of Object.values(documents)) {
    if (!document.path.startsWith(`kyc/${uid}/`)) {
      throw new HttpsError(
        "permission-denied",
        "KYC documents must be uploaded under your account.",
      );
    }
    if (!/^(image\/.+|application\/pdf)$/.test(document.contentType)) {
      throw new HttpsError(
        "invalid-argument",
        "KYC documents must be images or PDFs.",
      );
    }
  }
}

function ensureFunctionsEmulator() {
  if (process.env.FUNCTIONS_EMULATOR !== "true") {
    throw new HttpsError(
      "failed-precondition",
      "Development email is only available in the Functions emulator.",
    );
  }
}

async function sendDevelopmentEmail(message: {
  to: string;
  subject: string;
  text: string;
  html: string;
}) {
  const transport = nodemailer.createTransport({
    host: process.env.MAILPIT_SMTP_HOST ?? "127.0.0.1",
    port: Number(process.env.MAILPIT_SMTP_PORT ?? 1025),
    secure: false,
  });

  await transport.sendMail({
    from: process.env.MAILPIT_FROM ?? devMailFrom,
    ...message,
  });
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function readUserPayload(
  data: unknown,
  options: {passwordOptional?: boolean} = {},
): UserPayload {
  const value = readObject(data);
  const payload: UserPayload = {
    email: readString(value, "email"),
    displayName: readOptionalString(value, "displayName"),
    disabled: readOptionalBoolean(value, "disabled"),
    admin: readOptionalBoolean(value, "admin"),
    emailVerified: readOptionalBoolean(value, "emailVerified"),
    phoneNumber: readOptionalString(value, "phoneNumber"),
  };
  const password = readOptionalString(value, "password");

  if (!options.passwordOptional || password) {
    payload.password = password;
  }

  return payload;
}

// Firebase Auth requires phone numbers in E.164 format (e.g. +14155552671).
// Returns the validated number, `null` to clear an existing number, or
// `undefined` to leave the value untouched.
function normalizePhoneNumber(
  phoneNumber: string | undefined,
  {allowClear}: {allowClear: boolean},
): string | null | undefined {
  if (phoneNumber === undefined) {
    return undefined;
  }
  const trimmed = phoneNumber.trim();
  if (!trimmed) {
    return allowClear ? null : undefined;
  }
  if (!/^\+[1-9]\d{6,14}$/.test(trimmed)) {
    throw new HttpsError(
      "invalid-argument",
      "Phone number must be in E.164 format, e.g. +14155552671.",
    );
  }
  return trimmed;
}

function readAssetPayload(data: unknown): Omit<AdminAsset, "id"> {
  const value = readObject(data);
  const type = readString(value, "type");
  const purchasePrice = readNumberOrDefault(value, "purchasePrice", 0);
  const totalShares = readNumberOrDefault(value, "totalShares", 0);

  return {
    title: readString(value, "title"),
    location: readString(value, "location"),
    type,
    fundedPercent: readNumberOrDefault(value, "fundedPercent", 0),
    reviewStatus: readString(value, "reviewStatus"),
    publishedStatus: readString(value, "publishedStatus"),
    description: readOptionalString(value, "description") ?? "",
    category: readOptionalString(value, "category") ?? "realEstate",
    assetType: readOptionalString(value, "assetType") ?? type,
    images: readStringArrayOrDefault(value.images, []),
    purchasePrice,
    fundingTarget: readNumberOrDefault(value, "fundingTarget", 0),
    amountFunded: readNumberOrDefault(value, "amountFunded", 0),
    pricePerShare: readNumberOrDefault(value, "pricePerShare", 0),
    totalShares,
    availableShares: readNumberOrDefault(value, "availableShares", totalShares),
    expectedAnnualYield: readNumberOrDefault(value, "expectedAnnualYield", 0),
    projectedNetYield: readNumberOrDefault(value, "projectedNetYield", 0),
    strategy: readOptionalString(value, "strategy") ?? "capitalGrowth",
    riskLevel: readOptionalString(value, "riskLevel") ?? "balanced",
    exitPeriod: readOptionalString(value, "exitPeriod") ?? "",
    documents: readStringArrayOrDefault(value.documents, []),
    status: readOptionalString(value, "status") ?? "available",
    regulationNote: readOptionalString(value, "regulationNote") ?? "",
    currentAssetValue: readNumberOrDefault(
      value,
      "currentAssetValue",
      purchasePrice,
    ),
    minimumInvestment: readNumberOrDefault(value, "minimumInvestment", 50),
  };
}

function readPaymentOptionPayload(
  data: unknown,
): Omit<CryptoPaymentOption, "id"> {
  const value = readObject(data);
  return {
    type: readOptionalString(value, "type") ?? "crypto",
    // network/walletAddress are crypto-only; non-crypto methods leave them blank
    // and describe themselves through accountDetails instead.
    network: readOptionalString(value, "network") ?? "",
    assetSymbol: readString(value, "assetSymbol"),
    walletAddress: readOptionalString(value, "walletAddress") ?? "",
    qrCodeUrl: readOptionalString(value, "qrCodeUrl") ?? "",
    accountDetails: readAccountDetails(value),
    enabled: readBoolean(value, "enabled"),
    minimumAmount: readNumber(value, "minimumAmount"),
  };
}

function readAccountDetails(data: Record<string, unknown>): PaymentAccountField[] {
  const raw = data.accountDetails;
  if (raw === undefined || raw === null) return [];
  if (!Array.isArray(raw)) {
    throw new HttpsError("invalid-argument", "accountDetails must be a list.");
  }
  return raw
    .map((entry) => {
      const row = readObject(entry);
      return {
        label: String(row.label ?? "").trim(),
        value: String(row.value ?? "").trim(),
      };
    })
    .filter((row) => row.label !== "" || row.value !== "");
}

async function loadWithdrawalPolicy(): Promise<WithdrawalPolicy> {
  const snapshot = await withdrawalPolicyDoc.get();
  return withdrawalPolicyFromData(snapshot.data());
}

function withdrawalPolicyFromData(
  data: FirebaseFirestore.DocumentData | undefined,
): WithdrawalPolicy {
  const defaults = defaultWithdrawalPolicy();
  if (!data) return defaults;

  return {
    minimumAmountUsd: Number(
      data.minimumAmountUsd ?? defaults.minimumAmountUsd,
    ),
    flatFeeUsd: Number(data.flatFeeUsd ?? defaults.flatFeeUsd),
    percentageFee: Number(data.percentageFee ?? defaults.percentageFee),
    requiresDestinationWalletVerification:
      Boolean(
        data.requiresDestinationWalletVerification ??
          defaults.requiresDestinationWalletVerification,
      ),
    requiredApprovals: Number(
      data.requiredApprovals ?? defaults.requiredApprovals,
    ),
    processingTime: String(data.processingTime ?? defaults.processingTime),
    enabled: Boolean(data.enabled ?? defaults.enabled),
    notes: String(data.notes ?? defaults.notes),
  };
}

function defaultWithdrawalPolicy(): WithdrawalPolicy {
  return {
    minimumAmountUsd: 25,
    flatFeeUsd: 0,
    percentageFee: 0,
    requiresDestinationWalletVerification: true,
    requiredApprovals: 1,
    processingTime: "1-2 business days",
    enabled: true,
    notes: "Admin verification is required before release.",
  };
}

function readWithdrawalPolicy(data: unknown): WithdrawalPolicy {
  const value = readObject(data);
  const policy: WithdrawalPolicy = {
    minimumAmountUsd: readPositiveNumber(value, "minimumAmountUsd"),
    flatFeeUsd: readNonNegativeNumber(value, "flatFeeUsd"),
    percentageFee: readNonNegativeNumber(value, "percentageFee"),
    requiresDestinationWalletVerification: readBoolean(
      value,
      "requiresDestinationWalletVerification",
    ),
    requiredApprovals: readPositiveInteger(value, "requiredApprovals"),
    processingTime: readString(value, "processingTime"),
    enabled: readBoolean(value, "enabled"),
    notes: readOptionalString(value, "notes") ?? "",
  };

  if (policy.percentageFee > 25) {
    throw new HttpsError(
      "invalid-argument",
      "percentageFee must be 25 or lower.",
    );
  }
  if (policy.requiredApprovals > 3) {
    throw new HttpsError(
      "invalid-argument",
      "requiredApprovals must be 3 or lower.",
    );
  }

  return policy;
}

type ReferralAccount = {
  referralCode: string;
  referredBy: string | null;
  referredByCode: string | null;
  referralCount: number;
  totalEarnedUsd: number;
};

async function loadReferralPolicy(): Promise<ReferralPolicy> {
  const snapshot = await referralPolicyDoc.get();
  return referralPolicyFromData(snapshot.data());
}

function referralPolicyFromData(
  data: FirebaseFirestore.DocumentData | undefined,
): ReferralPolicy {
  const defaults = defaultReferralPolicy();
  if (!data) return defaults;
  return {
    enabled: Boolean(data.enabled ?? defaults.enabled),
    commissionPercent: Number(
      data.commissionPercent ?? defaults.commissionPercent,
    ),
    firstInvestmentOnly: Boolean(
      data.firstInvestmentOnly ?? defaults.firstInvestmentOnly,
    ),
  };
}

function defaultReferralPolicy(): ReferralPolicy {
  return {enabled: true, commissionPercent: 5, firstInvestmentOnly: false};
}

function readReferralPolicy(data: unknown): ReferralPolicy {
  const value = readObject(data);
  const policy: ReferralPolicy = {
    enabled: readBoolean(value, "enabled"),
    commissionPercent: readNonNegativeNumber(value, "commissionPercent"),
    firstInvestmentOnly: readBoolean(value, "firstInvestmentOnly"),
  };
  if (policy.commissionPercent > 50) {
    throw new HttpsError(
      "invalid-argument",
      "commissionPercent must be 50 or lower.",
    );
  }
  return policy;
}

// 7-char code from uppercased UUID hex. Ambiguity is acceptable because every
// candidate is verified unique against referralCodes before use.
function generateReferralCode(): string {
  return randomUUID().replace(/-/g, "").slice(0, 7).toUpperCase();
}

// Loads (or lazily creates) the caller's referral account. New accounts get a
// unique share code reserved in referralCodes via a transactional create so two
// members can never collide on the same code.
async function ensureReferralAccount(uid: string): Promise<ReferralAccount> {
  const ref = referralAccountsCollection.doc(uid);
  const existing = (await ref.get()).data();
  if (existing?.referralCode) {
    return {
      referralCode: String(existing.referralCode),
      referredBy: (existing.referredBy as string | undefined) ?? null,
      referredByCode: (existing.referredByCode as string | undefined) ?? null,
      referralCount: Number(existing.referralCount ?? 0),
      totalEarnedUsd: Number(existing.totalEarnedUsd ?? 0),
    };
  }

  let code = "";
  for (let attempt = 0; attempt < 5 && !code; attempt++) {
    const candidate = generateReferralCode();
    const codeRef = referralCodesCollection.doc(candidate);
    const reserved = await db.runTransaction(async (tx) => {
      if ((await tx.get(codeRef)).exists) return false;
      tx.set(codeRef, {uid, createdAt: FieldValue.serverTimestamp()});
      return true;
    });
    if (reserved) code = candidate;
  }
  if (!code) {
    throw new HttpsError("internal", "Could not allocate a referral code.");
  }

  await ref.set(
    {
      uid,
      referralCode: code,
      referredBy: existing?.referredBy ?? null,
      referredByCode: existing?.referredByCode ?? null,
      referralCount: Number(existing?.referralCount ?? 0),
      totalEarnedUsd: Number(existing?.totalEarnedUsd ?? 0),
      createdAt: existing?.createdAt ?? FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  return {
    referralCode: code,
    referredBy: (existing?.referredBy as string | undefined) ?? null,
    referredByCode: (existing?.referredByCode as string | undefined) ?? null,
    referralCount: Number(existing?.referralCount ?? 0),
    totalEarnedUsd: Number(existing?.totalEarnedUsd ?? 0),
  };
}

// Credits the referrer of `refereeUid` a percentage of a verified investment.
// Idempotent per order (the commission doc id is the orderId), respects the
// configured rate / enabled / first-investment-only policy, and pays into the
// referrer's wallet through the shared ledger helper.
async function accrueReferralCommission(input: {
  refereeUid: string;
  orderId: string;
  opportunityId: string;
  amountUsd: number;
}): Promise<void> {
  const policy = await loadReferralPolicy();
  if (!policy.enabled || policy.commissionPercent <= 0) return;

  const refereeAccount = (
    await referralAccountsCollection.doc(input.refereeUid).get()
  ).data();
  const referrerUid = refereeAccount?.referredBy as string | undefined;
  if (!referrerUid) return;

  if (policy.firstInvestmentOnly) {
    const prior = await referralCommissionsCollection
      .where("refereeUid", "==", input.refereeUid)
      .limit(1)
      .get();
    if (!prior.empty) return;
  }

  const commissionUsd = roundMoney(
    (input.amountUsd * policy.commissionPercent) / 100,
  );
  if (commissionUsd <= 0) return;

  const commissionRef = referralCommissionsCollection.doc(input.orderId);
  const created = await db.runTransaction(async (tx) => {
    if ((await tx.get(commissionRef)).exists) return false; // idempotent
    tx.set(commissionRef, {
      id: input.orderId,
      referrerUid,
      refereeUid: input.refereeUid,
      orderId: input.orderId,
      opportunityId: input.opportunityId,
      investmentAmountUsd: roundMoney(input.amountUsd),
      rate: policy.commissionPercent,
      commissionUsd,
      createdAt: FieldValue.serverTimestamp(),
    });
    tx.set(
      referralAccountsCollection.doc(referrerUid),
      {
        totalEarnedUsd: FieldValue.increment(commissionUsd),
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );
    return true;
  });
  if (!created) return;

  await applyWalletAdjustment({
    uid: referrerUid,
    amountUsd: commissionUsd,
    direction: "credit",
    reason:
      `Referral commission (${policy.commissionPercent}% of ` +
      `${formatUsd(input.amountUsd)} investment).`,
    createdBy: "system:referral",
  });

  await notifyMember(referrerUid, {
    type: "referral_commission_earned",
    title: "Referral commission earned",
    body: `You earned ${formatUsd(commissionUsd)} from a referral's investment.`,
    data: {orderId: input.orderId, refereeUid: input.refereeUid},
  });
}

function referralCommissionFromDoc(
  doc: FirebaseFirestore.QueryDocumentSnapshot,
) {
  const data = doc.data();
  return {
    id: doc.id,
    refereeUid: String(data.refereeUid ?? ""),
    opportunityId: String(data.opportunityId ?? ""),
    investmentAmountUsd: Number(data.investmentAmountUsd ?? 0),
    rate: Number(data.rate ?? 0),
    commissionUsd: Number(data.commissionUsd ?? 0),
    createdAt: readSerializableDate(data.createdAt),
  };
}

async function notifyAdmins(notification: {
  type: string;
  title: string;
  body: string;
  data: Record<string, string>;
}) {
  const [admins, tokenSnapshot] = await Promise.all([
    listAdminUsers(),
    notificationTokensCollection.where("admin", "==", true).get(),
  ]);

  const notificationData = {
    ...notification,
    createdAt: FieldValue.serverTimestamp(),
    read: false,
  };
  await adminNotificationsCollection.add(notificationData);

  await Promise.all(
    admins
      .filter((admin) => admin.email)
      .map((admin) =>
        sendOperationalEmail({
          to: admin.email!,
          subject: `BrickClub: ${notification.title}`,
          text: `${notification.body}\n\nOpen the admin dashboard to review.`,
          html: [
            `<p>${escapeHtml(notification.body)}</p>`,
            "<p>Open the admin dashboard to review.</p>",
          ].join(""),
        }),
      ),
  );

  await sendPushToTokens(
    tokenSnapshot.docs.map((doc) => doc.id),
    notification,
  );
}

async function notifyMember(uid: string, notification: {
  type: string;
  title: string;
  body: string;
  data: Record<string, string>;
}) {
  const tokenSnapshot = await notificationTokensCollection
    .where("uid", "==", uid)
    .get();

  await db.collection("memberNotifications").add({
    uid,
    ...notification,
    createdAt: FieldValue.serverTimestamp(),
    read: false,
  });

  const user = await auth.getUser(uid);
  if (user.email) {
    await sendOperationalEmail({
      to: user.email,
      subject: `BrickClub: ${notification.title}`,
      text: notification.body,
      html: `<p>${escapeHtml(notification.body)}</p>`,
    });
  }

  await sendPushToTokens(
    tokenSnapshot.docs.map((doc) => doc.id),
    notification,
  );
}

// Best-effort multicast push send. Failures never propagate to the caller, and
// tokens that FCM reports as unregistered/invalid are pruned from Firestore so
// dead tokens do not accumulate.
async function sendPushToTokens(
  tokens: string[],
  notification: {title: string; body: string; data: Record<string, string>},
) {
  if (tokens.length === 0) {
    return;
  }

  let response;
  try {
    response = await messaging.sendEachForMulticast({
      tokens,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: notification.data,
    });
  } catch (error) {
    logger.error("Failed to send push notifications", {error});
    return;
  }

  const staleTokens: string[] = [];
  response.responses.forEach((result, index) => {
    if (result.success) {
      return;
    }
    const code = result.error?.code;
    logger.warn("Push delivery failed", {token: tokens[index], code});
    if (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token"
    ) {
      staleTokens.push(tokens[index]);
    }
  });

  if (staleTokens.length > 0) {
    await Promise.all(
      staleTokens.map((token) =>
        notificationTokensCollection
          .doc(token)
          .delete()
          .catch(() => undefined),
      ),
    );
    logger.info("Pruned stale notification tokens", {
      count: staleTokens.length,
    });
  }
}

async function listAdminUsers(): Promise<UserRecord[]> {
  const result = await auth.listUsers(1000);
  return result.users.filter((user) => user.customClaims?.admin === true);
}

// Operational emails are best-effort: a misconfigured or unreachable mail
// server must never fail the member/admin action that triggered it (creating a
// deposit, submitting proof, replying to support, etc.). Failures are logged
// and swallowed.
async function sendOperationalEmail(message: {
  to: string;
  subject: string;
  text: string;
  html: string;
}) {
  const transport = buildEmailTransport();
  if (!transport) {
    logger.warn("Operational email skipped: SMTP is not configured", {
      to: message.to,
      subject: message.subject,
    });
    return;
  }

  try {
    await transport.sendMail({
      from: isFunctionsEmulator ?
        (process.env.MAILPIT_FROM ?? devMailFrom) :
        smtpFrom.value(),
      ...message,
    });
  } catch (error) {
    logger.error("Failed to send operational email", {
      to: message.to,
      subject: message.subject,
      error,
    });
  }
}

// Build the mail transport for the current environment. In the emulator it
// targets Mailpit; in production it uses the configured SMTP server. Returns
// null when production SMTP is not configured so callers skip rather than
// dialing localhost (which would always fail in Cloud Functions).
function buildEmailTransport(): nodemailer.Transporter | null {
  if (isFunctionsEmulator) {
    return nodemailer.createTransport({
      host: process.env.MAILPIT_SMTP_HOST ?? "127.0.0.1",
      port: Number(process.env.MAILPIT_SMTP_PORT ?? 1025),
      secure: false,
    });
  }

  const host = smtpHost.value().trim();
  if (!host) {
    return null;
  }

  const user = smtpUser.value().trim();
  const pass = smtpPass.value().trim();
  return nodemailer.createTransport({
    host,
    port: Number(smtpPort.value() || 587),
    secure: smtpSecure.value() === "true",
    auth: user && pass ? {user, pass} : undefined,
  });
}

function readObject(data: unknown): Record<string, unknown> {
  if (!data || typeof data !== "object" || Array.isArray(data)) {
    throw new HttpsError("invalid-argument", "Expected an object payload.");
  }

  return data as Record<string, unknown>;
}

function readString(data: unknown, key: string): string {
  const value = readObject(data)[key];
  if (typeof value !== "string" || value.trim() === "") {
    throw new HttpsError("invalid-argument", `${key} is required.`);
  }

  return value.trim();
}

function readDateString(data: unknown, key: string): string {
  const value = readString(data, key);
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    throw new HttpsError("invalid-argument", `${key} must be a valid date.`);
  }

  return date.toISOString();
}

function readEmail(data: unknown, key: string): string {
  const value = readString(data, key).toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
    throw new HttpsError("invalid-argument", `${key} must be an email.`);
  }

  return value;
}

function readOptionalString(
  data: unknown,
  key: string,
): string | undefined {
  const value = readObject(data)[key];
  if (value === undefined || value === null || value === "") {
    return undefined;
  }

  if (typeof value !== "string") {
    throw new HttpsError("invalid-argument", `${key} must be a string.`);
  }

  return value.trim();
}

function readBoolean(data: unknown, key: string): boolean {
  const value = readObject(data)[key];
  if (typeof value !== "boolean") {
    throw new HttpsError("invalid-argument", `${key} must be a boolean.`);
  }

  return value;
}

function readOptionalBoolean(
  data: unknown,
  key: string,
): boolean | undefined {
  const value = readObject(data)[key];
  if (value === undefined || value === null) {
    return undefined;
  }

  if (typeof value !== "boolean") {
    throw new HttpsError("invalid-argument", `${key} must be a boolean.`);
  }

  return value;
}

function readNumber(data: unknown, key: string): number {
  const value = readObject(data)[key];
  if (typeof value !== "number" || Number.isNaN(value)) {
    throw new HttpsError("invalid-argument", `${key} must be a number.`);
  }

  return value;
}

function readNumberOrDefault(
  data: unknown,
  key: string,
  fallback: number,
): number {
  const value = readObject(data)[key];
  if (value === undefined || value === null || value === "") {
    return fallback;
  }
  if (typeof value !== "number" || Number.isNaN(value)) {
    throw new HttpsError("invalid-argument", `${key} must be a number.`);
  }
  return value;
}

function readPositiveNumber(data: unknown, key: string): number {
  const value = readNumber(data, key);
  if (value <= 0) {
    throw new HttpsError("invalid-argument", `${key} must be greater than 0.`);
  }

  return value;
}

function readNonNegativeNumber(data: unknown, key: string): number {
  const value = readNumber(data, key);
  if (value < 0) {
    throw new HttpsError("invalid-argument", `${key} must be 0 or greater.`);
  }

  return value;
}

function readPositiveInteger(data: unknown, key: string): number {
  const value = readPositiveNumber(data, key);
  if (!Number.isInteger(value)) {
    throw new HttpsError("invalid-argument", `${key} must be a whole number.`);
  }

  return value;
}

function readStringArrayOrDefault(
  value: unknown,
  fallback: string[],
): string[] {
  if (!Array.isArray(value)) return fallback;
  const strings = value
    .filter((item): item is string => typeof item === "string")
    .map((item) => item.trim())
    .filter((item) => item.length > 0);
  return strings.length === 0 ? fallback : strings;
}

function readSerializableDate(value: unknown): string {
  if (
    value &&
    typeof value === "object" &&
    "toDate" in value &&
    typeof value.toDate === "function"
  ) {
    return value.toDate().toISOString();
  }
  if (value instanceof Date) return value.toISOString();
  if (typeof value === "string") return value;
  return "";
}

function roundMoney(value: number): number {
  return Math.round(value * 100) / 100;
}

function roundShares(value: number): number {
  return Math.round(value * 10000) / 10000;
}

// Shared profit/loss math so holdings computed at approval and at valuation
// time use identical formulas. Every division guards against zero.
function computeHoldingFigures(input: {
  amountInvested: number;
  purchasePrice: number;
  currentAssetValue: number;
  dividendsReceived: number;
}): {
  ownershipPercentage: number;
  currentValue: number;
  profitLoss: number;
  returnPercentage: number;
} {
  const ownershipPercentage = input.purchasePrice > 0 ?
    roundMoney((input.amountInvested / input.purchasePrice) * 100) :
    0;
  // When no asset valuation exists yet, current value tracks invested capital.
  const currentValue = input.currentAssetValue > 0 ?
    roundMoney(input.currentAssetValue * (ownershipPercentage / 100)) :
    roundMoney(input.amountInvested);
  const profitLoss = roundMoney(
    currentValue + input.dividendsReceived - input.amountInvested,
  );
  const returnPercentage = input.amountInvested > 0 ?
    roundMoney((profitLoss / input.amountInvested) * 100) :
    0;
  return {ownershipPercentage, currentValue, profitLoss, returnPercentage};
}

function formatUsd(value: number): string {
  return `$${Math.round(value).toLocaleString("en-US")}`;
}

// Apply a credit or debit to a member's cash wallet inside a transaction so the
// balance and the audit ledger row stay consistent. Debits that would push the
// balance below zero are rejected. Returns the new balance and the ledger row
// id; the caller notifies the member after the transaction commits.
async function applyWalletAdjustment(input: {
  uid: string;
  amountUsd: number;
  direction: "credit" | "debit";
  reason: string;
  createdBy: string;
}): Promise<{balanceUsd: number; transactionId: string}> {
  const walletRef = memberWalletsCollection.doc(input.uid);
  const txRef = walletTransactionsCollection.doc();
  const activityRef = memberActivitiesCollection.doc();
  const amountUsd = roundMoney(input.amountUsd);

  const balanceUsd = await db.runTransaction(async (tx) => {
    const walletSnapshot = await tx.get(walletRef);
    const existing = walletSnapshot.data();
    const priorBalance = Number(existing?.balanceUsd ?? 0);
    const delta = input.direction === "credit" ? amountUsd : -amountUsd;
    const newBalance = roundMoney(priorBalance + delta);
    if (newBalance < 0) {
      throw new HttpsError(
        "failed-precondition",
        "Adjustment would make the wallet balance negative.",
      );
    }

    tx.set(
      walletRef,
      {
        uid: input.uid,
        balanceUsd: newBalance,
        createdAt: existing?.createdAt ?? FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );

    tx.set(txRef, {
      id: txRef.id,
      uid: input.uid,
      type: input.direction,
      amountUsd,
      balanceAfter: newBalance,
      reason: input.reason,
      createdBy: input.createdBy,
      createdAt: FieldValue.serverTimestamp(),
    });

    tx.set(activityRef, {
      id: activityRef.id,
      uid: input.uid,
      type: input.direction === "credit" ? "wallet_credit" : "wallet_debit",
      title: input.direction === "credit" ?
        "Wallet credited" :
        "Wallet debited",
      subtitle: input.reason,
      value: `${input.direction === "credit" ? "+" : "-"}${formatUsd(amountUsd)}`,
      status: "wallet_adjusted",
      amountUsd,
      createdAt: FieldValue.serverTimestamp(),
    });

    return newBalance;
  });

  return {balanceUsd, transactionId: txRef.id};
}

function walletTransactionFromDoc(
  doc: FirebaseFirestore.QueryDocumentSnapshot,
) {
  const data = doc.data();
  return {
    id: doc.id,
    type: String(data.type ?? ""),
    amountUsd: Number(data.amountUsd ?? 0),
    balanceAfter: Number(data.balanceAfter ?? 0),
    reason: String(data.reason ?? ""),
    createdAt: readSerializableDate(data.createdAt),
  };
}

function isLikelyWalletAddress(value: string): boolean {
  const trimmed = value.trim();
  return /^(0x[a-fA-F0-9]{40}|T[A-Za-z0-9]{25,40}|bc1[A-Za-z0-9]{25,90}|[13][A-Za-z0-9]{25,40})$/.test(trimmed);
}
