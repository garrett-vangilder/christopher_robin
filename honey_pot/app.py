from flask import Flask

app = Flask(__name__)

@app.route('/<string:web_path>')
def honey_pot(web_path):
    # TODO do something
    return "Think, think, think."

if __name__ == "__main__":
    app.run(host='0.0.0.0')