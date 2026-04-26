from datetime import datetime, timedelta, timezone
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import DateTime, func

db = SQLAlchemy()

def get_utc_now():
    """Return current UTC time"""
    return datetime.now(timezone.utc)

# Import models after db is created
from backend.models.user import User
from backend.models.session_token import SessionToken

__all__ = ['db', 'datetime', 'timedelta', 'timezone', 'DateTime', 'func', 'get_utc_now', 'User', 'SessionToken']