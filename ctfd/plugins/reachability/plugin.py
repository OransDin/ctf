import json
import os
import socket
from flask import Blueprint, jsonify
from CTFd.utils.decorators import admins_only

DEFAULT_OUTPUTS_PATH = "/data/terraform/outputs.json"


def _read_target_ip(outputs_path: str):
    if not os.path.exists(outputs_path):
        return None

    with open(outputs_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    for key in ("target_public_ip", "public_ip"):
        if key in data and isinstance(data[key], dict):
            return data[key].get("value")

    return None


def _tcp_check(ip: str, port: int = 22, timeout: int = 3) -> bool:
    try:
        with socket.create_connection((ip, port), timeout=timeout):
            return True
    except OSError:
        return False


def load(app):
    bp = Blueprint("reachability", __name__)

    @bp.route("/admin/reachability/validate", methods=["GET"])
    @admins_only
    def validate():
        outputs_path = os.getenv("TF_OUTPUTS_PATH", DEFAULT_OUTPUTS_PATH)
        ip = _read_target_ip(outputs_path)

        if not ip:
            return jsonify({
                "status": "failed",
                "message": f"Target IP not found. Expected outputs at: {outputs_path}"
            }), 404

        ok = _tcp_check(ip, port=22, timeout=3)

        if ok:
            return jsonify({
                "status": "success",
                "target_ip": ip,
                "check": "tcp/22",
                "message": "Target is reachable from CTFd"
            }), 200

        return jsonify({
            "status": "failed",
            "target_ip": ip,
            "check": "tcp/22",
            "message": "Target is NOT reachable from CTFd (port 22 closed/blocked)"
        }), 200

    app.register_blueprint(bp)

