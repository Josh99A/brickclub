const admin = require("firebase-admin");

const email = process.argv[2];

if (!email) {
  console.error("Usage: npm --prefix functions run claim:admin -- <email>");
  process.exit(1);
}

admin.initializeApp({
  projectId: process.env.GCLOUD_PROJECT || "brickclub-dev",
});

async function main() {
  const user = await admin.auth().getUserByEmail(email);
  await admin.auth().setCustomUserClaims(user.uid, {admin: true});
  console.log(`Admin claim set for ${email} (${user.uid})`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
