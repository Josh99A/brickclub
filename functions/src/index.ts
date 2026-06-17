import {randomUUID} from "crypto";
import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {initializeApp} from "firebase-admin/app";
import {getAuth, UserRecord} from "firebase-admin/auth";
import {FieldValue, getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {getStorage} from "firebase-admin/storage";
import {ImageAnnotatorClient} from "@google-cloud/vision";
import * as nodemailer from "nodemailer";

initializeApp();

const db = getFirestore();
const auth = getAuth();
const messaging = getMessaging();
const storage = getStorage();
const vision = new ImageAnnotatorClient();

type AdminAsset = {
  id: string;
  title: string;
  location: string;
  type: string;
  fundedPercent: number;
  reviewStatus: string;
  publishedStatus: string;
};

type CryptoPaymentOption = {
  id: string;
  network: string;
  assetSymbol: string;
  walletAddress: string;
  qrCodeUrl: string;
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
};

type WithdrawalPolicy = {
  minimumAmountUgx: number;
  flatFeeUgx: number;
  percentageFee: number;
  requiresDestinationWalletVerification: boolean;
  requiredApprovals: number;
  processingTime: string;
  enabled: boolean;
  notes: string;
};

type UserPayload = {
  email: string;
  password?: string;
  displayName?: string;
  disabled?: boolean;
  admin?: boolean;
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
const kycProfilesCollection = db.collection("kycProfiles");
const notificationTokensCollection = db.collection("notificationTokens");
const adminNotificationsCollection = db.collection("adminNotifications");
const withdrawalRequestsCollection = db.collection("withdrawalRequests");
const supportTicketsCollection = db.collection("supportTickets");
const withdrawalPolicyDoc = db.collection("platformSettings").doc("withdrawals");
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
  const [usersResult, assetsSnapshot, paymentOptionsSnapshot] =
    await Promise.all([
      auth.listUsers(1000),
      assetsCollection.get(),
      paymentOptionsCollection.get(),
    ]);
  const depositRequestsSnapshot = await purchaseOrdersCollection
    .where("status", "in", ["proof_submitted", "deposit_verified", "deposit_rejected"])
    .get();
  const supportTicketsSnapshot = await supportTicketsCollection
    .orderBy("updatedAt", "desc")
    .limit(100)
    .get();
  const withdrawalPolicy = await loadWithdrawalPolicy();

  return {
    users: usersResult.users.map(userToJson),
    assets: assetsSnapshot.docs.map(assetFromDoc),
    cryptoPaymentOptions: paymentOptionsSnapshot.docs.map(paymentOptionFromDoc),
    depositRequests: depositRequestsSnapshot.docs.map(depositRequestFromDoc),
    supportTickets: supportTicketsSnapshot.docs.map(supportTicketFromDoc),
    withdrawalPolicy,
  };
});

export const listMemberOpportunities = onMemberCall(async () => {
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
      opportunityFromDoc(doc, paymentMethods),
    ),
  };
});

