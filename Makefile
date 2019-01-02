DOCKER_REGISTRY := williamchanrico
SERVICE_NAME := items-count-app
DOCKER_IMAGE := $(DOCKER_REGISTRY)/$(SERVICE_NAME)
VERSION ?= latest

# Compile Go packages and dependencies
build:
	./build.sh $(SERVICE_NAME)

# Build the Docker image
build-docker:
	./build-docker.sh $(DOCKER_IMAGE) $(VERSION) Dockerfile
