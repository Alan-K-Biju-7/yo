from typing import AsyncGenerator
import os
from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
from dotenv import load_dotenv

load_dotenv()

MONGODB_URI = os.getenv("MONGODB_URI", "mongodb://localhost:27017")
MONGODB_DB = os.getenv("MONGODB_DB", "college_sync")

_client: AsyncIOMotorClient | None = None


async def get_client() -> AsyncGenerator[AsyncIOMotorClient, None]:
    global _client
    if _client is None:
        _client = AsyncIOMotorClient(MONGODB_URI)
    try:
        yield _client
    finally:
        # Do not close client here; lifecycle managed by application
        pass


def get_db() -> AsyncIOMotorDatabase:
    global _client
    if _client is None:
        _client = AsyncIOMotorClient(MONGODB_URI)
    return _client[MONGODB_DB]
