"""Robot variable file: environment-driven settings (the only config source).

Precedence: `robot --variable NAME:value` > environment variable > .env file > default.
The public demo URLs are defaults so a fresh clone runs; credentials come only from env/.env.
"""

from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parent.parent / ".env")  # real env vars always win


def _get(name: str, default: str = "") -> str:
    return os.getenv(name, "").strip() or default


def get_variables() -> dict[str, object]:
    return {
        "UI_BASE_URL": _get("UI_BASE_URL", "https://practicesoftwaretesting.com").rstrip("/"),
        "API_BASE_URL": _get("API_BASE_URL", "https://api.practicesoftwaretesting.com").rstrip("/"),
        "CUSTOMER_EMAIL": _get("CUSTOMER_EMAIL"),
        "CUSTOMER_PASSWORD": _get("CUSTOMER_PASSWORD"),
        "BROWSER": _get("BROWSER", "chrome").lower(),
        "HEADLESS": _get("HEADLESS", "true").lower() == "true",
        "SELENIUM_TIMEOUT": _get("SELENIUM_TIMEOUT", "10s"),
        "API_TIMEOUT": float(_get("API_TIMEOUT_SECONDS", "15")),
    }
