"""Extra AI models package: NexusAI and Flash variants.
This package provides simple simulated model classes for testing and integration.
"""
from .nexus_model import NexusAIModel, NexusFactory
from .flash_models import FlashModel, ProFlashModel, UltraModel, UltraFlashModel

__all__ = [
    "NexusAIModel",
    "NexusFactory",
    "FlashModel",
    "ProFlashModel",
    "UltraModel",
    "UltraFlashModel",
]
