from motor.motor_asyncio import AsyncIOMotorDatabase
from bson.objectid import ObjectId
from datetime import datetime


class NoticesRepository:
    def __init__(self, db: AsyncIOMotorDatabase):
        self.db = db
        self.collection = db.notices

    async def create_notice(
        self,
        title: str,
        file_url: str,
        is_exam_notice: bool = False,
        file_id: str | None = None,
    ):
        """Create a new notice"""
        document = {
            "title": title,
            "file_url": file_url,
            "is_exam_notice": is_exam_notice,
            "file_id": file_id,
            "upload_date": datetime.utcnow(),
        }
        result = await self.collection.insert_one(document)
        return str(result.inserted_id)

    async def get_all_notices(self, is_exam_notice: bool = False):
        """Get all notices (or exam notices only)"""
        records = await self.collection.find({
            "is_exam_notice": is_exam_notice
        }).sort("upload_date", -1).to_list(None)
        
        return [{
            "_id": str(record["_id"]),
            "title": record["title"],
            "file_url": record["file_url"],
            "upload_date": record["upload_date"].isoformat(),
            "is_exam_notice": record["is_exam_notice"],
            "file_id": record.get("file_id"),
        } for record in records]

    async def delete_notice(self, notice_id: str):
        """Delete a notice"""
        result = await self.collection.delete_one({
            "_id": ObjectId(notice_id)
        })
        return result.deleted_count > 0

    async def get_notice(self, notice_id: str):
        """Get a specific notice"""
        record = await self.collection.find_one({
            "_id": ObjectId(notice_id)
        })
        if not record:
            return None
        
        return {
            "_id": str(record["_id"]),
            "title": record["title"],
            "file_url": record["file_url"],
            "upload_date": record["upload_date"].isoformat(),
            "is_exam_notice": record["is_exam_notice"],
            "file_id": record.get("file_id"),
        }
