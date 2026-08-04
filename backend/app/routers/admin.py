import os
from fastapi import APIRouter, Depends, HTTPException, status, File, UploadFile, Form
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from app.database.connection import get_db
from app.services import admin_auth_service
from app.services.websocket_manager import manager
from app.repositories.attendance import AttendanceRepository
from app.repositories.marks import MarksRepository
from app.repositories.notices import NoticesRepository
from app.repositories.events import EventsRepository
from app.repositories.admin import AdminRepository
from app.schemas.models import (
    AdminLogin, AdminCreate, StudentCredentialUpsert, AttendanceEntry, AttendanceDelete,
    MarksEntry, NoticeCreate, EventCreate, WSMessage
)
from bson import ObjectId
from motor.motor_asyncio import AsyncIOMotorGridFSBucket

router = APIRouter(prefix="/admin", tags=["admin"])
security = HTTPBearer()

async def verify_admin_token(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> str:
    """Verify admin token"""
    token = credentials.credentials
    username = admin_auth_service.verify_admin_token(token)
    if not username:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )
    return username


@router.post("/init-admin")
async def init_admin(admin_data: AdminCreate):
    """Initialize admin account (only works if no admin exists)"""
    db = get_db()
    repo = AdminRepository(db)
    
    if await repo.admin_exists():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Admin account already exists"
        )
    
    admin_id = await admin_auth_service.create_admin_user(
        admin_data.username,
        admin_data.password,
        admin_data.name
    )
    
    if not admin_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Failed to create admin account"
        )
    
    return {"admin_id": admin_id, "message": "Admin account created successfully"}


@router.post("/login")
async def admin_login(login_data: AdminLogin):
    """Admin login endpoint"""
    admin = await admin_auth_service.authenticate_admin(
        login_data.username,
        login_data.password
    )
    
    if not admin:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials"
        )
    
    access_token = admin_auth_service.create_admin_access_token(
        {"sub": admin["username"]}
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "admin_name": admin.get("name", "Admin")
    }


@router.put("/students/credentials")
async def upsert_student_credentials(
    entry: StudentCredentialUpsert,
    username: str = Depends(verify_admin_token),
):
    """Create or update a student's app login credentials."""
    from app.services.auth_service import get_password_hash

    db = get_db()
    await db.users.update_one(
        {"username": entry.username},
        {
            "$set": {
                "username": entry.username,
                "password_hash": get_password_hash(entry.password),
                "student_id": entry.student_id,
            }
        },
        upsert=True,
    )
    return {"username": entry.username, "message": "Student credentials saved"}


# ==================== ATTENDANCE ENDPOINTS ====================

@router.post("/attendance/add")
async def add_absence(entry: AttendanceEntry, username: str = Depends(verify_admin_token)):
    """Add an absence record"""
    db = get_db()
    repo = AttendanceRepository(db)
    
    absence_id = await repo.add_absence(
        entry.date,
        entry.period,
        entry.subject_code,
        entry.class_code
    )
    
    # Broadcast update via WebSocket
    await manager.broadcast_to_channel("attendance", WSMessage(
        type="attendance_updated",
        data={
            "class_code": entry.class_code,
            "date": entry.date,
            "period": entry.period,
            "subject_code": entry.subject_code,
            "action": "added"
        }
    ))
    
    return {"id": absence_id, "message": "Absence added successfully"}


@router.post("/attendance/remove")
async def remove_absence(entry: AttendanceDelete, username: str = Depends(verify_admin_token)):
    """Remove an absence record"""
    db = get_db()
    repo = AttendanceRepository(db)
    
    success = await repo.remove_absence(entry.date, entry.period, entry.class_code)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Absence record not found"
        )
    
    # Broadcast update via WebSocket
    await manager.broadcast_to_channel("attendance", WSMessage(
        type="attendance_updated",
        data={
            "class_code": entry.class_code,
            "date": entry.date,
            "period": entry.period,
            "action": "removed"
        }
    ))
    
    return {"message": "Absence removed successfully"}


@router.get("/attendance/{class_code}")
async def get_absences(class_code: str, username: str = Depends(verify_admin_token)):
    """Get all absences for a class"""
    db = get_db()
    repo = AttendanceRepository(db)
    
    absences = await repo.get_absences_by_class(class_code)
    return absences


# ==================== MARKS ENDPOINTS ====================

