SERVICE_NAME := collection-count
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

# Build the Docker test image
#build-test-docker:
#	./scripts/build-docker.sh $(DOCKER_TEST_IMAGE) $(VERSION) Dockerfile.test

# Run unit tests
#test-unit:
#	./scripts/test-unit.sh

# Run unit tests with Code Climate coverage
#test-unit-code-climate:
#	./scripts/test-unit-code-climate.sh

# Run component tests
#test-component: build-docker build-test-docker
#	./scripts/test-component.sh

#.PHONY: install-gometalinter lint
#.PHONY: build build-docker build-test-docker
#.PHONY: test-unit test-unit-code-climate test-component
