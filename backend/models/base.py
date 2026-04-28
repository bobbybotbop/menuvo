from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import DateTime
from datetime import datetime, timedelta, timezone

db = SQLAlchemy()

def get_utc_now():
    """Return current UTC time"""
    return datetime.now()