from flask import Flask

app = Flask(__name__)


@app.route('/')
def greet():
    return "The mystery of life isn't a problem to solve, but a reality to experience.<br><br>– Frank Herbert"


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
