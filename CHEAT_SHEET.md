# 🚀 Command Cheat Sheet

## Installation & Setup

### Backend
```bash
# Install Python dependencies
cd backend
pip install -r requirements.txt

# Create .env file
echo MONGODB_URI=mongodb://localhost:27017 > .env
echo MONGODB_DB=college_sync >> .env
echo ADMIN_SECRET_KEY=your-secret-key >> .env

# Start backend server
python main.py
# ✅ Backend running at: http://localhost:8000
```

### Admin Dashboard
```bash
# Navigate to admin folder
cd admin-dashboard

# Start HTTP server (Python 3)
python -m http.server 8080

# Or with Node.js
npx http-server

# ✅ Admin portal at: http://localhost:8080
```

### Mobile App
```bash
# Get dependencies
flutter pub get

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Build APK
flutter build apk --release
# ✅ Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Quick Testing

### Test Backend API
```bash
# Check health
curl http://localhost:8000/api/health

# Create admin (first time only)
curl -X POST http://localhost:8000/api/admin/init-admin \
  -H "Content-Type: application/json" \
  -d '{"name":"Admin","username":"admin","password":"password"}'

# Login
curl -X POST http://localhost:8000/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}'
```

### Test WebSocket (Browser Console)
```javascript
const ws = new WebSocket('ws://localhost:8000/ws');
ws.onopen = () => console.log('Connected!');
ws.onmessage = (e) => console.log(e.data);
ws.send(JSON.stringify({action: 'subscribe', channel: 'attendance'}));
```

---

## Configuration Commands

### Update API URLs (For Different Environments)

**For Android Emulator:**
```dart
// lib/data/api_service.dart
static const String baseUrl = 'http://10.0.2.2:8000/api';

// lib/data/websocket_service.dart
static const String wsUrl = 'ws://10.0.2.2:8000/ws';
```

**For Your Local IP (Replace 192.168.1.100):**
```bash
# Find your IP
ipconfig | findstr "IPv4"  # Windows
ifconfig | grep "inet"     # Linux/Mac
```

```dart
static const String baseUrl = 'http://192.168.1.100:8000/api';
static const String wsUrl = 'ws://192.168.1.100:8000/ws';
```

**For Production (Replace yourdomain.com):**
```dart
static const String baseUrl = 'https://yourdomain.com/api';
static const String wsUrl = 'wss://yourdomain.com/ws';
```

---

## MongoDB Commands

### Connect to MongoDB
```bash
mongo
# or MongoDB 5.0+
mongosh
```

### Create Indexes
```javascript
use college_sync
db.attendance.createIndex({class_code: 1, date: 1})
db.marks.createIndex({student_id: 1, class_code: 1})
db.notices.createIndex({is_exam_notice: 1, upload_date: -1})
db.events.createIndex({date: 1})
db.admins.createIndex({username: 1}, {unique: true})
```

### View Collections
```javascript
show collections
db.attendance.count()
db.marks.count()
db.notices.find().pretty()
```

### Backup Database
```bash
mongodump --db college_sync --out ./backup
```

### Restore Database
```bash
mongorestore --db college_sync ./backup/college_sync
```

---

## Troubleshooting Commands

### Check if Port is in Use
```bash
# Windows
netstat -ano | findstr :8000

# Linux/Mac
lsof -i :8000
```

### Kill Process on Port
```bash
# Linux/Mac
sudo kill -9 <PID>

# Windows
taskkill /PID <PID> /F
```

### Check MongoDB Status
```bash
# Windows
net start MongoDB        # Start
net stop MongoDB         # Stop

# Linux
sudo systemctl status mongod
sudo systemctl start mongod
sudo systemctl stop mongod

# Mac
brew services start mongodb-community
brew services stop mongodb-community
```

### View Backend Logs
```bash
# If using output redirection
tail -f backend.log

