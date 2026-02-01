from flask import Flask, send_from_directory, jsonify
import requests
import os
import json

app = Flask(__name__, static_folder="../../frontend/dist", static_url_path="")

# Get API Gateway ID from environment variable (injected by ECS from Secrets Manager)
api_gateway_secret = os.environ.get("api_gateway_secret")
if api_gateway_secret:
    api_gateway_id = json.loads(api_gateway_secret)
else:
    raise RuntimeError("api_gateway_secret environment variable not set")

@app.route("/api/state-data")
def state_data():
    api_url = f"https://{api_gateway_id['api_key']}.execute-api.us-west-2.amazonaws.com/dev/data?groupby=all"
    response = requests.get(api_url)
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
