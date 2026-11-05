CONTAINER_NAME ?= hka-tools/asic

.PHONY: build run test-tools test-pdk check-docker check-running export

PDK_ROOT ?= $(HOME)/pdks
PDK = ihp-sg13g2


# _______________________________________________
# tests

test-tools: check-docker 
	docker run --rm \
		-v "$(CURDIR):/workspace" \
		-v "$(PDK_ROOT):/pdks" \
		hka-tools/asic python3 /workspace/tests/smoke_test.py

PDK_VERSION ?= c4b8b4e5e7a05f375cca3815d51b3a37721fbf5c
test-pdk:
	if [ ! -d "$(PDK_ROOT)/$(PDK)" ]; then \
		echo "PDK '$(PDK)' not found under $(PDK_ROOT)"; \
		echo "Run: ciel enable --pdk-family $(PDK) --pdk-root \"$(PDK_ROOT)\" $(PDK_VERSION)"; \
		exit 1; \
	fi

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


# _______________________________________________
# main

build: check-docker
	docker build --tag hka-tools/asic .

DISPLAY ?= :0
WAYLAND_DISPLAY ?= wayland-0
XDG_RUNTIME_DIR := /mnt/wslg/runtime-dir
LIBGL_ALWAYS_SOFTWARE ?= 0
run: check-docker test-pdk
	docker run -it --rm \
		--hostname hka-tools \
		-v "$(CURDIR)/example:/workspace" \
		-v "$(PDK_ROOT):/pdks" \
		-e "PDK=$(PDK)" \
		-e "PDK_VERSION=$(PDK_VERSION)" \
		-e "KLAYOUT_HOME=/home/developer/.klayout" \
		-e "KLAYOUT_PATH=/home/developer/.klayout:/pdks/ciel/$(PDK)/versions/$(PDK_VERSION)/$(PDK)/libs.tech/klayout" \
		-e DISPLAY=$(DISPLAY) \
		-e WAYLAND_DISPLAY=$(WAYLAND_DISPLAY) \
		-e XDG_RUNTIME_DIR=$(XDG_RUNTIME_DIR) \
		-e LIBGL_ALWAYS_SOFTWARE=$(LIBGL_ALWAYS_SOFTWARE) \
		-v /mnt/wslg:/mnt/wslg \
		-v /mnt/wslg/.X11-unix:/tmp/.X11-unix \
		-v /usr/lib/wsl:/usr/lib/wsl \
		--device=/dev/dxg \
		-e PULSE_SERVER=unix:/mnt/wslg/PulseServer \
		hka-tools/asic
# todo: add uv sync to run bash cmd

save:
	docker save hka-tools/asic | gzip > hka-tools-asic.tar.gz