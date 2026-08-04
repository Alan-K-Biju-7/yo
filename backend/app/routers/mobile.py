from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.database.connection import get_db
from app.repositories.attendance import AttendanceRepository
from app.repositories.events import EventsRepository
from app.repositories.marks import MarksRepository
from app.repositories.notices import NoticesRepository
from app.services.auth_service import decode_token


router = APIRouter(prefix="/mobile", tags=["mobile"])
security = HTTPBearer()


async def current_student(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> dict:
    try:
        username = decode_token(credentials.credentials).get("sub")
    except Exception:
        username = None
    if not username:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )

    user = await get_db().users.find_one({"username": username})
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Student account no longer exists",
        )
    return user


@router.get("/attendance/{class_code}")
async def attendance(class_code: str, user: dict = Depends(current_student)):
    return await AttendanceRepository(get_db()).get_absences_by_class(class_code)


@router.get("/marks/{class_code}")
async def marks(class_code: str, user: dict = Depends(current_student)):
    student_id = str(user.get("student_id") or user.get("username"))
    records = await MarksRepository(get_db()).get_marks_by_student(
        student_id, class_code
    )
    return {
        "student_id": student_id,
        "marks": [
            {"subject_code": record["subject_code"], "mark": record["mark"]}
            for record in records
        ],
    }


@router.get("/notices")
async def notices(is_exam: bool = False, user: dict = Depends(current_student)):
    return await NoticesRepository(get_db()).get_all_notices(is_exam)


@router.get("/events")
async def events(
    date: str | None = None,
    user: dict = Depends(current_student),
):
    repository = EventsRepository(get_db())
    if date:
        return await repository.get_events_by_date(date)
    return await repository.get_all_events()
