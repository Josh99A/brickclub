# BrickClub

BrickClub is a Flutter app backed by Firebase. Local development can run two ways:

- **Against the cloud `brickclub` project** (default) when you want to develop against real Firebase services.
- **Against the Firebase Emulator Suite** by enabling emulators explicitly, so backend work can be built and tested without touching cloud data.

See [Run against the Firebase emulators](#run-against-the-firebase-emulators) for the emulator workflow.

## Architecture

- `lib/main.dart` boots Flutter, initializes Firebase, and creates app-level dependencies.
- `lib/src/app/` contains the current BrickClub UI and routing gate.
- `lib/src/core/firebase/` contains Firebase bootstrap, emulator configuration, generated-style Firebase options, and shared backend function clients.
- `lib/src/features/auth/` contains the authentication domain contract and Firebase implementation.
- `functions/src/` contains Firebase Cloud Functions, which are the backend entry points.

Keep Firebase calls behind repositories or core service clients. Widgets should call app/domain abstractions, not Firebase SDKs directly.

## Development Setup

Install the required tools:

```powershell
flutter doctor
npm install -g firebase-tools
dart pub global activate flutterfire_cli
docker --version
java -version
```

Install Java 21 or newer if `java -version` is not available. The Firestore
emulator requires Java.

Install project dependencies:

```powershell
flutter pub get
npm --prefix functions install
```

Run the Flutter app in development:

```powershell
flutter run
```

The app defaults to the cloud `brickclub` project, so a plain `flutter run`
connects Authentication, Firestore, Cloud Functions, and Storage to the cloud.
This uses real cloud data and quota — see
[Run against cloud Firebase in development](#run-against-cloud-firebase-in-development)
for the implications. To use the local emulators instead, see
[Run against the Firebase emulators](#run-against-the-firebase-emulators).

### Run against cloud Firebase in development

A plain `flutter run` connects Authentication, Firestore, Cloud Functions, and
Storage to the cloud `brickclub` project — this is the default, so no flag is
required:

```powershell
flutter run -d chrome
```

Notes:

- **All platforms are configured for cloud.** Web, Android, iOS, Windows, and
  Linux apps are registered in the `brickclub` project, and their real options
  live in `lib/src/core/firebase/default_firebase_options.dart`. Firebase is
  initialized directly from these Dart options, so no `google-services.json` or
  `GoogleService-Info.plist` is required.
- For Android phone-auth/App Check against cloud you must add your signing
  certificate SHA-1/SHA-256 to the Android app in the Firebase Console.
- This uses real cloud data and quota. Email verification and password reset
  use the live Firebase Auth email senders (not Mailpit), and phone
  verification sends real SMS. Make sure `localhost` is an authorized domain
  for web sign-in (it is by default for new projects).
- Cloud Functions must be deployed for callable features to work; the local
  Functions emulator is not used in this mode. Deploy with
  `firebase deploy --only functions`.

### Run against the Firebase emulators

To build and test backend work without touching cloud data, enable the
emulators explicitly. Because the app now defaults to cloud, the flag is
required.

Start the Firebase emulators:

```powershell
docker compose up -d mailpit
firebase emulators:start --only auth,functions,firestore,storage
```

The emulator UI runs at [http://localhost:4000](http://localhost:4000).
Mailpit runs at [http://localhost:8025](http://localhost:8025), with SMTP
available on `localhost:1025`.

Run the app against the emulators:

```powershell
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

For Android emulator runs the app uses `10.0.2.2`; for web, Windows, iOS
simulator, and macOS it uses `localhost`.

For a physical Android device connected over USB, use the helper script. It
sets up local reverse ports for convenience, detects this machine's LAN IPv4
address, then runs Flutter against that address. A LAN address is required
because FlutterFire remaps `127.0.0.1` to `10.0.2.2` on Android for emulator
support, which is wrong for a physical phone:

```powershell
.\scripts\run-physical-device.ps1
```

You can pass normal Flutter arguments after the script name:

```powershell
.\scripts\run-physical-device.ps1 -d <device-id>
```

If the script selects the wrong network adapter, pass the host explicitly:

```powershell
.\scripts\run-physical-device.ps1 -d <device-id> -EmulatorHost 192.168.1.20
```

For a physical device on the same Wi-Fi network instead, pass your machine IP.
The Firebase emulators are configured to listen on `0.0.0.0` for this workflow,
but Windows Firewall may still need to allow the emulator ports:

```powershell
flutter run --dart-define=USE_FIREBASE_EMULATORS=true --dart-define=FIREBASE_EMULATOR_HOST=192.168.1.20
```

## Authentication

Firebase Authentication is the source of truth for sign-in and account creation. During local development, create test users in the Auth emulator UI or through the app sign-up flow.

Current local defaults in the UI:

- member email: `joshua@brickclub.com`
- admin email: `admin@brickclub.com`
- password: `password10`

Admin access is authorized with the Firebase custom claim `admin: true`. The Flutter app checks the refreshed ID token after admin sign-in, and all admin callable Functions require that claim before performing CRUD.

To create the first local emulator admin:

1. Start the emulators.
2. Create `admin@brickclub.com` in the Auth emulator UI or through the app.
3. In another terminal, set the claim:

```powershell
$env:FIREBASE_AUTH_EMULATOR_HOST="127.0.0.1:9099"
$env:GCLOUD_PROJECT="brickclub"
npm --prefix functions run claim:admin -- admin@brickclub.com
```

After a claim changes, sign out and sign back in so the app receives a fresh ID token.

### First admin on the live (cloud) project

The live `brickclub` project starts with no users, and the in-app "Users"
dashboard can only promote people once an admin already exists. So the very
first admin has to be granted the `admin: true` claim from a trusted machine.

1. Make sure **Email/Password** (and **Google**, if you use it) is enabled under
   Firebase Console → Authentication → Sign-in method. Without it, sign-up fails
   with "Email sign in is not enabled yet."
2. Create the account through the app's **Create account** flow against cloud:

   ```powershell
   flutter run -d chrome --dart-define=USE_FIREBASE_EMULATORS=false
   ```

3. Grant the admin claim with the helper script. Against cloud it uses Google
   Application Default Credentials, so authenticate once first:

   ```powershell
   gcloud auth application-default login
   $env:GCLOUD_PROJECT="brickclub"
   npm --prefix functions run claim:admin -- you@example.com
   ```

   (Do **not** set `FIREBASE_AUTH_EMULATOR_HOST` here — that variable is only for
   the emulator and would point the script at the wrong place.)
4. Sign out and sign back in, then use **Sign in as an admin** on the sign-in
   screen. The app force-refreshes the ID token and reads the new claim.

Once the first admin exists, grant or revoke admin for everyone else from the
admin dashboard's Users section instead of re-running the script.

### Development email

Development password reset and KYC email verification messages are sent through
the Functions emulator to Mailpit. Start Mailpit before sending email:

```powershell
docker compose up -d mailpit
npm --prefix functions run serve
```

Open [http://localhost:8025](http://localhost:8025) to view the local inbox.
The Functions emulator uses `MAILPIT_SMTP_HOST=127.0.0.1` and
`MAILPIT_SMTP_PORT=1025` by default.

### Phone SMS verification

KYC phone verification uses Firebase Auth phone verification in development.
When the app is connected to the Auth emulator, no real SMS is sent. Send the
code from the KYC screen, then open the Auth emulator UI at
[http://localhost:4000/auth](http://localhost:4000/auth) and use the displayed
verification code in the app.

The admin dashboard can now manage:

- Firebase Auth users, including disabling accounts and granting/removing admin claims.
- Assets stored in Firestore under `adminAssets`.
- Crypto payment options stored in Firestore under `cryptoPaymentOptions`.

## Cloud Functions

Build and lint functions:

```powershell
npm --prefix functions run build
npm --prefix functions run lint
```

Run only the backend emulators:

```powershell
npm --prefix functions run serve
```

Admin callable Functions live in `functions/src/index.ts`. Keep privileged behavior there, especially user management and custom-claim changes. Flutter should call typed repositories under `lib/src/features/*/data/` instead of talking directly to Firebase Admin-only resources.

## Production Setup

Create or choose the production Firebase project, then run:

```powershell
flutterfire configure
```

Use the production Firebase project ID and select the platforms you plan to ship. Replace the placeholder Firebase options in `lib/src/core/firebase/default_firebase_options.dart` with the generated production values, or adopt the generated `lib/firebase_options.dart` and update `FirebaseBootstrap` to import it.

Production builds already default to cloud Firebase. You can pass the flag
explicitly to be safe:

```powershell
flutter build web --dart-define=USE_FIREBASE_EMULATORS=false
flutter build apk --dart-define=USE_FIREBASE_EMULATORS=false
```

Deploy Cloud Functions:

```powershell
firebase use <production-project-id>
firebase deploy --only functions
```

Set the first production admin from a trusted machine with Google application credentials or another secure admin process:

```powershell
$env:GCLOUD_PROJECT="<production-project-id>"
npm --prefix functions run claim:admin -- founder@example.com
```

Production checklist:

- Enable the required Firebase Authentication providers in the Firebase Console.
- Configure authorized domains for web sign-in.
- Set custom claims for initial admin users before exposing admin operations.
- Deploy Firestore rules with `firebase deploy --only firestore:rules`.
- Keep secrets out of source control; use Firebase environment/config or Secret Manager.
- Review Firebase security rules whenever Firestore, Storage, or other Firebase products are added.

## Verification

Run Flutter checks:

```powershell
flutter analyze
flutter test
```

Run Functions checks:

```powershell
npm --prefix functions run build
npm --prefix functions run lint
```
