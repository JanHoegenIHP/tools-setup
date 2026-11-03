.PHONY: build run run-windows-x11

build:
	docker build --tag hka-tools/asic .

# todo: add user and shell id from host to avoid permission issues when mounting volumes
ifeq ($(OS),Windows_NT)
WSL_DISTRO ?= Ubuntu
WINDOWS_X11_DISPLAY ?= host.docker.internal:0.0

run:
	wsl.exe -d "$(WSL_DISTRO)" -- env -u OS make run

# Requires a Windows X server (for example VcXsrv) listening on display 0.
# This target uses Docker Desktop directly, without WSLg socket mounts.
run-windows-x11:
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

run:
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

run-windows-x11:
	@echo "run-windows-x11 is only available from Windows; use 'make run' on Linux/WSL."
endif