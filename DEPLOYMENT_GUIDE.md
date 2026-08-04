# RSET Student Application - Complete Deployment Guide

## Overview

This document provides step-by-step instructions for deploying the RSET Student Application with the new real-time admin portal, WebSocket synchronization, and PDF notice management system.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Mobile App (Flutter)                      │
│  - Attendance Tracking                                      │
│  - Marks Management                                         │
│  - PDF Notices                                              │
│  - Calendar Events                                          │
│  - WebSocket Real-time Sync                                │
└────────────┬────────────────────────────────┬───────────────┘
             │ HTTP/REST API                  │ WebSocket
             │                                │
┌────────────▼────────────────────────────────▼───────────────┐
│             Backend Server (Python/FastAPI)                 │
│  - RESTful API Endpoints                                    │
│  - WebSocket Server                                         │
│  - MongoDB Integration                                      │
│  - File Upload & Storage                                    │
└────────────┬────────────────────────────────────────────────┘
             │
     ┌───────▼────────┐
     │   MongoDB      │
     └────────────────┘
        
┌─────────────────────────────────────────────────────────────┐
│           Admin Web Dashboard (HTML/CSS/JS)                 │
│  - Login Portal                                             │
│  - Attendance Management                                    │
│  - Marks Management                                         │
│  - Notice Upload                                            │
│  - Event Management                                         │
└────────────┬────────────────────────────────────────────────┘
             │ HTTP/REST API
             │
        Backend Server
```

## Part 1: Backend Setup

### 1.1 Prerequisites

- Python 3.8+
- MongoDB 4.0+
- Node.js or Python's built-in HTTP server (for admin dashboard)
- Git

### 1.2 Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 1.3 Environment Configuration

Create a `.env` file in the `backend` directory:

```env
# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017
MONGODB_DB=college_sync

# API Configuration
SYNC_INTERVAL_MINUTES=30

# Admin Authentication
ADMIN_SECRET_KEY=your-secure-admin-secret-key-change-this-in-production

# CORS Configuration
CORS_ORIGINS=["http://localhost:3000", "http://localhost:8080", "http://your-ip:3000"]
```

**For Production:**
- Change `ADMIN_SECRET_KEY` to a strong random string
- Set `CORS_ORIGINS` to your actual domain
- Use a production MongoDB URI with authentication

### 1.4 Initialize MongoDB

```bash
# Start MongoDB service
# Windows
net start MongoDB

# Linux/Mac
sudo systemctl start mongod
```

Create database indexes:

```bash
# Connect to MongoDB
mongo

# Run in MongoDB shell
use college_sync
db.attendance.createIndex({class_code: 1, date: 1})
db.marks.createIndex({student_id: 1, class_code: 1})
db.notices.createIndex({is_exam_notice: 1, upload_date: -1})
db.events.createIndex({date: 1})
db.admins.createIndex({username: 1}, {unique: true})
```

### 1.5 Start Backend Server

```bash
cd backend
python main.py
```

The backend will start at `http://localhost:8000`

**API Health Check:**
```bash
curl http://localhost:8000/api/health
```

## Part 2: Admin Dashboard Setup

### 2.1 Running the Admin Dashboard

The admin dashboard is a standalone web application. You can run it using:

#### Option A: Direct File Access
- Open `admin-dashboard/index.html` directly in your browser

#### Option B: Local HTTP Server (Recommended)

```bash
# Navigate to admin-dashboard folder
cd admin-dashboard

# Using Python 3
python -m http.server 8080

# Using Python 2
python -m SimpleHTTPServer 8080

# Using Node.js (if installed)
npx http-server
```

Open: `http://localhost:8080`

### 2.2 Initial Admin Setup

1. Open admin dashboard in browser
2. You'll see an initialization screen since no admin exists yet
3. Create admin account with:
   - Name: Administrator
   - Username: admin
   - Password: (secure password)
4. Login with these credentials
5. You're now ready to manage data!

### 2.3 Admin Dashboard Features

**Attendance Management:**
- Add absence records (Date, Period, Subject Code, Class Code)
- Remove absence records
- View all absences by class

**Marks Management:**
- Add/update marks for students
- View student marks by ID and class code

**Notices:**
- Upload PDF notices (max 10MB)
- Categorize as regular or exam notices
- Delete notices
- All uploaded PDFs stored in `backend/uploads/notices/`

