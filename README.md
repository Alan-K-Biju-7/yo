# RSET Student App

A responsive Flutter recreation of the supplied RSET student Android
application screens. It targets mobile phones in portrait and landscape; no
tablet-specific layout is included.

## Implemented reference scope

- Login screen with persistent local sign-in until Logout is pressed
- Scrollable Home screen with exclusive Vision and Mission accordions
- Home/Profile bottom navigation and Profile back navigation
- Notices and Exam Notices lists
- Attendance class-code selection and horizontally scrollable period table
- Internal Mark class-code and exam-type selection
- Academic Calendar
- Late Coming Details
- Academic/Semester document list
- Responsive checks at `360x800` portrait and `800x360` landscape

Semester and Comments/Remarks do not navigate because no destination-screen
reference was supplied. Networking, real authentication, PDF URLs, and backend
endpoints are intentionally not invented; the current reference data is local.

## Requirements

- Flutter `3.44.8` stable or compatible
- Dart `3.12.2` or compatible
- JDK 17
- Android SDK and an Android phone with USB debugging, or an Android emulator

Check the environment:

```powershell
flutter doctor
```

On the current development machine, Flutter can be called directly with:

```powershell
C:\Users\Amith\flutter-sdk\bin\flutter.bat doctor
```

## Run from source

From PowerShell:

```powershell
cd C:\Users\RSMS
C:\Users\Amith\flutter-sdk\bin\flutter.bat pub get
C:\Users\Amith\flutter-sdk\bin\flutter.bat devices
C:\Users\Amith\flutter-sdk\bin\flutter.bat run
```

If more than one device is listed:

```powershell
C:\Users\Amith\flutter-sdk\bin\flutter.bat run -d <device-id>
```

Any non-empty username and password enters the local reference app.

## Build the verified universal APK

The repository includes a PowerShell build script that resolves dependencies,
runs analysis and tests, builds one universal APK, copies it into `dist`, and
creates a SHA-256 checksum:

```powershell
cd C:\Users\RSMS
powershell -ExecutionPolicy Bypass -File .\scripts\build_apk.ps1 `
  -Flutter C:\Users\Amith\flutter-sdk\bin\flutter.bat
```

For a debug APK:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_apk.ps1 `
  -Mode debug `
  -Flutter C:\Users\Amith\flutter-sdk\bin\flutter.bat
```

## Install an APK on a phone

Enable Developer options and USB debugging, connect the unlocked phone, approve
the USB debugging prompt, then run:

```powershell
C:\Users\Amith\android-sdk\platform-tools\adb.exe devices
C:\Users\Amith\android-sdk\platform-tools\adb.exe install -r `
  C:\Users\RSMS\dist\RSET-Student-App-v1.0.0-universal-release.apk
```

The universal APK can also be copied to another supported Android phone and
opened there. Android may ask the recipient to allow installation from the app
used to open the file.

This repository currently signs release-mode APKs with the Android debug key so
that no private production keystore is committed. The APK is suitable for
direct learning, validation, and research distribution. A Play Store or other
production release requires a separately protected release keystore.

## Download the APK from GitHub

The `Android APK` GitHub Actions workflow runs for pull requests, `main`,
feature branches, and manual dispatches. Open the completed workflow run,
scroll to **Artifacts**, and download:

`RSET-Student-App-v1.0.0-universal-release`

The artifact contains the APK and its SHA-256 checksum.

## Verification

```powershell
C:\Users\Amith\flutter-sdk\bin\flutter.bat analyze
C:\Users\Amith\flutter-sdk\bin\flutter.bat test
```
