from __future__ import annotations

from datetime import datetime, timezone

from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import DateTime


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


db = SQLAlchemy()


class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)

    email = db.Column(db.Text, unique=True, index=True, nullable=False)
    password_hash = db.Column(db.Text, nullable=False)

    name = db.Column(db.Text, nullable=False)
    username = db.Column(db.Text, unique=True, index=True, nullable=False)

    created_at = db.Column(DateTime(timezone=True), default=_utcnow, nullable=False)

