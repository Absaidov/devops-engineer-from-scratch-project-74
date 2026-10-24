DOCKER_COMPOSE ?= docker compose
TEST_COMPOSE = $(DOCKER_COMPOSE) -p devops-engineer-from-scratch-project-74-test -f docker-compose.yml
LOCAL_UID ?= $(shell id -u)
LOCAL_GID ?= $(shell id -g)
export LOCAL_UID LOCAL_GID

.PHONY: setup prepare-env build build-production push up dev down test test-clean ci logs

setup: prepare-env
	$(DOCKER_COMPOSE) run --rm app make setup

prepare-env:
	@test -f .env || cp .env.example .env

build:
	$(DOCKER_COMPOSE) build

build-production:
	$(DOCKER_COMPOSE) -f docker-compose.yml build app

push:
	$(DOCKER_COMPOSE) -f docker-compose.yml push app

up: prepare-env
	$(DOCKER_COMPOSE) up

dev: up

down:
	$(DOCKER_COMPOSE) down

test: prepare-env
	@trap '$(TEST_COMPOSE) down --volumes' EXIT; \
		$(TEST_COMPOSE) up --build --abort-on-container-exit --exit-code-from app

test-clean:
	$(TEST_COMPOSE) down --volumes

ci: test

logs:
	$(DOCKER_COMPOSE) logs -f
