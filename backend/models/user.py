from backend.models import db, DateTime, get_utc_now

class User(db.Model):
    """
    Users table stores the users information: email, password_hash, username, creation date, friends, recipes, and cookbooks. It has a one to many relationship to the session tables.

    Invariants:
    - for all users, they must all contain a unique username and email
    """
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)

    email = db.Column(db.Text, unique=True, index=True, nullable=False)
    password_hash = db.Column(db.Text, nullable=False)

    name = db.Column(db.Text, nullable=False)
    username = db.Column(db.Text, unique=True, index=True, nullable=False)

    created_at = db.Column(DateTime(timezone=True), default=get_utc_now, nullable=False)

    def __init__(self, **kwargs):
        """Initialize a user with email, password_hash, name, and username."""
        self.email = kwargs.get("email")
        self.password_hash = kwargs.get("password_hash")
        self.name = kwargs.get("name")
        self.username = kwargs.get("username")

    def serialize(self):
        """Serialize user to dictionary."""
        return {
            "id": self.id,
            "email": self.email,
            "name": self.name,
            "username": self.username,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }




