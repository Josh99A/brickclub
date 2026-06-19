# CLAUDE.md

Guidance for AI agents working in this repository. For long-form setup (emulators,
first-admin bootstrap, production provisioning) see [README.md](README.md); this
file captures the architecture, conventions, and commands an agent needs day to day.

## What this is

BrickClub is a **Flutter** (web + Android/iOS) fractional real-estate investment
app backed by **Firebase** (Auth, Firestore, Cloud Functions, Storage, Cloud
Messaging). Members browse investment opportunities, complete KYC, fund purchases,
and track a portfolio; admins manage assets, users, KYC, payments, and withdrawals
from an in-app dashboard.

- Flutter client: `lib/`
- Backend (TypeScript Cloud Functions): `functions/`
- Firestore/Storage rules + indexes: `firestore.rules`, `firestore.indexes.json`, `storage.rules`
- Active Firebase project: **`brickclub`** (see `.firebaserc`)

## Architecture & conventions

**Client is feature-first with a repository pattern. Follow it.**

- `lib/main.dart` — boots Flutter, calls `FirebaseBootstrap.initialize()`, then
  constructs each `Firebase*Repository` and injects them into `BrickClubApp`.
- `lib/src/app/` — all UI: screens, theme, routing/auth gate, shared widgets.
- `lib/src/core/firebase/` — `firebase_bootstrap.dart` (init + emulator wiring),
  `default_firebase_options.dart` (platform options, used instead of
  google-services files), `backend_functions.dart` (typed callable clients).
- `lib/src/core/web/` — PWA install plumbing (conditional web/stub imports).
- `lib/src/features/<feature>/` — one folder per domain: `admin`, `auth`,
  `investment`, `kyc`, `support`. Each has:
  - `domain/` — plain models + an **abstract repository interface**.
  - `data/` — the `Firebase<Feature>Repository` implementation.

**Rules:**
- **Widgets never touch Firebase SDKs directly.** Call a repository (or
  `BackendFunctions`) abstraction. Keep `cloud_firestore` / `firebase_auth` /
  `cloud_functions` imports inside `lib/src/features/*/data/` and `lib/src/core/`.
- New backend-touching feature → add the contract in `domain/`, implement in
  `data/`, inject from `main.dart`.
- Privileged logic lives in Cloud Functions, never the client.

### Cloud Functions (`functions/src/index.ts`)

All callables are defined in a single `functions/src/index.ts`. Auth is enforced
through two wrappers — **use them, don't hand-roll auth checks**:

- `onMemberCall(...)` — requires an authenticated user.
- `onAdminCall(...)` — requires the Firebase custom claim `admin: true`.

Admin access = the `admin: true` custom claim. The client force-refreshes the ID
token after admin sign-in to read it. The first admin must be set out-of-band via
`npm --prefix functions run claim:admin -- <email>` (see README); afterwards admins
are managed from the dashboard (`setUserAdmin`).

Firestore collections in use: `adminAssets`, `cryptoPaymentOptions`, `kycProfiles`,
`purchaseOrders`, `withdrawalRequests`, `supportTickets`, `memberHoldings`,
`memberActivities`, `memberNotifications`, `adminNotifications`,
`notificationTokens`, `platformSettings`.

When you add or change a callable, mirror it in the client: typed methods in
`lib/src/core/firebase/backend_functions.dart` or the relevant repository.

## Commands

Flutter (run from repo root):

```powershell
flutter pub get
flutter run -d chrome                 # dev against CLOUD Firebase (default)
flutter build web --release
flutter analyze                       # lint
flutter test                          # tests (test/)
```

Run against local emulators instead of cloud:

```powershell
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
firebase emulators:start --only auth,functions,firestore,storage
```

Cloud Functions (run from repo root; `--prefix functions`):

```powershell
npm --prefix functions install
npm --prefix functions run build      # tsc compile (required before deploy)
npm --prefix functions run lint       # eslint
npm --prefix functions run serve      # build + start backend emulators
```

**Before finishing client work run `flutter analyze` + `flutter test`; before
finishing backend work run `npm --prefix functions run build` + `... run lint`.**
The deploy `predeploy` hook runs lint + build, so a lint/type error blocks deploy.

## Deploy & CI/CD

Pushing to `main` triggers `.github/workflows/firebase-deploy.yml`, which builds
Flutter web + functions and runs `firebase deploy --only hosting,functions,firestore,storage`
against `brickclub`. Manual deploy: `firebase deploy --only functions` (after
`firebase use brickclub`).

**Secrets/config the deploy depends on (do not break these):**
- Secret Manager holds `SMTP_PASS`; it's bound to every function via
  `setGlobalOptions({secrets: [smtpPass]})`. The CI deployer service account
  `github-action-1270157247@brickclub.iam.gserviceaccount.com` needs
  `roles/secretmanager.admin` to read/bind it.
- Non-secret SMTP params (`SMTP_HOST/PORT/SECURE/USER/FROM`) come from
  `functions/.env.brickclub`, which is **git-ignored**. CI writes it from the
  GitHub secret `FUNCTIONS_ENV_BRICKCLUB` (a workflow step), then deploys. If SMTP
  config changes, update that GitHub secret — **never commit credentials** (the
  repo is public).

Email/push are best-effort: if SMTP is unset or unreachable, the message is
skipped and logged, never blocking the triggering action.

## Gotchas

- Repo is **public** — keep keys, passwords, and `functions/.env.*` out of git.
- `default_firebase_options.dart` is used directly; there are no
  `google-services.json` / `GoogleService-Info.plist` files.
- The app defaults to **cloud** Firebase even in `flutter run`; that uses real
  data/quota and live email + SMS. Use `--dart-define=USE_FIREBASE_EMULATORS=true`
  for safe backend work.
- Web push needs a build-time VAPID key:
  `flutter build web --dart-define=FCM_VAPID_KEY=<public-vapid-key>`.
- Functions target Node 22; client SDK is on the Firebase v4/v6 line (see
  `pubspec.yaml`).

## Git

Default branch `main` (deploys on push). Branch for changes and open a PR rather
than committing to `main` directly. Commit/push only when asked.
