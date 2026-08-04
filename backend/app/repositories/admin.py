from motor.motor_asyncio import AsyncIOMotorDatabase
from datetime import datetime


class AdminRepository:
    def __init__(self, db: AsyncIOMotorDatabase):
        self.db = db
        self.collection = db.admins

    async def create_admin(self, username: str, password_hash: str, name: str):
        """Create a new admin user"""
        existing = await self.collection.find_one({"username": username})
        if existing:
            return None
        
        document = {
            "username": username,
            "password_hash": password_hash,
            "name": name,
            "created_at": datetime.utcnow(),
        }
        result = await self.collection.insert_one(document)
        return str(result.inserted_id)

    async def get_admin_by_username(self, username: str):
        """Get admin by username"""
        return await self.collection.find_one({"username": username})

    async def admin_exists(self):
        """Check if any admin exists"""
        count = await self.collection.count_documents({})
        return count > 0
