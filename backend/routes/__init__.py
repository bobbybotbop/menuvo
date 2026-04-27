# external libraries used by routes
from flask import Blueprint, request, g, jsonify
from werkzeug.security import check_password_hash, generate_password_hash
from sqlalchemy.exc import IntegrityError
from marshmallow import ValidationError

# local libraries used by routes
from backend.models import User, SessionToken, db
from backend.utils import error, success, generate_token
from backend.schemas import CreateAccountSchema, LoginSchema, AutoLoginSchema
from backend.middleware.customauth import require_auth
from backend.routes.users import users_bp

# exposed methods
__all__ = ["users_bp"]