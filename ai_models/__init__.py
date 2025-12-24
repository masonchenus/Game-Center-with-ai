"""Compatibility shim package so modules importing `ai_models` still work.

This forwards to `ai_backend.ai_models` which contains the real implementations.
"""
from ai_backend.ai_models import models as models

__all__ = ["models"]
