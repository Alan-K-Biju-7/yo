import os
import asyncio
import logging
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


SYNC_INTERVAL_MINUTES = int(os.getenv("SYNC_INTERVAL_MINUTES", "30"))


@app.on_event("startup")
async def startup_event():
	# Ensure DB client is created
	async for _ in get_client():
		break

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

	uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=False)

