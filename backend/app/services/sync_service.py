import os
import logging
from typing import Any
from dotenv import load_dotenv
from fastapi import HTTPException

load_dotenv()

logger = logging.getLogger(__name__)


async def sync_all(db) -> dict[str, Any]:
    """High-level sync orchestration.

    NOTE: The actual scraper implementation is intentionally left as a stub.
    Before implementing the scraper we must obtain portal URLs and sample
    HTML from the user. This function validates environment and then
    calls the scraper module (not implemented yet).
    """
    portal_base = os.getenv("PORTAL_BASE_URL")
    username = os.getenv("PORTAL_USERNAME")
    password = os.getenv("PORTAL_PASSWORD")

    if not (portal_base and username and password):
        raise HTTPException(status_code=400, detail="Portal credentials or URL missing in environment")

    # Placeholder for scraper call. We'll implement the scraper after the
    # user provides portal URLs and sample payloads.
    logger.info("Portal credentials present; scraper not implemented yet.")

    # Returning a neutral success with a message indicating that no data was fetched.
    return {"status": "ok", "message": "scraper_not_implemented"}