@router.post("/marks/add")
async def add_or_update_mark(entry: MarksEntry, username: str = Depends(verify_admin_token)):
    """Add or update a mark"""
    db = get_db()
    repo = MarksRepository(db)
    
    await repo.create_or_update_mark(
        entry.class_code,
        entry.subject_code,
        entry.student_id,
        entry.mark
    )
    
    # Broadcast update via WebSocket
    await manager.broadcast_to_channel("marks", WSMessage(
        type="marks_updated",
        data={
            "student_id": entry.student_id,
            "class_code": entry.class_code,
            "subject_code": entry.subject_code,
            "mark": entry.mark,
        }
    ))
    
    return {"message": "Mark saved successfully"}


@router.get("/marks/{student_id}/{class_code}")
async def get_student_marks(student_id: str, class_code: str, username: str = Depends(verify_admin_token)):
    """Get marks for a student"""
    db = get_db()
    repo = MarksRepository(db)
    
    marks = await repo.get_marks_by_student(student_id, class_code)
    return {
        "student_id": student_id,
        "marks": [
            {
                "subject_code": mark["subject_code"],
                "mark": mark["mark"],
            }
            for mark in marks
        ],
    }


# ==================== NOTICES ENDPOINTS ====================

@router.post("/notices/upload")
async def upload_notice(
    title: str = Form(...),
    is_exam_notice: bool = Form(False),
    file: UploadFile = File(...),
    username: str = Depends(verify_admin_token)
):
    """Upload a notice PDF"""
    
    # Validate file
    if not file.filename.endswith('.pdf'):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only PDF files are allowed"
        )
    
    # Check file size (max 10MB)
    contents = await file.read()
    if len(contents) > 10 * 1024 * 1024:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File size must be less than 10MB"
        )
    
    db = get_db()
    bucket = AsyncIOMotorGridFSBucket(db)
    file_id = await bucket.upload_from_stream(
        file.filename,
        contents,
        metadata={"content_type": "application/pdf"},
    )
    file_url = f"/api/files/{file_id}"

    # Save notice metadata to the database.
    repo = NoticesRepository(db)
    notice_id = await repo.create_notice(
        title,
        file_url,
        is_exam_notice,
        str(file_id),
    )
    
    # Broadcast update via WebSocket
    await manager.broadcast_to_channel("notices", WSMessage(
        type="notice_added",
        data={
            "id": notice_id,
            "title": title,
            "file_url": file_url,
            "is_exam_notice": is_exam_notice,
        }
    ))
    
    return {
        "id": notice_id,
        "message": "Notice uploaded successfully"
    }


@router.get("/notices")
async def get_all_notices(is_exam: bool = False, username: str = Depends(verify_admin_token)):
    """Get all notices"""
    db = get_db()
    repo = NoticesRepository(db)
    
    notices = await repo.get_all_notices(is_exam)
    return notices


@router.delete("/notices/{notice_id}")
async def delete_notice(notice_id: str, username: str = Depends(verify_admin_token)):
    """Delete a notice"""
    db = get_db()
    repo = NoticesRepository(db)
    
    notice = await repo.get_notice(notice_id)
    if not notice:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notice not found"
        )
    
    # Delete the persistent GridFS file when present. Older local-file notices
    # remain compatible and can still be removed from the metadata collection.
    if notice.get("file_id"):
        bucket = AsyncIOMotorGridFSBucket(db)
        await bucket.delete(ObjectId(notice["file_id"]))
    
    # Delete from database
    await repo.delete_notice(notice_id)
    
    return {"message": "Notice deleted successfully"}


# ==================== EVENTS ENDPOINTS ====================

@router.post("/events/create")
async def create_event(event: EventCreate, username: str = Depends(verify_admin_token)):
    """Create a new event"""
    db = get_db()
    repo = EventsRepository(db)
    
    event_id = await repo.create_event(
        event.title,
        event.date,
        event.description
    )
    
    # Broadcast update via WebSocket
    await manager.broadcast_to_channel("events", WSMessage(
        type="event_added",
        data={
            "id": event_id,
            "title": event.title,
            "date": event.date,
            "description": event.description,
        }
    ))
    
    return {"id": event_id, "message": "Event created successfully"}


@router.get("/events")
async def get_all_events(username: str = Depends(verify_admin_token)):
    """Get all events"""
    db = get_db()
    repo = EventsRepository(db)
    
    events = await repo.get_all_events()
    return events


@router.get("/events/dates-with-events")
async def get_event_dates(username: str = Depends(verify_admin_token)):
    """Get all dates that have events"""
    db = get_db()
    repo = EventsRepository(db)
    
    dates = await repo.get_dates_with_events()
    return {"dates": dates}


@router.delete("/events/{event_id}")
async def delete_event(event_id: str, username: str = Depends(verify_admin_token)):
    """Delete an event"""
    db = get_db()
    repo = EventsRepository(db)
    
    success = await repo.delete_event(event_id)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found"
        )
    
    return {"message": "Event deleted successfully"}
