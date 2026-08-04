# RSET Student Application - Complete System

A comprehensive digital platform for RSET College student information management with real-time synchronization, admin portal, and mobile application.

## 📱 Features

### Mobile App (Flutter)

✅ **Authentication**
- Secure login system
- Session management
- Local credential storage

✅ **Attendance Tracking**
- View absence records by class
- Organized by date and period
- Subject code display for each absence
- Real-time updates via WebSocket

✅ **Marks Management**
- Internal exam marks
- Assignment marks
- Subject-wise performance tracking
- Multiple exam types support

✅ **PDF Notices**
- Regular notices
- Exam notices
- Date-based organization
- Quick PDF access

✅ **Academic Calendar**
- Monthly calendar view
- Event indicators (black dots)
- Event details on selected date
- Real-time event updates

✅ **Additional Features**
- Late arrivals tracking
- Academic documents
- Profile management
- Offline-capable with sync

### Admin Web Portal

✅ **Attendance Management**
- Add absence records (date, period, subject code, class)
- Remove incorrect records
- View all absences by class

✅ **Marks Management**
- Add/update student marks
- Bulk operations support
- View marks by student and class

✅ **Notice Management**
- Upload PDF notices (max 10MB)
- Categorize as regular or exam notices
- Delete notices
- Track upload dates

✅ **Event Management**
- Create calendar events
- Set event descriptions
- View all events
- Delete events
- Automatic mobile app sync

✅ **Real-time Features**
- WebSocket-based instant updates
- Admin actions immediately visible on mobile
- Live attendance synchronization
- Instant notice availability

### Backend API

✅ **RESTful Endpoints**
- Attendance CRUD operations
- Marks management
- Notice handling with PDF upload
- Event management
- Admin authentication

✅ **WebSocket Support**
- Real-time event broadcasting
- Channel-based subscriptions
- Instant data synchronization

✅ **Database**
- MongoDB integration
- Efficient data storage
- Automatic indexing
- Backup support

## 📁 Project Structure

```
Project Root/
│
├── backend/                          # Python/FastAPI Backend
│   ├── app/
│   │   ├── api/
│   │   │   └── router.py            # Main API router
│   │   ├── database/
│   │   │   └── connection.py        # MongoDB connection
│   │   ├── models/                  # (Placeholder)
│   │   ├── repositories/            # Data access layer
│   │   │   ├── attendance.py        # Attendance queries
│   │   │   ├── marks.py             # Marks queries
│   │   │   ├── notices.py           # Notice queries
│   │   │   ├── events.py            # Event queries
│   │   │   ├── admin.py             # Admin user queries
│   │   │   ├── students.py          # Student queries
│   │   │   ├── subjects.py          # Subject queries
│   │   │   ├── results.py           # Result queries
│   │   │   └── internal_marks.py    # Mark queries
│   │   ├── routers/
│   │   │   ├── auth.py              # Authentication
│   │   │   ├── admin.py             # Admin operations
│   │   │   ├── marks.py             # Marks endpoints
│   │   │   ├── profile.py           # Profile endpoints
│   │   │   ├── results.py           # Results endpoints
│   │   │   ├── sync.py              # Sync endpoints
│   │   │   └── websocket.py         # WebSocket endpoint
│   │   ├── schemas/
│   │   │   └── models.py            # Pydantic models
│   │   ├── services/
│   │   │   ├── auth_service.py      # Auth logic
│   │   │   ├── admin_auth_service.py# Admin auth logic
│   │   │   ├── sync_service.py      # Sync logic
│   │   │   └── websocket_manager.py # WebSocket manager
│   │   └── utils/                   # Utility functions
│   ├── main.py                      # FastAPI app entry point
│   ├── requirements.txt             # Python dependencies
│   └── uploads/                     # Uploaded files (PDFs)
│       └── notices/
│
├── admin-dashboard/                 # Web-based Admin Portal
│   ├── index.html                   # Admin UI
│   ├── styles.css                   # Styling
│   ├── script.js                    # Admin functionality
│   └── README.md                    # Admin dashboard docs
│
├── lib/                             # Flutter Mobile App
│   ├── main.dart                    # App entry point
│   ├── app.dart                     # App configuration
│   ├── core/
│   │   ├── session/                 # Session management
│   │   ├── theme/                   # App theming
│   │   └── widgets/                 # Reusable widgets
│   ├── data/
│   │   ├── api_service.dart         # REST API calls
│   │   ├── websocket_service.dart   # WebSocket client
│   │   └── reference_data.dart      # Static data
│   ├── features/
│   │   ├── attendance/              # Attendance page
│   │   ├── auth/                    # Login page
│   │   ├── calendar/                # Calendar page
│   │   ├── documents/               # Documents page
│   │   ├── home/                    # Home page
│   │   ├── late_arrivals/           # Late arrivals page
│   │   ├── marks/                   # Marks page
│   │   ├── notices/                 # Notices page
│   │   └── profile/                 # Profile page
│   └── test/                        # Test files
│
├── assets/                          # Static assets
│   └── images/                      # App images
│
├── android/                         # Android build files
│   └── app/                         # Android app config
│
├── pubspec.yaml                     # Flutter dependencies
├── analysis_options.yaml            # Dart lint config
├── DEPLOYMENT_GUIDE.md              # Deployment instructions
└── README.md                        # Project documentation
```

