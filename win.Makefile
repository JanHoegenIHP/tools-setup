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

# Requires a Windows X server (for example VcXsrv) listening on display 0.
# This target uses Docker Desktop directly, without WSLg socket mounts.
run: check-docker 
	docker run -it --rm \
		--hostname hka-tools \
		-v "$(CURDIR)/example:/workspace" \
		-v "$(PDK_ROOT):/pdks" \
		-e DISPLAY=$(WINDOWS_X11_DISPLAY) \
		-e QT_X11_NO_MITSHM=1 \
		hka-tools/asic
endif
