# _______________________________________________
# Librelane

LIBRELANE_CONFIG ?= librelane.yaml
LAYOUT_APP ?= klayout # or openroad

.PHONY: harden
harden:
	librelane $(LIBRELANE_CONFIG)


# _______________________________________________
# Klayout

.PHONY: rtl-layout layout
rtl-layout:
	librelane --last-run --flow openin$(LAYOUT_APP) $(LIBRELANE_CONFIG) &


# _______________________________________________
# Cocotb

# Cocotb
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl
WAVES ?= 1

.PHONY: simulate 
simulate: 
	WAVES=$(WAVES) SIM=$(SIM) uv run pytest tests/test.py
	gtkwave sim_build/*.ghw &