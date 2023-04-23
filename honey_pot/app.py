import json
import os
from flask import Flask, request
import requests

from parser import RequestParser

app = Flask(__name__)


@app.route("/")
@app.route("/<string:web_path>", methods=["GET", "POST", "PUT", "DELETE"])
def honey_pot(web_path=""):
    # serialize request information into byte stream using json
    parser = RequestParser(request=request)
    data = parser.parse()

    # Serialize the dictionary as JSON
    json_data = json.dumps(data)
    # Send the JSON data to the data ingest endpoint
    if lambda_url := os.environ['DATA_INGEST_ENDPOINT']:
        requests.post(
            url=lambda_url,
            data=json_data,
            headers={"Content-Type": "application/json"},
            timeout=15
        )

    return json_data


if __name__ == "__main__":
    app.run(host="0.0.0.0")
