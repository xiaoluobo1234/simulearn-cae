"""Test configuration and fixtures."""

import sys
import os
import pytest
from pathlib import Path

# Add backend to path
sys.path.insert(0, str(Path(__file__).parent.parent))

TEST_DATA = Path(__file__).parent.parent.parent / "tests" / "data"


@pytest.fixture
def test_step_file() -> bytes:
    """Return the test cube STEP file content."""
    step_path = TEST_DATA / "test_cube.step"
    if not step_path.exists():
        pytest.skip("Test STEP file not found. Run: python scripts/generate_test_model.py")
    return step_path.read_bytes()


@pytest.fixture
def test_step_path() -> Path:
    """Return path to test cube STEP file."""
    step_path = TEST_DATA / "test_cube.step"
    if not step_path.exists():
        pytest.skip("Test STEP file not found")
    return step_path
