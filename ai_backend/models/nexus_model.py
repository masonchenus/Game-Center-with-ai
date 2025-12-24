"""Simulated Nexus AI model and factory.

This provides a lightweight NexusAIModel that can be parameterized by version.
It is deterministic and safe for tests; it does not call external services.
"""
import hashlib


class NexusAIModel:
    def __init__(self, version: str = "1.0"):
        self.version = str(version)
        self.name = f"nexus-{self.version}"

    def generate(self, prompt: str) -> str:
        seed = (self.name + "|" + prompt).encode("utf-8")
        h = hashlib.sha256(seed).hexdigest()[:12]
        return f"[Nexus {self.version} simulated response | id={h}] {prompt}"

    def generate_tokens(self, text: str) -> list:
        """Generate tokens by splitting on whitespace and punctuation boundaries."""
        import re
        # Simple token generation: split on whitespace and keep punctuation
        tokens = re.findall(r"\w+|[.,!?;:]", text)
        return tokens if tokens else text.split()


class NexusFactory:
    """Factory that produces NexusAIModel instances for requested versions.

    Use `NexusFactory().get(version)` to obtain a model instance.
    """
    def __init__(self, min_version: str = "1.0", max_version: str = "10.5.5"):
        self.min_version = min_version
        self.max_version = max_version

    def get(self, version: str = None) -> NexusAIModel:
        if version is None:
            version = self.min_version
        return NexusAIModel(version=str(version))
