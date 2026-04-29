"""
Schemas for friends endpoints
"""
from marshmallow import Schema, fields, validate

class FriendRequestSchema(Schema):
    """Schema for processing friend requests or actions"""
    friend_id = fields.Int(
        required=True,
        error_messages={"required": "Friend's ID is required"}
    )