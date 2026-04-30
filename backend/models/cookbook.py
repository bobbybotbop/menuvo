from backend.models.assocTables import cookbookRecipes
from backend.models.base import db

class Cookbook(db.Model):
    """
    Cookbook table stores cookbook
    Each cookbook has name, description, list of recipes, and number of friends saving it
    
    Invariants:
    - every cookbook must refer to a valid recipe in the database
    - a global per-user cookbook named "saved" tracks user-recipe save relationships
      and is the source of truth for computing recipe total save counts in feed previews
    """
    __tablename__ = "cookbooks"

    id = db.Column(db.Integer, primary_key=True)
    creator_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)

    name = db.Column(db.Text, nullable=False)
    description = db.Column(db.Text, nullable=True)

    recipes = db.relationship(
        'Recipe',
        secondary=cookbookRecipes,
        backref='cookbooks',
        lazy='dynamic'
    )

    def __init__(self, **kwargs):        
        self.name = kwargs.get("name")
        self.description = kwargs.get("description", "")
        self.creator_id = kwargs.get("creator_id")

    def serialize(self):
        """Full cookbook view"""
        return {
            "id": self.id,
            "name": self.name,
            "description": self.description,
            "recipes": [r.serialize_preview() for r in self.recipes],
        }
    
    def simple_serialize(self):
        """Partial cookbook view"""
        return {
            "id": self.id,
            "name" : self.name, 
            "description" : self.description
        }