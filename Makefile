SERVICE_NAME := helm-chart-tutorial
DOCKER_IMAGE := $(SERVICE_NAME)
VERSION ?= latest

# Lint the code
#lint:
#	./scripts/lint.sh

# Compile Go packages and dependencies
build:
	./build.sh $(SERVICE_NAME)

# Build the Docker image
build-docker:
	./build-docker.sh $(DOCKER_IMAGE) $(VERSION) Dockerfile
