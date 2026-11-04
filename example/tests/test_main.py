import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly

@cocotb.test()
async def test_reset(dut):
    """Verify synchronous, active-high reset clears the counter."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    dut.rst.value = 1
    dut.enable.value = 1
    for cycle in range(3):
        await RisingEdge(dut.clk)
        await ReadOnly()
        assert int(dut.count.value) == 0, f"Counter was not reset on cycle {cycle}"

    await FallingEdge(dut.clk)
    dut.rst.value = 0
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.count.value) == 0, "Counter changed after reset was released with enable low"

@cocotb.test()
async def test_counting(dut):
    """Verify enabled counting, rollover, and holding when disabled."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    dut.rst.value = 1
    dut.enable.value = 0
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.count.value) == 0

    await FallingEdge(dut.clk)
    dut.rst.value = 0
    dut.enable.value = 1

    modulus = 1 << len(dut.count)
    for expected in range(1, modulus + 2):
        await RisingEdge(dut.clk)
        await ReadOnly()
        assert int(dut.count.value) == expected % modulus, (
            f"Expected count {expected % modulus}, got {int(dut.count.value)}"
        )

    await FallingEdge(dut.clk)
    dut.enable.value = 0
    held_value = int(dut.count.value)
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.count.value) == held_value, "Counter changed while enable was low"
