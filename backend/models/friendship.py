from backend.models.base import db, DateTime, get_utc_now

class Friendship(db.Model):
    """
    Association object set as user between each other. It stores the user_id, friend_id, and status (invariant is that it is only pending, accepted, blocked)
    """
    __tablename__ = 'friendships'
    
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), primary_key=True)
    friend_id = db.Column(db.Integer, db.ForeignKey('users.id'), primary_key=True)
    status = db.Column(db.String(20), default='pending')  # pending, accepted, blocked
    created_at = db.Column(DateTime(timezone=True), default=get_utc_now)
    
    user = db.relationship('User', foreign_keys=[user_id], backref='sent_requests')
    friend = db.relationship('User', foreign_keys=[friend_id], backref='received_requests')