# On Linux/Mac
grep ERROR backend.log
grep WARNING backend.log
```

---

## File Paths Reference

### Backend
- Main app: `backend/main.py`
- API routes: `backend/app/routers/admin.py`
- Database: `backend/app/database/connection.py`
- Uploads: `backend/uploads/notices/`
- Config: `backend/.env`

### Admin Dashboard
- HTML: `admin-dashboard/index.html`
- Styles: `admin-dashboard/styles.css`
- Logic: `admin-dashboard/script.js`

### Mobile App
- Main: `lib/main.dart`
- API: `lib/data/api_service.dart`
- WebSocket: `lib/data/websocket_service.dart`
- Features: `lib/features/*/`

---

## Environment Variables

### Backend .env Template
```env
# MongoDB
MONGODB_URI=mongodb://localhost:27017
MONGODB_DB=college_sync

# Admin Auth
ADMIN_SECRET_KEY=your-super-secret-key-change-in-production

# Sync
SYNC_INTERVAL_MINUTES=30

# CORS
CORS_ORIGINS=["http://localhost:3000","http://localhost:8080"]
```

---

## API Quick Reference

### Admin Endpoints
```
POST   /api/admin/init-admin              Create first admin
POST   /api/admin/login                   Admin login
POST   /api/admin/attendance/add          Add absence
POST   /api/admin/attendance/remove       Remove absence
GET    /api/admin/attendance/{class}      Get absences
POST   /api/admin/marks/add               Add mark
GET    /api/admin/marks/{id}/{class}      Get marks
POST   /api/admin/notices/upload          Upload PDF
GET    /api/admin/notices                 Get notices
DELETE /api/admin/notices/{id}            Delete notice
POST   /api/admin/events/create           Create event
GET    /api/admin/events                  Get events
DELETE /api/admin/events/{id}             Delete event
WS     /ws                                WebSocket
```

---

## Build Commands

### Flutter
```bash
# Clean build
flutter clean
flutter pub get

# Run in debug mode
flutter run

# Build APK (release)
flutter build apk --release

# Build app bundle
flutter build appbundle --release

# Build iOS
flutter build ios --release
```

### Python/Backend
```bash
# Install dependencies
pip install -r requirements.txt

# Update pip
pip install --upgrade pip

# Check Python version
python --version

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows
```

---

## Common Issues & Fixes

### Port Already in Use
```bash
# Find process using port 8000
lsof -i :8000              # Linux/Mac
netstat -ano | findstr :8000  # Windows

# Kill it
kill -9 <PID>              # Linux/Mac
taskkill /PID <PID> /F     # Windows

# Use different port
python main.py --port 8001  # (if supported)
```

### MongoDB Connection Refused
```bash
# Check if MongoDB is running
systemctl status mongod

# Start MongoDB
systemctl start mongod

# Or with Brew (Mac)
brew services start mongodb-community
```

### CORS Errors in Admin Dashboard
```bash
# This means backend CORS is not configured
# Check backend/main.py has:
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # or specific domains
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### WebSocket Connection Fails
```bash
# Check backend is running
curl http://localhost:8000/api/health

# Check firewall allows port 8000
# Windows Firewall:
netsh advfirewall firewall add rule name="FastAPI" dir=in action=allow protocol=tcp localport=8000

# Verify WebSocket URL is correct
# Should be: ws://localhost:8000/ws (not http)
```

### Flutter App Can't Connect on Emulator
```bash
# Use special IP for Android emulator
static const String baseUrl = 'http://10.0.2.2:8000/api';

# For iOS simulator
static const String baseUrl = 'http://localhost:8000/api';

# For physical device on same network
static const String baseUrl = 'http://192.168.1.X:8000/api';  # Your backend IP
```

---

## Production Deployment Quick Steps

```bash
# 1. Update configuration
# Edit backend/.env with production values
ADMIN_SECRET_KEY=<strong-random-key>
MONGODB_URI=<production-mongodb>
CORS_ORIGINS=["https://yourdomain.com"]

# 2. Generate SSL certificate (Let's Encrypt)
certbot certonly --standalone -d yourdomain.com

# 3. Update app configuration
# Edit lib/data/api_service.dart
static const String baseUrl = 'https://yourdomain.com/api';
static const String wsUrl = 'wss://yourdomain.com/ws';

# 4. Build and deploy
flutter build apk --release
# Share build/app/outputs/flutter-apk/app-release.apk

# 5. Run backend with SSL
# (See DEPLOYMENT_GUIDE.md Part 4 for details)
```

---

## Useful Links

- Python Docs: https://docs.python.org/3/
- Flutter Docs: https://flutter.dev/docs
- FastAPI Docs: https://fastapi.tiangolo.com/
- MongoDB Docs: https://docs.mongodb.com/
- WebSocket: https://en.wikipedia.org/wiki/WebSocket

---

## Emergency Commands

```bash
# Kill all Python processes
pkill -f "python main.py"

# Clear Flutter cache
flutter clean
rm -rf build/

# Reset Flutter
flutter clean
flutter pub get
flutter run

# Clear admin dashboard cache (browser)
# Press: Ctrl+Shift+Delete
# Clear: Cookies and Cached Images and Files

# Reset MongoDB (dangerous!)
mongo
use college_sync
db.dropDatabase()
```

---

**Keep this handy for quick reference!** 📋
