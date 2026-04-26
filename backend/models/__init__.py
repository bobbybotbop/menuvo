from datetime import datetime, timedelta, timezone
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import DateTime, func

db = SQLAlchemy()

def get_utc_now():
    """Return current UTC time"""
    return datetime.now(timezone.utc)

__all__ = ['db', 'datetime', 'timedelta', 'timezone', 'DateTime', 'func', 'get_utc_now']