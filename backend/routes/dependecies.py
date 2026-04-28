"""
Dependencies toolbox for route files.
"""

# External Flask & Werkzeug libraries
from flask import Blueprint, request, g, jsonify
from werkzeug.security import check_password_hash, generate_password_hash

# External Database & Validation exceptions
from sqlalchemy.exc import IntegrityError
from marshmallow import ValidationError

# Local Models & Database instance
from backend.models import User, SessionToken, db, Friendship

# Local Utilities
from backend.utils import error, success, generate_token

# Local Schemas
from backend.schemas import CreateAccountSchema, LoginSchema, AutoLoginSchema

# Local Middleware
from backend.middleware.customauth import require_auth

# Explicitly export these so IDEs and linters know they are meant to be imported
__all__ = [
    "Blueprint", 
    "request", 
    "g", 
    "jsonify", 
    "check_password_hash", 
    "generate_password_hash", 
    "IntegrityError", 
    "ValidationError", 
    "User", 
    "SessionToken", 
    "db", 
    "Friendship",
    "error", 
    "success", 
    "generate_token", 
    "CreateAccountSchema", 
    "LoginSchema", 
    "AutoLoginSchema", 
    "require_auth"
]