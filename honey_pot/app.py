from flask import Flask, request

app = Flask(__name__)

@app.route('/<web_path:web_path>')
def honey_pot(web_path):
    # TODO do something
    return "Think, think, think."