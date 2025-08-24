import datetime
import os
import socket
import time

from flask import Flask, jsonify

app = Flask(__name__)

# Environment variables for revision
AUTHOR = os.environ.get("AUTHOR", "Shadow Author")
QUOTE = os.environ.get("QUOTE", "You hate te see it...")
APP_VERSION = os.environ.get("APP_VERSION", "1.0.0")
FEATURE_FLAG = os.environ.get("FEATURE_FLAG", "original experience")

# Instance identification
HOSTNAME = socket.gethostname()
REVISION = os.environ.get("CONTAINER_APP_REVISION", "UNKNOWN")
REPLICA = os.environ.get("CONTAINER_APP_REPLICA", "UNKNOWN")


@app.route('/')
def greet():
    if APP_VERSION.startswith("2"):
        quote = QUOTE
        author = AUTHOR
    else:
        quote = QUOTE
        author = AUTHOR

    return f"""
    
    <!DOCTYPE html>
    <html>
    <head>
    </head>
    <body>
        <div class="version-banner">
        🚀 Version {APP_VERSION} - {FEATURE_FLAG.replace('_', ' ').title()}
        </div>
        <div class="instance-info">
            <h3>Container Instance Information</h3>
            <div class="info-item"><strong>Instance ID:</strong> {HOSTNAME}</div>
            <div class="info-item"><strong>Revision:</strong> {REVISION}</div>
            <div class="info-item"><strong>Replica Name:</strong> {REPLICA}</div>
            <div class="info-item"><strong>App Version:</strong> {APP_VERSION}</div>
            <div class="info-item"><strong>Request Time:</strong> {datetime.datetime.now().isoformat()}</div>
            {"<div class='new-feature'>✨ <strong>NEW IN V2:</strong> Enhanced UI & Dynamic Quotes!</div>" if APP_VERSION.startswith("2") else ""}
        </div>
        <br><br>
        <div class="quote">
            "{quote}"
        </div>
        <div class="author">
            – {author}
        </div>
    </body>
    </html>
    """


@app.route('/load')
def simulate_load():
    start_time = time.time()

    # Do some work for 5 seconds to simulate HEAVY load
    while time.time() - start_time < 5:
        pass  # pure CPU spin, 100% usage

    return jsonify({
        "message": "Processed request\n",
        "instance": HOSTNAME,
    })


@app.route('/health')
def health_check():
    try:
        return {
            "status": "healthy",
            "timestamp": datetime.datetime.now().isoformat(),
            "version": APP_VERSION
        }, 200
    except Exception as e:
        return {
            "status": "unhealthy",
            "error": str(e),
            "timestamp": datetime.datetime.now().isoformat()
        }, 5000


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
