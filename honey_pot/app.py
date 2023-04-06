import json
from flask import Flask, request
from werkzeug.exceptions import BadRequest

app = Flask(__name__)


@app.route("/")
@app.route("/<string:web_path>", methods=["GET", "POST", "PUT", "DELETE"])
def honey_pot(web_path=""):
    # serialize request information into byte stream using json
    data = {}
    try:
        data = {
            "headers": dict(request.headers),
            "method": request.method,
            "args": dict(request.args),
            "form": dict(request.form),
            "json": request.json,
            "cookies": request.cookies,
            "files": request.files,
            "remote_addr": request.remote_addr,
            "url": request.url,
        }
    except BadRequest:
        data = {
            "headers": dict(request.headers),
            "method": request.method,
            "args": dict(request.args),
            "form": dict(request.form),
            "json": {},
            "cookies": request.cookies,
            "files": request.files,
            "remote_addr": request.remote_addr,
            "url": request.url,
        }

    # Serialize the dictionary as JSON
    json_data = json.dumps(data)

    return json_data


if __name__ == "__main__":
    app.run(host="0.0.0.0")
