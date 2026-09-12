# SelfieCam

SelfieCam is a Flutter photo-booth application for iPad and Android devices. A
device operator signs in, joins an event, downloads that event's branding and
experience configuration, captures photos or videos, optionally collects lead
information, and uploads the resulting media to the SelfieCam API.

The package name is currently `selfiecam1`, while the iOS display name is
`SelfieCam`.

## Prerequisites

- Flutter with Dart SDK `^3.8.0` (see `pubspec.yaml` for the authoritative SDK
	constraint).
- Xcode and CocoaPods for iOS development.
- Android Studio and an Android SDK for Android development.
- A physical device is strongly recommended. Camera, gallery, microphone,
	video encoding, and device-health behavior cannot be fully verified on a
	simulator.
- Access to a valid SelfieCam device account and event.

Check the local toolchain before starting:

```bash
flutter doctor
flutter --version
```

## First-Time Setup

From the repository root:

```bash
flutter pub get
```

Create `assets/config/.env` if it is missing. The application currently reads
the following value during startup:

```dotenv
SP_ENCRPT_KEY=<local-encryption-key>
```

Do not commit real credentials, tokens, or encryption keys. The file is bundled
as a Flutter asset, so changing it requires a full application restart. Keep
the spelling `SP_ENCRPT_KEY` because it is the key currently used by
`PrefUtils`.

For iOS, install pods when native dependencies change:

```bash
cd ios
pod install
cd ..
```

## Running the App

List available targets and run a development build:

```bash
flutter devices
flutter run
```

Useful commands:

```bash
flutter analyze
flutter test
dart format lib test
flutter clean
flutter pub get
```

The app forces portrait orientation at runtime. The iOS project also declares
portrait support for the production device flow.

## Runtime Flow

The main application lifecycle is:

1. `lib/main.dart` initializes orientation, dotenv, encrypted preferences,
	 Dio, Hive, global GetX services, FFmpeg logging, and Sentry.
2. `MyApp` starts at `Routes.SPLASH`.
3. The splash/session flow decides whether the device should sign in, choose an
	 event, or enter the current event experience.
4. Sign-in calls `POST /api/devices/login`, stores the device token, and loads
	 device/event information.
5. Event selection calls `PUT /api/devices/{deviceId}` and stores the event
	 identity and event token.
6. The joined event loads branding, enabled experiences, lead-capture rules,
	 and disclaimers. Remote media is downloaded into the application documents
	 directory and configuration is cached in Hive.
7. `SocketService` connects to the live server, joins the event, sends a
	 heartbeat approximately once per minute, and applies live branding,
	 experience, lead-capture, and disclaimer updates.
8. The operator selects Photo, Boomerang, GIF, Shoutout, Slow Motion, or an
	 enabled AI style. Camera work is coordinated by `CameraControllerX`.
9. Captured media is previewed, optionally saved to the device gallery, and
	 submitted with lead data when applicable.
10. `UploadQueueService` persists upload work in Hive and processes it when the
		network is available. The queue is initialized after a successful event
		session, not during the initial global startup.

## Project Structure

```text
lib/
	main.dart                       Application bootstrap and GetMaterialApp
	controller/                     GetX controllers and feature state
	data/
		api/                          API response wrappers
		models/                       JSON/Hive data models and generated adapters
		services/                     API-facing services, caching, uploads, sockets
	infrastructure/
		bindings/                     GetX dependency bindings
		constants/                    Routes, endpoints, colors, asset references
		navigation/                   GetX route names and page registrations
		theme/                        Global Material theme
		utils/                        API client, preferences, logging, media helpers
	presentation/
		auth/                         Sign-in, event joining, and web views
		component/                    Reusable buttons, fields, loaders, and toasts
		home/                         Booth screens and capture/send workflows

assets/
	config/                         Runtime dotenv file
	fonts/                          Bundled Bebas, Akshar, and Inter fonts
	icons/                          App icons and experience artwork
	images/                         Images and other bundled visual assets
android/                          Android host project
ios/                              iOS host project
test/                             Flutter tests; currently only a placeholder
```

### Where to Make Changes

- Add or change a screen in `lib/presentation/`.
- Put screen state, API orchestration, and lifecycle logic in the matching
	`lib/controller/` class. Controllers use GetX observables and `Get.find`.
- Put reusable API or persistence behavior in `lib/data/services/` rather than
	directly in widgets.
- Add or change request paths in `lib/infrastructure/constants/api_endpoints.dart`.
- Use `ApiCalls` in `lib/infrastructure/utils/api_client.dart` for the regular
	JSON API. Uploads use the separate Dio-based `UploadRepository`.
- Add route names in `routes.dart` and register active pages in
	`navigation.dart`.
- Add bundled files under `assets/` and update the `flutter.assets` section of
	`pubspec.yaml` when a new asset directory is introduced.
- When changing Hive models, update the adapter and keep its type ID stable.
	Current upload adapter IDs are 50 (`UploadStatus`), 51 (`LeadCapture`), and
	52 (`UploadQueueItem`).

## State and Persistence

There are three main kinds of local state:

- Encrypted shared preferences store device and event session values such as
	`deviceToken`, `deviceId`, `eventToken`, `eventId`, `eventName`, and login
	details. Access them through `PrefUtils`.
