"""
Schemas for review endpoints
"""
from marshmallow import Schema, fields, validate


class CreateReviewSchema(Schema):
    """Schema for creating/updating review on recipe"""
    rating = fields.Int(
        required=True,
        validate=validate.Range(min=1, max=5),
        error_messages={"required": "Rating is required"}
    )
    text = fields.Str(
        required=False,
        allow_none=True,
        validate=validate.Length(max=2000)
    )