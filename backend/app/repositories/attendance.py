from motor.motor_asyncio import AsyncIOMotorDatabase
from bson.objectid import ObjectId
from datetime import datetime


class AttendanceRepository:
    def __init__(self, db: AsyncIOMotorDatabase):
        self.db = db
        self.collection = db.attendance

    async def add_absence(self, date: str, period: int, subject_code: str, class_code: str):
        """Add an absence record"""
        document = {
            "date": date,
            "period": period,
            "subject_code": subject_code,
            "class_code": class_code,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
        }
        result = await self.collection.insert_one(document)
        return str(result.inserted_id)

    async def remove_absence(self, date: str, period: int, class_code: str):
        """Remove an absence record"""
        result = await self.collection.delete_one({
            "date": date,
            "period": period,
            "class_code": class_code,
        })
        return result.deleted_count > 0

    async def get_absences_by_class(self, class_code: str):
        """Get all absences for a class, grouped by date"""
        records = await self.collection.find({
            "class_code": class_code
        }).sort([("date", 1), ("period", 1)]).to_list(None)
        
        # Group by date
        grouped = {}
        for record in records:
            date = record["date"]
            if date not in grouped:
                grouped[date] = []
            grouped[date].append({
                "period": record["period"],
                "subject_code": record["subject_code"],
            })
        
        return grouped

    async def get_absences_by_date(self, date: str, class_code: str):
        """Get absences for a specific date and class"""
        records = await self.collection.find({
            "date": date,
            "class_code": class_code,
        }).sort("period", 1).to_list(None)
        return records

    async def update_absence(self, date: str, period: int, class_code: str, subject_code: str):
        """Update an absence record"""
        result = await self.collection.update_one(
            {
                "date": date,
                "period": period,
                "class_code": class_code,
            },
            {
                "$set": {
                    "subject_code": subject_code,
                    "updated_at": datetime.utcnow(),
                }
            }
        )
        return result.modified_count > 0
