"""
Routes package: Exposes only the Blueprints for app registration.
"""
from backend.routes.users import users_bp
from backend.routes.friends import friends_bp

# This keeps your app-level imports clean: 
# 'from backend.routes import *' will only give you the blueprints.
__all__ = ["users_bp", "friends_bp"]