**Events:**
- Create events with date and description
- View all events
- Delete events
- Events automatically show in mobile app calendar

## Part 3: Mobile App (Flutter) Setup

### 3.1 Prerequisites

- Flutter 3.4.0+
- Android SDK / iOS SDK
- Android device or emulator / iOS simulator

### 3.2 Install Dependencies

```bash
cd .
flutter pub get
```

### 3.3 Configuration

Update `lib/data/api_service.dart` with your backend URL:

```dart
class ApiService {
  // For local testing on Android emulator:
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // For physical Android device (replace 192.168.x.x with your backend IP):
  // static const String baseUrl = 'http://192.168.1.100:8000/api';
  
  // For iOS simulator:
  // static const String baseUrl = 'http://localhost:8000/api';
  
  // For production:
  // static const String baseUrl = 'https://your-backend-domain.com/api';
}
```

Update `lib/data/websocket_service.dart` WebSocket URL:

```dart
class WebSocketService {
  // For local testing on Android emulator:
  static const String wsUrl = 'ws://10.0.2.2:8000/ws';
  
  // For production:
  // static const String wsUrl = 'wss://your-backend-domain.com/ws';
}
```

### 3.4 Build & Run

```bash
# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Build APK for distribution
flutter build apk --release

# Build iOS app
flutter build ios --release
```

### 3.5 APK Distribution

The built APK is located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

**Distribution methods:**
1. Email the APK file to students
2. Host on a server and provide download link
3. Use Android App Bundle for Google Play Store
4. Use TestFlight for iOS beta testing

Students can install the APK using:
- Sending via file transfer
- QR code download link
- Cloud storage (Google Drive, Dropbox)
- App distribution platform

## Part 4: Network Configuration

### 4.1 Local Network (LAN)

For testing within a network (office/campus):

1. Find backend machine IP:
```bash
# Windows
ipconfig | findstr "IPv4"

# Linux/Mac
ifconfig | grep "inet"
```

2. Update app configuration:
```dart
static const String baseUrl = 'http://192.168.1.100:8000/api';  // Replace with your IP
static const String wsUrl = 'ws://192.168.1.100:8000/ws';
```

3. Ensure firewall allows connections:
```bash
# Windows (allow port 8000)
netsh advfirewall firewall add rule name="FastAPI" dir=in action=allow protocol=tcp localport=8000
```

### 4.2 Public Internet (Production)

For deploying to the internet:

1. **Get a Domain:** Purchase or use free domain (freenom.com, noip.com)

2. **SSL Certificate:** Use Let's Encrypt
```bash
# Install Certbot
pip install certbot

# Generate certificate
certbot certonly --standalone -d yourdomain.com
```

3. **Update Backend:**
```bash
# main.py - add SSL context
import ssl
ssl_context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
ssl_context.load_cert_chain("path/to/cert.pem", "path/to/key.pem")

# Run with SSL
uvicorn.run(app, host="0.0.0.0", port=443, ssl_context=ssl_context)
```

4. **Update App Configuration:**
```dart
static const String baseUrl = 'https://yourdomain.com/api';
static const String wsUrl = 'wss://yourdomain.com/ws';  // Note: wss (secure WebSocket)
```

5. **Port Forwarding:** Forward ports 80 and 443 to your server on router

## Part 5: Real-Time Synchronization

### 5.1 WebSocket Connection Flow

```
Mobile App                              Backend Server
    │                                      │
    ├─── Connect WebSocket ───────────────>│
    │<─── Connection Confirmed ────────────┤
    │                                      │
    ├─── Subscribe to 'attendance' ──────>│
    │<─── Subscription Confirmed ─────────┤
    │                                      │
    │                                      │
Admin Portal (updates attendance)         │
    ├─── POST /api/admin/attendance/add ──>│
    │                                      │
Backend broadcasts update                 │
    │<─── WebSocket Message: attendance_updated ──│
    │                                      │
App receives update & refreshes UI
```

### 5.2 Supported Event Types

- `attendance_updated` - Attendance record changed
- `marks_updated` - Mark entry changed
- `notice_added` - New notice uploaded
- `event_added` - New calendar event created

### 5.3 Testing WebSocket Connection

Use WebSocket client to test:
```javascript
// In browser console or NodeJS
const ws = new WebSocket('ws://localhost:8000/ws');
ws.onmessage = (event) => console.log(event.data);
ws.send(JSON.stringify({action: 'subscribe', channel: 'attendance'}));
```