## 🚀 Quick Start

### Prerequisites
- Flutter 3.4.0+
- Python 3.8+
- MongoDB 4.0+
- Node.js (optional, for admin dashboard)

### 1. Backend Setup

```bash
cd backend
pip install -r requirements.txt
python main.py
```

Backend runs at: `http://localhost:8000`

### 2. Admin Dashboard

```bash
cd admin-dashboard
python -m http.server 8080
```

Dashboard at: `http://localhost:8080`

### 3. Mobile App

```bash
flutter pub get
flutter run
```

## 📊 API Endpoints

### Authentication
- `POST /api/admin/login` - Admin login
- `POST /api/admin/init-admin` - Create first admin account

### Attendance
- `POST /api/admin/attendance/add` - Add absence
- `POST /api/admin/attendance/remove` - Remove absence
- `GET /api/admin/attendance/{class_code}` - Get absences

### Marks
- `POST /api/admin/marks/add` - Add/update mark
- `GET /api/admin/marks/{student_id}/{class_code}` - Get marks

### Notices
- `POST /api/admin/notices/upload` - Upload PDF
- `GET /api/admin/notices?is_exam={bool}` - Get notices
- `DELETE /api/admin/notices/{notice_id}` - Delete notice

### Events
- `POST /api/admin/events/create` - Create event
- `GET /api/admin/events` - Get all events
- `DELETE /api/admin/events/{event_id}` - Delete event

### WebSocket
- `WS /ws` - WebSocket connection for real-time updates

## 🔄 Real-Time Synchronization

When admin updates data, mobile app instantly receives updates via WebSocket:

```
Admin Portal → API Endpoint → WebSocket Broadcast → Mobile App Updates UI
```

Supported events:
- `attendance_updated` - Attendance changed
- `marks_updated` - Marks changed
- `notice_added` - New notice uploaded
- `event_added` - New event created

## 🛡️ Security Features

- ✅ JWT-based admin authentication
- ✅ Bcrypt password hashing
- ✅ CORS protection
- ✅ Secure WebSocket connections
- ✅ MongoDB indexing for performance
- ✅ File upload validation (PDF only, 10MB max)

## 📱 Supported Platforms

- **Mobile:** Android 5.0+ (iOS support ready)
- **Admin Dashboard:** All modern browsers (Chrome, Firefox, Safari, Edge)
- **Backend:** Linux, Windows, macOS

## 🎨 Responsive Design

- **Mobile App:** Optimized for all screen sizes
- **Admin Dashboard:** Responsive CSS grid layout
- **Tables:** Horizontal scroll on small screens
- **Forms:** Auto-adjusting input fields

No pixel overflow or text formatting issues across devices ✓

## 📦 Dependencies

### Backend (Python)
- FastAPI 0.111.0+
- Motor 3.5.0+ (Async MongoDB)
- Uvicorn 0.30.0+
- Pydantic 2.7.0+
- python-jose with cryptography
- passlib with bcrypt
- websockets 12.0+
- python-multipart 0.0.6+

### Frontend (Flutter)
- Flutter SDK 3.4.0+
- shared_preferences 2.5.3+
- http 1.1.0+
- web_socket_channel 2.4.0+

### Admin Dashboard
- Pure HTML5/CSS3/JavaScript
- No framework dependencies
- Works offline (with local storage)

## 📖 Documentation

- [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) - Full deployment instructions
- [admin-dashboard/README.md](./admin-dashboard/README.md) - Admin portal guide

## 🤝 Contributing

All code follows Flutter and Python best practices:
- Clean architecture with layered structure
- Responsive design principles
- Real-time synchronization patterns
- Error handling and validation

## 📝 Version

**v1.0.0** - Initial Release (2026-08-03)

## 📧 Contact

For deployment issues, refer to DEPLOYMENT_GUIDE.md section 11: Contact & Support

## 📄 License

Internal Use - RSET College

---

**Ready to Deploy!** Follow the [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for complete setup instructions.
