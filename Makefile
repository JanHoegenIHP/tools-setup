CONTAINER_NAME ?= hka-tools/asic

.PHONY: build run run-windows-x11 test-tools test-pdk check-docker check-running

PDK_ROOT ?= $(HOME)/pdks
PDK = ihp-sg13g2
PDK_VERSION ?= c4b8b4e5e7a05f375cca3815d51b3a37721fbf5c


# _______________________________________________
# platform agnostic Docker

build: check-docker
	docker build --tag hka-tools/asic .

test-tools: check-docker 
	docker run --rm \
		-v "$(CURDIR):/workspace" \
		-v "$(PDK_ROOT):/pdks" \
		hka-tools/asic python3 /workspace/tests/smoke_test.py

test-pdk:
	if [ ! -d "$(PDK_ROOT)/$(PDK)" ]; then \
		echo "PDK '$(PDK)' version '$(PDK_VERSION)' not found under $(PDK_ROOT)"; \
		echo "Run: ciel enable --pdk-family $(PDK) --pdk-root \"$(PDK_ROOT)\" $(PDK_VERSION)"; \
		exit 1; \
	fi

# _______________________________________________
# WSL bash Docker

ifneq ($(OS),Windows_NT)
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

DISPLAY ?= :0
WAYLAND_DISPLAY ?= wayland-0
XDG_RUNTIME_DIR := /mnt/wslg/runtime-dir
run: check-docker test-pdk
	docker run -it --rm \
		--hostname hka-tools \
		-v "$(CURDIR)/example:/workspace" \
		-v "$(PDK_ROOT):/pdks" \
		-e DISPLAY=$(DISPLAY) \
		-e WAYLAND_DISPLAY=$(WAYLAND_DISPLAY) \
		-e XDG_RUNTIME_DIR=$(XDG_RUNTIME_DIR) \
		-v /mnt/wslg:/mnt/wslg \
		-v /mnt/wslg/.X11-unix:/tmp/.X11-unix \
		-v /usr/lib/wsl:/usr/lib/wsl \
		-e PULSE_SERVER=unix:/mnt/wslg/PulseServer \
		hka-tools/asic
# todo: add uv sync to run bash cmd
endif


# _______________________________________________
# Windows cmd Docker

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

WSL_DISTRO ?= Ubuntu
WINDOWS_X11_DISPLAY ?= host.docker.internal:0.0
run: check-docker 
	wsl.exe -d "$(WSL_DISTRO)" -- env -u OS make run

# Requires a Windows X server (for example VcXsrv) listening on display 0.
# This target uses Docker Desktop directly, without WSLg socket mounts.
run-windows-x11: check-docker 
	docker run -it --rm \
		--hostname hka-tools \
		-v "$(CURDIR)/example:/workspace" \
		-v "$(PDK_ROOT):/pdks" \
		-e DISPLAY=$(WINDOWS_X11_DISPLAY) \
		-e QT_X11_NO_MITSHM=1 \
		hka-tools/asic
endif
