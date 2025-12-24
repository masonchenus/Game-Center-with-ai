# ai_backend/__init__.py
import os
import json
import logging

# -----------------------
# Import and initialize core and extra model providers
# -----------------------
try:
    from .ai_models.chatgpt_model import ChatGPTModel
except Exception:
    # Fallback shim when optional external dependencies (like openai) are missing.
    class ChatGPTModel:
        def __init__(self):
            self.name = "chatgpt-shim"

        def generate(self, prompt: str) -> str:
            return f"[chatgpt-shim] {prompt}"

try:
    from .ai_models.gemini_model import GeminiModel
except Exception:
    class GeminiModel:
        def __init__(self):
            self.name = "gemini-shim"

        def generate(self, prompt: str) -> str:
            return f"[gemini-shim] {prompt}"

try:
    from .ai_models.grok_model import GrokModel
except Exception:
    class GrokModel:
        def __init__(self):
            self.name = "grok-shim"

        def generate(self, prompt: str) -> str:
            return f"[grok-shim] {prompt}"

# Extra (local simulated) models
from .models import NexusFactory, FlashModel, ProFlashModel, UltraModel, UltraFlashModel

# -----------------------
# Logging setup
# -----------------------
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("iGame-AI")

# -----------------------
# Ensure necessary folders exist
# -----------------------
for folder in ["stats", "billing"]:
    os.makedirs(folder, exist_ok=True)

# -----------------------
# Initialize stats file
# -----------------------
stats_file = "stats/stats.json"
if not os.path.exists(stats_file):
    with open(stats_file, "w") as f:
        json.dump({"requests": 0}, f)

# -----------------------
# Ultra billing setup
# -----------------------
billing_file = "billing/billing.json"
if not os.path.exists(billing_file):
    ultra_credits = 10**12  # ultra dev mode
    with open(billing_file, "w") as f:
        json.dump({"credits": ultra_credits}, f)

# Initialize models once for the whole backend
_nexus_factory = NexusFactory()
models = {
    "chatgpt": ChatGPTModel(),
    "gemini": GeminiModel(),
    "grok": GrokModel(),

    # Nexus factory and a couple of convenience instances
    "nexus_factory": _nexus_factory,
    "nexus": _nexus_factory.get("1.0"),
    "nexus-10.5.5": _nexus_factory.get("10.5.5"),

    # Flash-family simulated models
    "flash": FlashModel(),
    "pro-flash": ProFlashModel(),
    "ultra": UltraModel(),
    "ultra-flash": UltraFlashModel(),
}

logger.info("iGame-AI package initialized with core and extra models loaded.")
