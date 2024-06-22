from flask import Flask, request, jsonify
from function import function_app
import json, os

app = Flask(__name__)

def handle(req):
    req = json.loads(req)
    return function_app.execute(req)

def is_true(val):
    return len(val) > 0 and val.lower() == "true" or val == "1"

@app.before_request
def fix_transfer_encoding():
    """
    Sets the "wsgi.input_terminated" environment flag, thus enabling
    Werkzeug to pass chunked requests as streams.  The gunicorn server
    should set this, but it's not yet been implemented.
    """

    transfer_encoding = request.headers.get("Transfer-Encoding", None)
    if transfer_encoding == u"chunked":
        request.environ["wsgi.input_terminated"] = True


@app.route("/", methods=["POST", "GET"])
#@app.route("/<path:path>", methods=["POST", "GET"])
def knative_function():
    try:
        raw_body = os.getenv("RAW_BODY", "false")

        as_text = True

        if is_true(raw_body):
            as_text = False
        
        ret = handle(request.get_data(as_text=as_text))
        return ret
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
