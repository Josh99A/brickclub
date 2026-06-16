import {randomUUID} from "crypto";
import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {initializeApp} from "firebase-admin/app";
import {getAuth, UserRecord} from "firebase-admin/auth";
import {FieldValue, getFirestore} from "firebase-admin/firestore";
import * as nodemailer from "nodemailer";

initializeApp();

const db = getFirestore();
const auth = getAuth();

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

type UserPayload = {
  email: string;
  password?: string;
  displayName?: string;
  disabled?: boolean;
  admin?: boolean;
};

const assetsCollection = db.collection("adminAssets");
const paymentOptionsCollection = db.collection("cryptoPaymentOptions");
const purchaseOrdersCollection = db.collection("purchaseOrders");
const kycProfilesCollection = db.collection("kycProfiles");
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

  return {
    users: usersResult.users.map(userToJson),
    assets: assetsSnapshot.docs.map(assetFromDoc),
    cryptoPaymentOptions: paymentOptionsSnapshot.docs.map(paymentOptionFromDoc),
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
    status: "pending_payment",
    expiresAt: expiresAt.toISOString(),
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };

  await purchaseOrdersCollection.doc(id).set(order);

  return order;
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
    enabled: Boolean(data.enabled ?? true),
    minimumAmount: Number(data.minimumAmount ?? 0),
  };
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
    enabled: readBoolean(value, "enabled"),
    minimumAmount: readNumber(value, "minimumAmount"),
  };
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

function roundMoney(value: number): number {
  return Math.round(value * 100) / 100;
}
