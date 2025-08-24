import datetime
import os

from flask import Flask

app = Flask(__name__)

AUTHOR = os.environ.get("AUTHOR", "Shadow Author")


@app.route('/')
def greet():
    return "The mystery of life isn't a problem to solve, but a reality to experience.<br><br>– " + AUTHOR


@app.route('/health')
def health_check():
    try:
        return {
            "status": "healthy",
            "timestamp": datetime.datetime.now().isoformat(),
            "version": "1.0.0"
        }, 200
    except Exception as e:
        return {
            "status": "unhealthy",
            "error": str(e),
            "timestamp": datetime.datetime.now().isoformat()
        }, 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
