# RSET Student App

Responsive Flutter recreation of the supplied Android reference screens.

The current data is local because no backend contracts or original assets were
provided. Authentication accepts non-empty credentials and persists the
signed-in state until logout.

## Implemented references

- Login with persistent session and explicit logout
- Scrollable Home with exclusive Vision/Mission accordions
- Profile
- Attendance Details with horizontally scrollable periods
- Notices and Exam Notices
- Internal Mark selectors
- Academic Calendar
- Late Coming Details empty state and refresh action
- Academic/Semester PDF list
- Portrait and landscape phone layouts

The Semester and Comments/Remarks Home actions intentionally remain inactive
because no destination references were supplied. Backend authentication,
network data, PDFs, and notice-detail destinations require their API contracts
and destination references before integration.

## Run

```powershell
flutter pub get
flutter run
```

## Verify

```powershell
flutter analyze
flutter test
flutter build apk --debug
```
