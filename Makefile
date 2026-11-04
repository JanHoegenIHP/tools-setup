CONTAINER_NAME ?= hka-tools/asic

.PHONY: build run run-windows-x11 test-tools

ifeq ($(OS),Windows_NT)
check-docker:
	@where docker >NUL 2>&1 || ( \
		echo ERROR: Docker is not running or is not accessible. & \
		echo Please start Docker Desktop and try again. & \
		exit /b 1 \
	)

check-running:
	@docker ps --format "{{.Names}}" | findstr /x /c:"$(CONTAINER_NAME)" >NUL || ( \
		echo Error: Container '$(CONTAINER_NAME)' is not running. & \
		echo Run 'make run' to start it. & \
		exit /b 1 \
	)
else
check-docker:
	@docker version >/dev/null 2>&1 || docker info >/dev/null 2>&1 || ( \
		echo "ERROR: Docker is not running or is not accessible."; \
		echo "Please start Docker Desktop and try again."; \
		exit 1; \
	)

check-running:
	@if ! docker ps --format '{{.Names}}' | grep -Fxq "$(CONTAINER_NAME)"; then \
		echo "Error: Container '$(CONTAINER_NAME)' is not running."; \
		echo "Run 'make run' to start it."; \
		exit 1; \
	fi
endif

build: check-docker
	docker build --tag hka-tools/asic .

test-tools: check-docker 
	docker run --rm \
		-v "$(CURDIR):/workspace" \
		hka-tools/asic python3 /workspace/tests/smoke_test.py

# todo: add user and shell id from host to avoid permission issues when mounting volumes
ifeq ($(OS),Windows_NT)
WSL_DISTRO ?= Ubuntu
WINDOWS_X11_DISPLAY ?= host.docker.internal:0.0

run: check-docker 
	wsl.exe -d "$(WSL_DISTRO)" -- env -u OS make run

# Requires a Windows X server (for example VcXsrv) listening on display 0.
# This target uses Docker Desktop directly, without WSLg socket mounts.
run-windows-x11: check-docker 
	docker run -it --rm \
		--hostname hka-tools \
		-v "$(CURDIR):/workspace" \
		-e DISPLAY=$(WINDOWS_X11_DISPLAY) \
		-e QT_X11_NO_MITSHM=1 \
		hka-tools/asic
else
DISPLAY ?= :0
WAYLAND_DISPLAY ?= wayland-0
XDG_RUNTIME_DIR := /mnt/wslg/runtime-dir

run: check-docker 
	docker run -it --rm \
		--hostname hka-tools \
		-v "$(CURDIR):/workspace" \
		-e DISPLAY=$(DISPLAY) \
		-e WAYLAND_DISPLAY=$(WAYLAND_DISPLAY) \
		-e XDG_RUNTIME_DIR=$(XDG_RUNTIME_DIR) \
		-v /mnt/wslg:/mnt/wslg \
		-v /mnt/wslg/.X11-unix:/tmp/.X11-unix \
		-v /usr/lib/wsl:/usr/lib/wsl \
		-e PULSE_SERVER=unix:/mnt/wslg/PulseServer \
		hka-tools/asic
# todo: add uv sync to run bash cmd

run-windows-x11: check-docker 
	@echo "run-windows-x11 is only available from Windows; use 'make run' on Linux/WSL."
endif


# _______________________________________________
# Librelane

LIBRELANE_CONFIG ?= example/librelane.yaml
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
	WAVES=$(WAVES) SIM=$(SIM) uv run pytest example/tests/test.py
	gtkwave sim_build/*.ghw &