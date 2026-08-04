from motor.motor_asyncio import AsyncIOMotorDatabase
from bson.objectid import ObjectId
from datetime import datetime


class EventsRepository:
    def __init__(self, db: AsyncIOMotorDatabase):
        self.db = db
        self.collection = db.events

    async def create_event(self, title: str, date: str, description: str = None):
        """Create a new event"""
        document = {
            "title": title,
            "date": date,
            "description": description,
            "created_at": datetime.utcnow(),
        }
        result = await self.collection.insert_one(document)
        return str(result.inserted_id)

    async def get_events_by_date(self, date: str):
        """Get all events for a specific date"""
        records = await self.collection.find({
            "date": date
        }).to_list(None)
        
        return [{
            "_id": str(record["_id"]),
            "title": record["title"],
            "date": record["date"],
            "description": record.get("description"),
            "created_at": record["created_at"].isoformat(),
        } for record in records]

    async def get_all_events(self):
        """Get all events"""
        records = await self.collection.find().sort("date", 1).to_list(None)
        
        return [{
            "_id": str(record["_id"]),
            "title": record["title"],
            "date": record["date"],
            "description": record.get("description"),
            "created_at": record["created_at"].isoformat(),
        } for record in records]

    async def delete_event(self, event_id: str):
        """Delete an event"""
        result = await self.collection.delete_one({
            "_id": ObjectId(event_id)
        })
        return result.deleted_count > 0

    async def update_event(self, event_id: str, title: str = None, date: str = None, description: str = None):
        """Update an event"""
        update_data = {}
        if title is not None:
            update_data["title"] = title
        if date is not None:
            update_data["date"] = date
        if description is not None:
            update_data["description"] = description
        
        if not update_data:
            return False
        
        result = await self.collection.update_one(
            {"_id": ObjectId(event_id)},
            {"$set": update_data}
        )
        return result.modified_count > 0

    async def get_dates_with_events(self):
        """Get all dates that have events"""
        result = await self.collection.distinct("date")
        return result
