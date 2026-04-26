from flask import Blueprint
 
from backend.models import User
from backend.utils import error, success
 
users_bp = Blueprint("users", __name__)
 
 
@users_bp.get("/users/<int:user_id>")
def get_user(user_id: int):
    """
    Get user information by user_id.
    
    Path params:
        user_id: int - The ID of the user to retrieve
    """
    user = User.query.get(user_id)
    if user is None:
        return error("User not found", 404)
 
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
 