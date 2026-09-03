import os
import asyncio
import logging
from datetime import datetime, timezone
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware

from apscheduler.schedulers.asyncio import AsyncIOScheduler

from app.api.router import router as api_router
from app.routers.websocket import router as ws_router
from app.services.sync_service import sync_all
from app.database.connection import get_db, get_client

load_dotenv()

logger = logging.getLogger("uvicorn")

os.makedirs("uploads/notices", exist_ok=True)

app = FastAPI(title="College Sync API", version="0.1.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router)
app.include_router(ws_router)

# Serve uploaded files
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")
app.mount(
	"/admin",
	StaticFiles(directory="../admin-dashboard", html=True),
	name="admin-dashboard",
)


SYNC_INTERVAL_MINUTES = int(os.getenv("SYNC_INTERVAL_MINUTES", "30"))


async def apply_data_migrations():
	"""Apply small, repeat-safe production data corrections."""
	db = get_db()
	migration_id = "2026-08-05-u2503208-s3-internal-1"
	if await db.app_migrations.find_one({"_id": migration_id}):
		return

	for subject_code, mark in (
		("102903/CO300B", "41.5"),
		("102908/EN900E", "43"),
		("102908/CO900G", "32"),
	):
		await db.marks.update_one(
			{
				"class_code": "2026S3CS-C",
				"subject_code": subject_code,
				"student_id": "U2503208",
			},
			{"$set": {"mark": mark, "updated_at": datetime.now(timezone.utc)}},
			upsert=True,
		)

	await db.app_migrations.insert_one(
		{"_id": migration_id, "applied_at": datetime.now(timezone.utc)}
	)


@app.on_event("startup")
async def startup_event():
	# Ensure DB client is created
	async for _ in get_client():
		break
	await apply_data_migrations()

	# Start scheduler
	scheduler = AsyncIOScheduler()

	async def _job_wrapper():
		try:
			db = get_db()
			await sync_all(db)
		except Exception as exc:
			logger.exception("Periodic sync failed: %s", exc)

	scheduler.add_job(lambda: asyncio.create_task(_job_wrapper()), "interval", minutes=SYNC_INTERVAL_MINUTES)
	scheduler.start()
	app.state.scheduler = scheduler


@app.on_event("shutdown")
async def shutdown_event():
	sched = getattr(app.state, "scheduler", None)
	if sched:
		sched.shutdown(wait=False)


if __name__ == "__main__":
	import uvicorn

	uvicorn.run(
		"main:app",
		host="0.0.0.0",
		port=int(os.getenv("PORT", "8000")),
		reload=False,
	)
