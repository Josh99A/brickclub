# BrickClub

BrickClub is a Flutter app backed by Firebase. Local development uses the Firebase Emulator Suite for Authentication and Cloud Functions so backend work can be built and tested without touching production data.

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

Start the Firebase emulators:

```powershell
docker compose up -d mailpit
firebase emulators:start --only auth,functions,firestore,storage
```

The emulator UI runs at [http://localhost:4000](http://localhost:4000).
Mailpit runs at [http://localhost:8025](http://localhost:8025), with SMTP
available on `localhost:1025`.

Run the Flutter app in development:

```powershell
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

The app defaults to emulators in debug builds. For Android emulator runs it uses `10.0.2.2`; for web, Windows, iOS simulator, and macOS it uses `localhost`.

For a physical device on the same network, pass your machine IP:

```powershell
flutter run --dart-define=USE_FIREBASE_EMULATORS=true --dart-define=FIREBASE_EMULATOR_HOST=192.168.1.20
```

## Authentication

Firebase Authentication is the source of truth for sign-in and account creation. During local development, create test users in the Auth emulator UI or through the app sign-up flow.

Current local defaults in the UI:

- member email: `joshua@brickclub.ug`
- admin email: `admin@brickclub.ug`
- password: `password10`

Admin access is authorized with the Firebase custom claim `admin: true`. The Flutter app checks the refreshed ID token after admin sign-in, and all admin callable Functions require that claim before performing CRUD.

To create the first local emulator admin:

1. Start the emulators.
2. Create `admin@brickclub.ug` in the Auth emulator UI or through the app.
3. In another terminal, set the claim:

```powershell
$env:FIREBASE_AUTH_EMULATOR_HOST="127.0.0.1:9099"
$env:GCLOUD_PROJECT="brickclub-dev"
npm --prefix functions run claim:admin -- admin@brickclub.ug
```

After a claim changes, sign out and sign back in so the app receives a fresh ID token.

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

Before a production build, disable emulators explicitly:

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
