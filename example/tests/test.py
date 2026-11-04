import os
import sys
from pathlib import Path
import pytest
from cocotb_tools.runner import get_runner

SIM = os.getenv("SIM", "ghdl")

PROJECT_ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = PROJECT_ROOT / "src"

# necessary for running the script!
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))
    

def test_main():
    sources = sorted(SRC_DIR.glob("*.vhd"))

    runner = get_runner(SIM)
    runner.build(
        sources=sources,
        hdl_toplevel="counter",
        always=True,
    )
    runner.test(
        test_module="tests.test_main",
        hdl_toplevel="counter",
    )
