# Quick Start Guide - RSET Student Application

## ⚡ 5-Minute Setup

### Step 1: Install Backend Dependencies
```bash
cd backend
pip install -r requirements.txt
```

### Step 2: Start Backend Server
```bash
python main.py
```
✅ Backend running at: `http://localhost:8000`

### Step 3: Start Admin Dashboard (New Terminal)
```bash
cd admin-dashboard
python -m http.server 8080
```
✅ Dashboard at: `http://localhost:8080`

### Step 4: Initialize Admin Account
1. Open http://localhost:8080 in browser
2. Create admin account (first-time only)
3. Login with your credentials

### Step 5: Start Mobile App (New Terminal)
```bash
flutter pub get
flutter run
```

---

## 🎮 Admin Portal - First Steps

### Add Attendance
1. Click "Attendance" in sidebar
2. Fill form: Date, Class Code, Period, Subject Code
3. Click "Add Absence"
4. See it instantly on mobile app! ✨

### Upload Notice PDF
1. Click "Notices" in sidebar
2. Enter title and select PDF file (max 10MB)
3. Choose notice type (Regular/Exam)
4. Click "Upload Notice"
5. Mobile app refreshes automatically ✨

### Create Calendar Event
1. Click "Events" in sidebar
2. Fill: Title, Date, Description (optional)
3. Click "Create Event"
4. Event appears on mobile calendar with dot ✨

### Add Student Marks
1. Click "Marks" in sidebar
2. Fill: Class Code, Subject Code, Student ID, Mark
3. Click "Save Mark"
4. Mobile app updates in real-time ✨

---

## 📱 Mobile App - User Experience

- **Attendance:** Shows only absent periods with subject codes
- **Notices:** Tap PDF icon to open notice
- **Calendar:** Dates with events show black dots
- **Marks:** Filter by class and exam type
- **Real-time:** All updates appear instantly via WebSocket

---

## 🔧 Configuration (If Not Localhost)

### For Android Device (Replace 192.168.1.100)
Edit `lib/data/api_service.dart`:
```dart
static const String baseUrl = 'http://192.168.1.100:8000/api';
```

Edit `lib/data/websocket_service.dart`:
```dart
static const String wsUrl = 'ws://192.168.1.100:8000/ws';
```

### For Production (Replace yourdomain.com)
```dart
static const String baseUrl = 'https://yourdomain.com/api';
static const String wsUrl = 'wss://yourdomain.com/ws';
```

---

## 📊 Database Setup

Create MongoDB indexes (copy-paste in MongoDB shell):

```javascript
db.attendance.createIndex({class_code: 1, date: 1})
db.marks.createIndex({student_id: 1, class_code: 1})
db.notices.createIndex({is_exam_notice: 1, upload_date: -1})
db.events.createIndex({date: 1})
db.admins.createIndex({username: 1}, {unique: true})
```

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Port 8000 already in use | `lsof -i :8000` (Mac/Linux) or use different port |
| MongoDB connection failed | Ensure MongoDB is running: `systemctl start mongod` |
| WebSocket connection error | Check firewall allows port 8000 |
| Admin dashboard CORS error | Backend has CORS enabled by default |
| APK won't install | Enable "Unknown Sources" in Android settings |

---

## 📁 Important Paths

```
backend/
├── uploads/notices/        ← PDF files stored here
└── .env                     ← Configuration file

lib/
├── data/api_service.dart   ← Change API URL here
└── data/websocket_service.dart ← Change WebSocket URL here

admin-dashboard/
└── index.html              ← Open this in browser
```

---

## ✨ Real-Time Magic

When you update data in admin portal:
```
Admin Portal → Backend API → WebSocket Broadcast → Mobile App
          Instant! (< 1 second)
```

---

## 📱 Build APK for Distribution

```bash
flutter build apk --release
```

📁 Output: `build/app/outputs/flutter-apk/app-release.apk`

Send to students via:
- Email
- Google Drive
- QR code
- Direct file transfer

---

## 🔐 Security Reminders

⚠️ **Before Production:**
- [ ] Change admin password
- [ ] Update `ADMIN_SECRET_KEY` in `.env`
- [ ] Configure MongoDB authentication
- [ ] Set CORS origins correctly
- [ ] Enable HTTPS (SSL certificates)
- [ ] Change default URLs

---

## 📖 Full Documentation

- **Deployment:** See `DEPLOYMENT_GUIDE.md`
- **Project Overview:** See `README.md`
- **Admin Dashboard:** See `admin-dashboard/README.md`

---

## 🎯 Key Points

✅ **No Admin Portal in Mobile App** - Separate web dashboard only  
✅ **Real-Time Sync** - WebSocket instant updates  
✅ **Responsive Design** - Works on all devices  
✅ **PDF Support** - Max 10MB per notice  
✅ **Attendance Display** - Only absent periods shown  
✅ **Calendar Events** - Dots on dates, details below  
✅ **Separate Admin Accounts** - Different from student login  
✅ **Automatic Backups** - MongoDB integration  

---

**Questions?** Check `DEPLOYMENT_GUIDE.md` section 11 for troubleshooting!

**Ready to go!** 🚀