export const getMemberDashboard = onMemberCall(async (request) => {
  const uid = request.auth!.uid;
  const [ordersSnapshot, assetsSnapshot, paymentOptionsSnapshot] =
    await Promise.all([
      purchaseOrdersCollection.where("uid", "==", uid).get(),
      assetsCollection.get(),
      paymentOptionsCollection.where("enabled", "==", true).get(),
    ]);

  const assetsById = new Map(
    assetsSnapshot.docs.map((doc) => [doc.id, opportunityFromDoc(doc, [])]),
  );
  const orders = ordersSnapshot.docs
    .map((doc) => memberOrderFromDoc(doc))
    .sort((a, b) => b.updatedAt.localeCompare(a.updatedAt));
  const verifiedOrders = orders.filter(
    (order) => order.status === "deposit_verified",
  );
  const holdings = buildMemberHoldings(verifiedOrders, assetsById);
  const portfolioValueUgx = roundMoney(
    holdings.reduce((total, holding) => total + holding.valueUgx, 0),
  );
  const yearReturnPercent = portfolioValueUgx === 0 ? 0 : roundMoney(
    holdings.reduce(
      (total, holding) => total + holding.returnPercent * holding.valueUgx,
      0,
    ) / portfolioValueUgx,
  );

  return {
    portfolioValueUgx,
    walletBalanceUgx: 0,
    yearReturnPercent,
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
  const amountUgx = readPositiveNumber(data, "amountUgx");
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

  const asset = opportunityFromDoc(
    assetSnapshot,
    [paymentAsset],
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
  if (amountUgx < asset.minimumInvestment) {
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
  if (amountUgx < paymentOption.minimumAmount) {
    throw new HttpsError(
      "invalid-argument",
      "Amount is below the payment option minimum.",
    );
  }

  const id = randomUUID();
  const quoteAmount = roundMoney(amountUgx / 3700);
  const networkFee = paymentAsset === "BTC" ? 0.0001 : 1;
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

  const order = {
    id,
    uid,
    opportunityId,
    opportunityTitle: asset.title,
    amountUgx,
    paymentNetwork: paymentOption.network,
    paymentAsset,
    quoteAmount,
    networkFee,
    paymentWalletAddress: paymentOption.walletAddress,
    paymentQrCodeUrl: paymentOption.qrCodeUrl,
    status: "pending_payment",
    expiresAt: expiresAt.toISOString(),
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };

  await purchaseOrdersCollection.doc(id).set(order);

  await notifyAdmins({
    type: "deposit_request_created",
    title: "New deposit request",
    body: `${asset.title} deposit request created for ${amountUgx} UGX.`,
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

export const verifyDepositProof = onAdminCall(async (data) => {
  const orderId = readString(data, "orderId");
  const orderRef = purchaseOrdersCollection.doc(orderId);
  const orderSnapshot = await orderRef.get();
  const order = orderSnapshot.data();
  if (!orderSnapshot.exists || !order) {
    throw new HttpsError("not-found", "Deposit request was not found.");
  }
  if (order.status !== "proof_submitted") {
    throw new HttpsError(
      "failed-precondition",
      "Only submitted deposit proofs can be verified.",
    );
  }

  await orderRef.set(
    {
      status: "deposit_verified",
      verifiedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  await notifyMember(String(order.uid), {
    type: "deposit_verified",
    title: "Deposit verified",
    body: "Your crypto deposit proof has been verified.",
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

export const createWithdrawalRequest = onMemberCall(async (request) => {
  const data = readObject(request.data);
  const amountUgx = readPositiveNumber(data, "amountUgx");
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
  if (amountUgx < policy.minimumAmountUgx) {
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
  const feeUgx = roundMoney(
    policy.flatFeeUgx + (amountUgx * policy.percentageFee / 100),
  );

  const requestData = {
    id,
    uid,
    amountUgx,
    feeUgx,
    netAmountUgx: roundMoney(amountUgx - feeUgx),
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
    body: `${amountUgx} UGX ${assetSymbol} withdrawal request submitted.`,
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

  const user = await auth.createUser({
    email: payload.email,
    password: payload.password,
    displayName: payload.displayName,
    disabled: payload.disabled ?? false,
  });

  if (payload.admin) {
    await auth.setCustomUserClaims(user.uid, {admin: true});
  }

  return userToJson(await auth.getUser(user.uid));
});

export const updateAdminUser = onAdminCall(async (data) => {
  const uid = readString(data, "uid");
  const payload = readUserPayload(data, {passwordOptional: true});

  await auth.updateUser(uid, {
    email: payload.email,
    password: payload.password,
    displayName: payload.displayName,
    disabled: payload.disabled,
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
  const status = approved ?
    "approved" :
    automation.status === "approved" ?
      "manual_review" :
      automation.status;
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
      reviewedAt: status === "manual_review" ?
        FieldValue.delete() :
        FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  if (status === "manual_review") {
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
  handler: (data: unknown) => Promise<T>,
) {
  return onCall(async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication is required.");
    }

    if (request.auth.token.admin !== true) {
      throw new HttpsError("permission-denied", "Admin access is required.");
    }

    return handler(request.data);
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
  const data = doc.data();
  return {
    id: doc.id,
    title: String(data.title ?? ""),
    location: String(data.location ?? ""),
    type: String(data.type ?? ""),
    fundedPercent: Number(data.fundedPercent ?? 0),
    reviewStatus: String(data.reviewStatus ?? "Pending"),
    publishedStatus: String(data.publishedStatus ?? "Draft"),
  };
}

function opportunityFromDoc(
  doc: FirebaseFirestore.DocumentSnapshot,
  enabledPaymentMethods: string[],
): MemberOpportunity {
  const data = doc.data();
  if (!data) {
    throw new HttpsError("not-found", "Opportunity was not found.");
  }

  return {
    id: doc.id,
    assetClass: String(data.assetClass ?? data.type ?? "Real Estate"),
    riskLevel: String(data.riskLevel ?? "Medium"),
    paymentMethods: readStringArrayOrDefault(
      data.paymentMethods,
      enabledPaymentMethods.length === 0 ? ["USDT"] : enabledPaymentMethods,
    ),
    title: String(data.title ?? ""),
    location: String(data.location ?? ""),
    minimumInvestment: Number(data.minimumInvestment ?? 250000),
    targetReturn: Number(data.targetReturn ?? 11.8),
    fundedPercent: Number(data.fundedPercent ?? 0),
  };
}

function paymentOptionFromDoc(
  doc: FirebaseFirestore.QueryDocumentSnapshot,
): CryptoPaymentOption {
  const data = doc.data();
  return {
    id: doc.id,
    network: String(data.network ?? ""),
    assetSymbol: String(data.assetSymbol ?? ""),
    walletAddress: String(data.walletAddress ?? ""),
    qrCodeUrl: String(data.qrCodeUrl ?? ""),
    enabled: Boolean(data.enabled ?? true),
    minimumAmount: Number(data.minimumAmount ?? 0),
  };
}

function depositRequestFromDoc(
  doc: FirebaseFirestore.QueryDocumentSnapshot,
) {
  const data = doc.data();
  return {
    id: doc.id,
    uid: String(data.uid ?? ""),
    opportunityTitle: String(data.opportunityTitle ?? ""),
    amountUgx: Number(data.amountUgx ?? 0),
    paymentNetwork: String(data.paymentNetwork ?? ""),
    paymentAsset: String(data.paymentAsset ?? ""),
    paymentWalletAddress: String(data.paymentWalletAddress ?? ""),
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
    amountUgx: Number(data.amountUgx ?? 0),
    paymentAsset: String(data.paymentAsset ?? ""),
    paymentNetwork: String(data.paymentNetwork ?? ""),
    status: String(data.status ?? "pending_payment"),
    updatedAt: readSerializableDate(data.updatedAt ?? data.createdAt),
    createdAt: readSerializableDate(data.createdAt),
  };
}

function buildMemberHoldings(
  orders: ReturnType<typeof memberOrderFromDoc>[],
  assetsById: Map<string, MemberOpportunity>,
) {
  const holdingsByOpportunity = new Map<string, {
    opportunityId: string;
    title: string;
    assetClass: string;
    brickShares: number;
    valueUgx: number;
    returnPercent: number;
  }>();

  for (const order of orders) {
    const asset = assetsById.get(order.opportunityId);
    const current = holdingsByOpportunity.get(order.opportunityId);
    const minimumInvestment = asset?.minimumInvestment ?? order.amountUgx;
    const brickShares = minimumInvestment > 0 ?
      order.amountUgx / minimumInvestment :
      0;
    holdingsByOpportunity.set(order.opportunityId, {
      opportunityId: order.opportunityId,
      title: asset?.title ?? order.opportunityTitle,
      assetClass: asset?.assetClass ?? "BrickShares",
      brickShares: roundMoney((current?.brickShares ?? 0) + brickShares),
      valueUgx: roundMoney((current?.valueUgx ?? 0) + order.amountUgx),
      returnPercent: asset?.targetReturn ?? current?.returnPercent ?? 0,
    });
  }

  return Array.from(holdingsByOpportunity.values());
}

function buildMemberAllocation(
  holdings: ReturnType<typeof buildMemberHoldings>,
) {
  const total = holdings.reduce((sum, holding) => sum + holding.valueUgx, 0);
  if (total <= 0) return [];

  const values = new Map<string, number>();
  for (const holding of holdings) {
    values.set(
      holding.assetClass,
      (values.get(holding.assetClass) ?? 0) + holding.valueUgx,
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
      totals[index] += order.amountUgx;
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
      formatUgx(order.amountUgx) :
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
  };
  const password = readOptionalString(value, "password");

  if (!options.passwordOptional || password) {
    payload.password = password;
  }

  return payload;
}

function readAssetPayload(data: unknown): Omit<AdminAsset, "id"> {
  const value = readObject(data);
  return {
    title: readString(value, "title"),
    location: readString(value, "location"),
    type: readString(value, "type"),
    fundedPercent: readNumber(value, "fundedPercent"),
    reviewStatus: readString(value, "reviewStatus"),
    publishedStatus: readString(value, "publishedStatus"),
  };
}

function readPaymentOptionPayload(
  data: unknown,
): Omit<CryptoPaymentOption, "id"> {
  const value = readObject(data);
  return {
    network: readString(value, "network"),
    assetSymbol: readString(value, "assetSymbol"),
    walletAddress: readString(value, "walletAddress"),
    qrCodeUrl: readOptionalString(value, "qrCodeUrl") ?? "",
    enabled: readBoolean(value, "enabled"),
    minimumAmount: readNumber(value, "minimumAmount"),
  };
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
    minimumAmountUgx: Number(
      data.minimumAmountUgx ?? defaults.minimumAmountUgx,
    ),
    flatFeeUgx: Number(data.flatFeeUgx ?? defaults.flatFeeUgx),
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
    minimumAmountUgx: 50000,
    flatFeeUgx: 0,
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
    minimumAmountUgx: readPositiveNumber(value, "minimumAmountUgx"),
    flatFeeUgx: readNonNegativeNumber(value, "flatFeeUgx"),
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

  const tokens = tokenSnapshot.docs.map((doc) => doc.id);
  if (tokens.length > 0) {
    await messaging.sendEachForMulticast({
      tokens,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: notification.data,
    });
  }
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

  const tokens = tokenSnapshot.docs.map((doc) => doc.id);
  if (tokens.length > 0) {
    await messaging.sendEachForMulticast({
      tokens,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: notification.data,
    });
  }
}

async function listAdminUsers(): Promise<UserRecord[]> {
  const result = await auth.listUsers(1000);
  return result.users.filter((user) => user.customClaims?.admin === true);
}

async function sendOperationalEmail(message: {
  to: string;
  subject: string;
  text: string;
  html: string;
}) {
  const transport = nodemailer.createTransport({
    host: process.env.SMTP_HOST ?? process.env.MAILPIT_SMTP_HOST ?? "127.0.0.1",
    port: Number(process.env.SMTP_PORT ?? process.env.MAILPIT_SMTP_PORT ?? 1025),
    secure: process.env.SMTP_SECURE === "true",
    auth: process.env.SMTP_USER && process.env.SMTP_PASS
      ? {
          user: process.env.SMTP_USER,
          pass: process.env.SMTP_PASS,
        }
      : undefined,
  });

  await transport.sendMail({
    from: process.env.SMTP_FROM ?? process.env.MAILPIT_FROM ?? devMailFrom,
    ...message,
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

function formatUgx(value: number): string {
  return `UGX ${Math.round(value).toLocaleString("en-US")}`;
}

function isLikelyWalletAddress(value: string): boolean {
  const trimmed = value.trim();
  return /^(0x[a-fA-F0-9]{40}|T[A-Za-z0-9]{25,40}|bc1[A-Za-z0-9]{25,90}|[13][A-Za-z0-9]{25,40})$/.test(trimmed);
}
