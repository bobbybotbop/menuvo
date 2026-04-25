from __future__ import annotations

import json
import os
from typing import Any

from flask import Flask, Response, request
from sqlalchemy.exc import IntegrityError
from werkzeug.security import check_password_hash, generate_password_hash

from db import User, db

app = Flask(__name__)
db_filename = "inmybeli.db"
app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL", f"sqlite:///{db_filename}")
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.config["SQLALCHEMY_ECHO"] = False

db.init_app(app)
with app.app_context():
    db.create_all()


def error(message: str, status: int):
    return Response(
        json.dumps({"error": message}),
        status=status,
        mimetype="application/json",
    )


def success(payload: dict[str, Any], status: int = 200):
    return Response(
        json.dumps(payload),
        status=status,
        mimetype="application/json",
    )


@app.post("/api/create")
def create_account():
    # Body format: {"name": string, "username": string, "email": string, "password": string}
    data = request.get_json(silent=True)
    if not isinstance(data, dict):
        return error("Invalid body", 400)

    name = str(data.get("name", "")).strip()
    username = str(data.get("username", "")).strip()
    email = str(data.get("email", "")).strip()
    password = str(data.get("password", "")).strip()

    user = User(
        name=name,
        username=username,
        email=email,
        password_hash=generate_password_hash(password),
    )
    db.session.add(user)
    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        # Covers duplicate username/email.
        return error("Invalid body", 400)

    return success(
        {"user_id": user.id, "name": user.name, "username": user.username},
        201,
    )


@app.post("/api/login")
def login():
    # Body format: {"email": string, "password": string}
    data = request.get_json(silent=True)
    if not isinstance(data, dict):
        return error("Invalid body", 400)

    email = str(data.get("email", "")).strip()
    password = str(data.get("password", "")).strip()

    user = User.query.filter_by(email=email).first()
    if user is None or not check_password_hash(user.password_hash, password):
        return error("invalid_credentials", 401)

    return success(
        {
            "success": True,
            "user": {"id": user.id, "username": user.username, "email": user.email},
        }
    )


@app.get("/api/users/<int:user_id>")
def get_user(user_id: int):
    # Body format: none (path param only)
    user = User.query.get(user_id)
    if user is None:
        return error("user not found", 404)

    return success(
        {
            "success": True,
            "user": {
                "id": user.id,
                "name": user.name,
                "username": user.username,
                "email": user.email,
            },
        }
    )


if __name__ == "__main__":
    app.run(debug=True)