## Part 6: Data Management

### 6.1 Backup MongoDB

```bash
# Create backup
mongodump --db college_sync --out ./backup

# Restore from backup
mongorestore --db college_sync ./backup/college_sync
```

### 6.2 PDF Storage

PDFs are stored at: `backend/uploads/notices/`

Organize by date:
```
uploads/
└── notices/
    ├── 2026-07-notice.pdf
    ├── 2026-08-notice.pdf
    └── 2026-09-notice.pdf
```

Ensure sufficient disk space and regular backups!

### 6.3 Database Maintenance

Monitor database size:
```javascript
db.stats()  // In MongoDB shell
```

Archive old data:
```javascript
// Archive attendance older than 1 year
db.attendance.deleteMany({
  created_at: {$lt: new Date(Date.now() - 365*24*60*60*1000)}
})
```

## Part 7: Troubleshooting

### Issue: WebSocket Connection Failed

**Solution:**
1. Check backend is running: `curl http://localhost:8000/api/health`
2. Check firewall allows port 8000
3. Verify WebSocket URL in app configuration
4. Check browser console for errors (admin dashboard)

### Issue: File Upload Fails

**Solution:**
1. Ensure `backend/uploads/notices/` directory exists
2. Check disk space available
3. Verify file size < 10MB
4. Check file permissions

### Issue: Android Emulator Can't Connect

**Solution:**
- Use `10.0.2.2` instead of `localhost`
- If still failing, try `192.168.1.x` (your backend IP on network)

### Issue: CORS Errors

**Solution:**
Update `backend/main.py` CORS configuration:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8080", "http://your-ip:8080"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Issue: Database Connection Refused

**Solution:**
1. Check MongoDB is running
2. Verify MONGODB_URI in .env
3. Check MongoDB username/password if using auth

## Part 8: Security Best Practices

### 8.1 Production Checklist

- [ ] Change `ADMIN_SECRET_KEY` to random string
- [ ] Use strong admin password
- [ ] Enable MongoDB authentication
- [ ] Use HTTPS/SSL certificates
- [ ] Set CORS origins to specific domains only
- [ ] Implement rate limiting
- [ ] Regular backups scheduled
- [ ] Firewall configured
- [ ] Port 8000 not exposed unnecessarily

### 8.2 Password Security

```python
# In admin_auth_service.py - passwords are already hashed with bcrypt
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
hashed_password = pwd_context.hash(plain_password)
```

### 8.3 API Key Rotation

Change `ADMIN_SECRET_KEY` periodically:
```bash
# Generate new key
python -c "import secrets; print(secrets.token_urlsafe(32))"

# Update .env
ADMIN_SECRET_KEY=new-generated-key

# Restart backend
```

## Part 9: Performance Optimization

### 9.1 Database Indexes

Already created in 1.4, but for additional optimization:

```javascript
// Add index for faster queries
db.attendance.createIndex({class_code: 1, date: -1})
db.marks.createIndex({class_code: 1, subject_code: 1})
db.notices.createIndex({upload_date: -1})
```

### 9.2 Caching

Enable client-side caching in Flutter:
```dart
// Already implemented in API service with timeout
.timeout(const Duration(seconds: 10))
```

### 9.3 Connection Pooling

MongoDB motor already handles connection pooling automatically.

## Part 10: Monitoring & Logging

### 10.1 Enable Logging

```python
# In main.py
import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

logger.info("Application started")
logger.error("Error occurred: ", exc_info=True)
```

### 10.2 Monitor Server Health

```bash
# Check process
ps aux | grep "python main.py"

# Check port
netstat -an | grep 8000

# Monitor logs
tail -f server.log
```

## Part 11: Contact & Support

For issues or questions:
1. Check this deployment guide
2. Review backend logs for errors
3. Check WebSocket connection in browser console
4. Verify network configuration
5. Test API endpoints with Postman/curl

---

## Quick Start Summary

```bash
# 1. Backend
cd backend
pip install -r requirements.txt
python main.py

# 2. Admin Dashboard (new terminal)
cd admin-dashboard
python -m http.server 8080

# 3. Mobile App (new terminal)
cd .
flutter run

# 4. Admin Setup
# - Open http://localhost:8080
# - Create admin account
# - Start managing data!
```

---

**Created:** 2026-08-03  
**Version:** 1.0.0
