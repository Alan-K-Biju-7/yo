from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime


class Subject(BaseModel):
    code: str
    name: str


class InternalMark(BaseModel):
    subject_code: str
    mark: str


class ResultRecord(BaseModel):
    subject_code: str
    grade: str


class StudentProfile(BaseModel):
    student_id: str = Field(..., alias="_id")
    name: Optional[str]
    class_code: Optional[str]
    department: Optional[str]
    email: Optional[str]
    phone: Optional[str]


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    username: Optional[str] = None


# Admin Models
class AdminCreate(BaseModel):
    username: str
    password: str
    name: str


class AdminLogin(BaseModel):
    username: str
    password: str


class StudentCredentialUpsert(BaseModel):
    username: str
    password: str
    student_id: str


# Attendance Models
class AttendanceEntry(BaseModel):
    date: str  # Format: MM/DD/YYYY
    period: int  # 1-7
    subject_code: str
    class_code: str


class AttendanceDelete(BaseModel):
    date: str
    period: int
    class_code: str


# Marks Models
class MarksEntry(BaseModel):
    class_code: str
    subject_code: str
    student_id: str
    mark: str


# Notice Models
class NoticeCreate(BaseModel):
    title: str
    is_exam_notice: bool = False


class NoticeResponse(BaseModel):
    id: str = Field(..., alias="_id")
    title: str
    file_url: str
    upload_date: datetime
    is_exam_notice: bool


# Event Models
class EventCreate(BaseModel):
    title: str
    date: str  # Format: MM/DD/YYYY
    description: Optional[str] = None


class EventResponse(BaseModel):
    id: str = Field(..., alias="_id")
    title: str
    date: str
    description: Optional[str]
    created_at: datetime


# WebSocket Message Models
class WSMessage(BaseModel):
    type: str  # "attendance_updated", "marks_updated", "notice_added", "event_added"
    data: dict
