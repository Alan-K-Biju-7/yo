from motor.motor_asyncio import AsyncIOMotorDatabase
from bson.objectid import ObjectId
from datetime import datetime


class MarksRepository:
    def __init__(self, db: AsyncIOMotorDatabase):
        self.db = db
        self.collection = db.marks

    async def create_or_update_mark(self, class_code: str, subject_code: str, student_id: str, mark: str):
        """Create or update a mark entry"""
        result = await self.collection.update_one(
            {
                "class_code": class_code,
                "subject_code": subject_code,
                "student_id": student_id,
            },
            {
                "$set": {
                    "mark": mark,
                    "updated_at": datetime.utcnow(),
                }
            },
            upsert=True
        )
        return True

    async def get_marks_by_student(self, student_id: str, class_code: str):
        """Get all marks for a student in a class"""
        records = await self.collection.find({
            "student_id": student_id,
            "class_code": class_code,
        }).to_list(None)
        return records

    async def get_marks_by_class_and_subject(self, class_code: str, subject_code: str):
        """Get all marks for a class and subject"""
        records = await self.collection.find({
            "class_code": class_code,
            "subject_code": subject_code,
        }).to_list(None)
        return records

    async def delete_mark(self, student_id: str, class_code: str, subject_code: str):
        """Delete a mark entry"""
        result = await self.collection.delete_one({
            "student_id": student_id,
            "class_code": class_code,
            "subject_code": subject_code,
        })
        return result.deleted_count > 0
