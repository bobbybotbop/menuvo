import json
from flask import Response
 
def error(message, status):
    """Return a JSON error response."""
    return Response(
        json.dumps({"error": message}),
        status=status,
    )
 
 
def success(payload, status=200):
    """Return a JSON success response."""
    return Response(
        json.dumps(payload),
        status=status,
    )
 