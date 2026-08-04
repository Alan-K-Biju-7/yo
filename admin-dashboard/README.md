# Admin Dashboard

A web-based admin portal for managing student data in the RSET Student Application.

## Features

- **Attendance Management**: Add and remove absence records for students
- **Marks Management**: Add, update, and view student marks
- **Notices**: Upload PDF notices (regular and exam notices)
- **Events**: Create and manage calendar events

## Getting Started

### Prerequisites
- Backend server running at `http://localhost:8000`
- Modern web browser (Chrome, Firefox, Safari, Edge)

### Installation

1. Open `index.html` in your web browser
2. On first login, create an admin account
3. Use the credentials to log in

### Running the Admin Dashboard

#### Option 1: Direct File
Simply open `index.html` in your browser.

#### Option 2: Local Server (Recommended)
To avoid CORS issues, run a local server:

```bash
# Using Python 3
python -m http.server 8080

# Using Python 2
python -m SimpleHTTPServer 8080

# Using Node.js (if you have http-server installed)
http-server
```

Then open `http://localhost:8080` in your browser.

## API Endpoints

### Authentication
- `POST /api/admin/init-admin` - Initialize first admin account
- `POST /api/admin/login` - Admin login

### Attendance
- `POST /api/admin/attendance/add` - Add absence record
- `POST /api/admin/attendance/remove` - Remove absence record
- `GET /api/admin/attendance/{class_code}` - Get absences by class

### Marks
- `POST /api/admin/marks/add` - Add/update mark
- `GET /api/admin/marks/{student_id}/{class_code}` - Get student marks

### Notices
- `POST /api/admin/notices/upload` - Upload PDF notice
- `GET /api/admin/notices?is_exam={bool}` - Get all notices
- `DELETE /api/admin/notices/{notice_id}` - Delete notice

### Events
- `POST /api/admin/events/create` - Create event
- `GET /api/admin/events` - Get all events
- `DELETE /api/admin/events/{event_id}` - Delete event

## Configuration

Edit the `API_BASE_URL` in `script.js` if your backend is running on a different host:

```javascript
const API_BASE_URL = "http://your-backend-url:8000/api";
```

## Troubleshooting

### CORS Errors
If you see CORS errors, make sure:
1. Backend is running with CORS enabled
2. You're accessing the dashboard from a compatible origin
3. Try running the dashboard on a local server (Option 2 above)

### File Upload Issues
- Maximum PDF size: 10MB
- Only `.pdf` files are accepted
- Ensure the `uploads` folder exists on the backend

### WebSocket Connection Issues
The mobile app connects via WebSocket at:
- `ws://your-backend-url:8000/ws`

Make sure your WebSocket connection is properly configured in the Flutter app.

## Development

To modify the dashboard:

1. **HTML**: Edit `index.html` for structure
2. **CSS**: Edit `styles.css` for styling
3. **JavaScript**: Edit `script.js` for functionality

All changes take effect immediately on page reload.
