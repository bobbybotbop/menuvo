"""
Schemas package containing all request/response validation schemas
"""
from backend.schemas.users import CreateAccountSchema, LoginSchema, AutoLoginSchema
from backend.schemas.friends import FriendRequestSchema
from backend.schemas.cookbooks import CreateCookbookSchema, UpdateCookbookSchema, AddRecipeToCookbookSchema

__all__ = [
    "CreateAccountSchema",
    "LoginSchema",
    "AutoLoginSchema",
    "FriendRequestSchema",
    "CreateCookbookSchema",
    "UpdateCookbookSchema",
    "AddRecipeToCookbookSchema"
]