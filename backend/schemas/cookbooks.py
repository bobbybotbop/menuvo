"""
Schemas for cookbook endpoints
"""
from marshmallow import Schema, fields, validate

class CreateCookbookSchema(Schema):
    """Schema for creating a new cookbook"""
    name = fields.Str(
        required=True,
        validate=validate.Length(min=1, max=255),
        error_messages={"required": "Cookbook name is required"}
    )
    description = fields.Str(
        required=False,
        allow_none=True,
        validate=validate.Length(max=1000)
    )


class UpdateCookbookSchema(Schema):
    """Schema for updating an existing cookbook"""
    name = fields.Str(
        required=False,
        validate=validate.Length(min=1, max=255)
    )
    description = fields.Str(
        required=False,
        allow_none=True,
        validate=validate.Length(max=1000)
    )

class AddRecipeToCookbookSchema(Schema):
    """Schema for adding a recipe to a cookbook"""
    recipe_id = fields.Int(
        required=True,
        error_messages={"required": "Recipe ID is required"}
    )
