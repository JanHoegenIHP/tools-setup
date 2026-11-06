CONTAINER_NAME ?= hka-tools/asic

.PHONY: build run run-win test-tools test-pdk test-docker check-docker check-running export

PDK_ROOT ?= $(USERPROFILE)/pdks
PDK = ihp-sg13g2
PDK_VERSION ?= c4b8b4e5e7a05f375cca3815d51b3a37721fbf5c


# _______________________________________________
# tests

test-pdk:
	@if not exist "$(PDK_ROOT)/$(PDK)" (echo PDK '$(PDK)' not found under '$(PDK_ROOT)' & exit 1)

test-docker:
	@docker info >nul 2>&1 || (echo ERROR: Docker is not running or is not accessible. Please start Docker Desktop and try again. & exit 1)

# _______________________________________________
# main

build: test-docker
	docker build --tag hka-tools/asic .

DISPLAY ?= host.docker.internal:0.0

run: test-docker test-pdk
	docker run -it --rm \
		--hostname hka-tools \
		-v "$(CURDIR)/example:/workspace" \
		-v "$(PDK_ROOT):/pdks" \
		-e "PDK=$(PDK)" \
		-e "PDK_VERSION=$(PDK_VERSION)" \
		-e DISPLAY=$(DISPLAY) \
		hka-tools/asic

save:
	docker save hka-tools/asic