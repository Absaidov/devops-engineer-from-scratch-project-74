DOCKER_COMPOSE ?= docker compose
LOCAL_UID ?= $(shell id -u)
LOCAL_GID ?= $(shell id -g)
export LOCAL_UID LOCAL_GID

.PHONY: setup build build-production push up dev down test ci logs

setup:
	$(DOCKER_COMPOSE) run --rm app make setup

build:
	$(DOCKER_COMPOSE) build

build-production:
	$(DOCKER_COMPOSE) -f docker-compose.yml build app

push:
	$(DOCKER_COMPOSE) -f docker-compose.yml push app

up:
	$(DOCKER_COMPOSE) up

dev: up

down:
	$(DOCKER_COMPOSE) down

test:
	$(DOCKER_COMPOSE) -f docker-compose.yml up --build --abort-on-container-exit --exit-code-from app

ci: test

logs:
	$(DOCKER_COMPOSE) logs -f
