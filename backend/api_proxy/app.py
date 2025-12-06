from flask import Flask, send_from_directory, jsonify
import requests
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__, static_folder="../../frontend/dist", static_url_path="")

API_URL = os.getenv("API_GATEWAY_URL")


@app.route("/api/state-data")
def state_data():
    response = requests.get(API_URL)
    return jsonify(response.json())


# Serve React
@app.route("/", defaults={"path": ""})
@app.route("/<path:path>")
def serve(path):
    dist_dir = os.path.join(os.path.dirname(__file__), "../../frontend/dist")
    full_path = os.path.join(dist_dir, path)

    # If file exists, serve directly
    if path != "" and os.path.exists(full_path):
        return send_from_directory(dist_dir, path)
    
    # Otherwise serve index.html
    return send_from_directory(dist_dir, "index.html")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
