SERVICE_NAME := helm-chart-tutorial
DOCKER_IMAGE := jimareed/$(SERVICE_NAME)
DOCKER_TEST_IMAGE := $(SERVICE_NAME)-test
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