- Hive stores cached event configuration and the persistent upload queue. The
	startup sequence must register adapters before opening typed boxes.
- The application documents directory stores downloaded branding and AI
	reference media under local media folders. These files are reused when the
	same path already exists.

When a device is removed by the server, the socket handler clears session
preferences, cached branding/experiences, settings, and downloaded event media,
then returns to sign-in.

## API and Authentication

The active API host is defined in `ApiUrls`:

- REST API: `https://hub.selfiecam.ai/api/`
- Socket.IO host: `https://hub.selfiecam.ai`

Configured REST paths include:

| Purpose | Method | Path |
| --- | --- | --- |
| Device login | POST | `devices/login` |
| List events | GET | `events/dropdown` |
| Join event | PUT | `devices/{deviceId}` |
| Joined event details | GET | `devices/joined/event` |
| Single media upload | POST | `image/upload` |
| AI style generation | POST | `ai/generate-style` |
| AI-styled image upload | POST | `image/upload/ai-style` |
| Disclaimers | GET | `settings/disclaimers` |
| Lead contacts | POST | `lead-capture/leads/contacts` |

Authenticated requests use a bearer device token. Joined-event requests also
send `x-auth-event`; both API clients send the configured app secret header.
Take care when logging requests because tokens and lead information can appear
in debug output.

## Media Capture and Uploads

`CameraControllerX` owns the camera and capture transformations:

- Uses the front camera when available.
- Locks capture to portrait.
- Uses temporary files for processed images, GIF frames, and video previews.
- Uses FFmpeg and `VideoUtils` for media transformations.
- Saves original or AI-generated images to the gallery through
	`image_gallery_saver`.

`UploadQueueService` is an offline-oriented, Hive-backed queue:

- Maximum concurrency defaults to two uploads.
- Failed items may retry up to five times.
- The repository supports single and chunked upload APIs, with chunk progress
	persisted for resumability.
- The queue listens for connectivity recovery and exposes an update stream for
	the pending uploads screen.

The current queue dispatch condition in `UploadQueueService` always selects the
single-upload branch; the chunk implementation exists but is not currently
selected. Review this intentionally before changing large-file behavior.

## Navigation

Routes are declared in `lib/infrastructure/navigation/routes.dart` and pages
are registered in `navigation.dart`. Active flows include sign-in, event join,
welcome, experience selection, send-to-me, email, phone, settings, and splash.
Some countdown, preview, and secondary routes remain declared but commented out
in the page registry because those screens are entered directly with `Get.to`.

When adding a route, update both the route constant and `Nav.routes`. When a
controller has dependencies that should be created lazily, add a GetX binding
instead of constructing it repeatedly in widgets.

## Platform Notes

- iOS declares camera, microphone, and photo-library usage descriptions in
	`ios/Runner/Info.plist`.
- Android declares internet access in the app manifest. Camera and media
	permissions are requested through Flutter plugins and must be checked on a
	physical device and on the target Android API level.
- Native plugin changes may require `pod install`, `flutter clean`, or a fresh
	Gradle build.
- Keep FFmpeg, camera, video-player, and gallery behavior in mind when testing
	older or resource-constrained devices.

## Testing and Quality Checks

The repository currently has no meaningful automated widget or unit tests;
`test/widget_test.dart` is empty. Before opening a pull request:

1. Run `dart format lib test`.
2. Run `flutter analyze` and resolve new diagnostics.
3. Run `flutter test`.
4. Test sign-in, event joining, cached restart behavior, camera permissions,
	 each enabled capture type, lead capture, gallery saving, and upload recovery
	 on a physical device.
5. Confirm that server-driven branding and experience changes arrive through
	 Socket.IO and that a device-removal event returns to sign-in.

For controller or service changes, prefer adding focused tests around request
payloads, Hive state transitions, retry behavior, and route decisions. Avoid
depending on live API credentials in automated tests.

## Troubleshooting

**The app fails before the first screen.** Confirm that
`assets/config/.env` exists, is listed in `pubspec.yaml`, and contains
`SP_ENCRPT_KEY`. Run `flutter pub get` after asset or dependency changes.

**The camera does not start.** Test on a physical device, check camera and
microphone permissions, and inspect device logs for camera initialization or
orientation errors.

**Uploads do not start.** Confirm that login produced `deviceToken`, event
joining produced `eventToken`, `InternetService` reports connectivity, and the
queue was initialized after the event session. Inspect the pending uploads
screen and Hive queue state rather than deleting temporary files first.

**Branding is stale or media is missing.** Check the API response, the local
application documents media directory, and the Socket.IO connection. A fresh
event session clears cached state when the server reports the device is no
longer valid.

**Native build errors appear after dependency changes.** Try `flutter clean`,
`flutter pub get`, and for iOS `cd ios && pod install` before rebuilding.

## Build Commands

Examples for local release artifacts:

```bash
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
```

Set release version metadata with Flutter flags when needed, for example:

```bash
flutter build apk --release --build-name=1.0.0 --build-number=1
```

Signing, provisioning, API environment selection, and store distribution are
not configured by this README; use the team's deployment credentials and the
native project settings for those steps.
