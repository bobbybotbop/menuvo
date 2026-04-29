from backend.routes.dependecies import (
    Blueprint,
    request,
    db,
    User,
    Friendship,
    error,
    success,
    require_auth,
    ValidationError,
    FriendRequestSchema,
    g
)

friends_bp = Blueprint("friends", __name__)

@friends_bp.get("/<int:user_id>/friends/")
@require_auth
def get_friends(user_id):
    """
    Get all the friends for user
    """
    user = User.query.get(user_id)
    if not user:
        error("User not found", 404)
    
    friends = user.get_friends()

    return success(
        {
        "user_id": user_id,
        "friends": [{"id": f.id, "username": f.username} for f in friends]
        }, 200
    )


@friends_bp.get("/<int:user_id>/friends/pending/")
@require_auth
def get_pending_requests(user_id):
    """
    Get all pending friend requests for user
    """
    user = User.query.get(user_id)
    if not user:
        error("User not found", 404)
    
    pending = user.get_pending_requests()

    return success(
        {
        "user_id": user_id,
        "pending_requests": [
            {"id": p.id, "username": p.username} for p in pending
        ]
        }, 200
    )

@friends_bp.post("/<int:user_id>/friends/request/")
@require_auth
def send_friend_request(user_id):
    """
    Send a friend request to the user
    """
    schema = FriendRequestSchema()

    try:
        data = schema.load(request.get_json(silent=True) or {})
    except ValidationError as err:
        return error(err.messages, 400)

    friendId = data["friend_id"]

    if g.user.id == friendId:
        return error("Cannot be friends with yourself", 400)

    friend = User.query.get(friendId)

    if not friend:
        return error("Friend not found", 404)

    g.user.send_friend_request(friend)
    db.session.commit()
    
    return success({'success': True, 'message': 'Friend request sent'}, 201)


@friends_bp.post("/<int:user_id>/friends/accept/")
@require_auth
def accept_friend_request(user_id):
    """
    Accepting a friend request to the user
    """
    schema = FriendRequestSchema()

    try:
        data = schema.load(request.get_json(silent=True) or {})
    except ValidationError as err:
        return error(err.messages, 400)
    
    friendId = data["friend_id"]
    
    if g.user.id == friendId:
        return error("Cannot be friends with yourself", 400)
    
    friend = User.query.get(friendId)
    if not friend:
        return error("Friend not found", 404)
    
    g.user.accept_friend_request(friend)
    db.session.commit()
    
    return success({'success': True, 'message': 'Friend request accepted'}, 200)


@friends_bp.delete('/<int:user_id>/friends/<int:friend_id>/')
@require_auth
def remove_friend(user_id, friend_id):
    """
    Deleting a friend
    """
    friendship = Friendship.query.filter_by(
        friend_id=friend_id,
        user_id=user_id,
        status='accepted'
    ).first()
    
    if not friendship:
        return error("Friendship not found", 404)
    
    db.session.delete(friendship)
    db.session.commit()
    
    return success({'success': True, 'message': 'Friend removed'}, 200)


@friends_bp.get('/<int:user_id>/friends/<int:friend_id>/')
@require_auth
def check_friendship(user_id, friend_id):
    """
    Checks if user and friend are existing friends already
    """
    friendship = Friendship.query.filter(
        db.or_(
            db.and_(Friendship.user_id == user_id, Friendship.friend_id == friend_id),
            db.and_(Friendship.user_id == friend_id, Friendship.friend_id == user_id)
        ),
        Friendship.status == 'accepted'
    ).first()
    
    is_friend = friendship is not None
    return {'user_id': user_id, 'friend_id': friend_id, 'is_friend': is_friend}, 200