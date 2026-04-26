from flask import Blueprint, request
from werkzeug.security import check_password_hash, generate_password_hash
from sqlalchemy.exc import IntegrityError

from backend.models import User, db
from backend.utils import error, success

auth_bp = Blueprint("auth", __name__)

@auth_bp.post("/create")
def create_account():
    """
    Create a new user account
    """
    data = request.get_json(silent=True)
    if not isinstance(data, dict):
        return error("Invalid body", 400)

    name = str(data.get("name", "")).strip()
    username = str(data.get("username", "")).strip()
    email = str(data.get("email", "")).strip()
    password = str(data.get("password", "")).strip()

    # Validate inputs
    if not all([name, username, email, password]):
        return error("Missing required fields", 400)

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
        # Covers duplicate username/email
        return error("Username or email already exists", 400)

    return success(
        {
            "user_id": user.id, 
            "name": user.name, 
            "username": user.username
        },
        201,
    )


@auth_bp.post("/login")
def login():
    """
    Login a user with email and password.
    
    Body format: {
        "email": string, 
        "password": string
    }
    """
    data = request.get_json(silent=True)
    if not isinstance(data, dict):
        return error("Invalid body", 400)

    email = str(data.get("email", "")).strip()
    password = str(data.get("password", "")).strip()

    if not email or not password:
        return error("Missing email or password", 400)

    user = User.query.filter_by(email=email).first()
    if user is None or not check_password_hash(user.password_hash, password):
        return error("Invalid credentials", 401)

    return success(
        {
            "success": True,
            "user": {
                "id": user.id, 
                "username": user.username, 
                "email": user.email
            },
        }
    )