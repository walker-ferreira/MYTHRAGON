"""Discover supported Gemini models and retry only model-not-found errors."""
import json
import os
from urllib import request, error

BASE = "https://generativelanguage.googleapis.com/v1beta/"
PREFERRED = ("models/gemini-2.5-flash-lite", "models/gemini-2.5-flash", "models/gemini-2.0-flash")


def google_error(exc):
    try:
        payload = json.loads(exc.read(4096).decode("utf-8", errors="replace"))
        details = payload.get("error", {})
        return str(details.get("message", "No error message"))[:500].replace("\\n", " ")
    except (ValueError, AttributeError):
        return "No structured error details"


def generate(body, timeout=90):
    key = os.environ["GEMINI_API_KEY"]
    req = request.Request(BASE + "models?pageSize=100", headers={"x-goog-api-key": key})
    try:
        with request.urlopen(req, timeout=30) as response:
            models = json.load(response).get("models", [])
    except error.HTTPError as exc:
        raise SystemExit(f"Gemini model discovery HTTP {exc.code}: {google_error(exc)}") from exc
    supported = [
        m["name"] for m in models
        if m.get("name", "").startswith("models/gemini-")
        and "generateContent" in m.get("supportedGenerationMethods", [])
    ]
    ordered = [m for m in PREFERRED if m in supported]
    ordered += [m for m in sorted(supported) if m not in ordered and "flash" in m]
    print(f"Gemini discovery: {len(models)} models; {len(supported)} support generateContent", flush=True)
    if not ordered:
        raise SystemExit("No compatible Gemini Flash model advertised for this key")
    payload = json.dumps(body).encode("utf-8")
    for model in ordered[:5]:
        print(f"Trying Gemini model: {model}", flush=True)
        req = request.Request(
            BASE + model + ":generateContent", data=payload, method="POST",
            headers={"Content-Type": "application/json", "x-goog-api-key": key},
        )
        try:
            with request.urlopen(req, timeout=timeout) as response:
                return json.load(response)
        except error.HTTPError as exc:
            detail = google_error(exc)
            print(f"Gemini {model} HTTP {exc.code}: {detail}", flush=True)
            if exc.code != 404:
                raise SystemExit(f"Gemini API HTTP {exc.code}; see model-specific error above") from exc
    raise SystemExit("Gemini generation failed: all attempted models returned HTTP 404")
