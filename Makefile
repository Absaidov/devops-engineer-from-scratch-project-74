DOCKER_COMPOSE ?= docker compose
LOCAL_UID ?= $(shell id -u)
LOCAL_GID ?= $(shell id -g)
export LOCAL_UID LOCAL_GID

.PHONY: setup build up dev down test logs

setup:
	$(DOCKER_COMPOSE) run --rm app make setup

build:
	$(DOCKER_COMPOSE) build

up:
	$(DOCKER_COMPOSE) up

dev: up

down:
	$(DOCKER_COMPOSE) down

test:
	$(DOCKER_COMPOSE) -f docker-compose.yml up --abort-on-container-exit --exit-code-from app

logs:
	$(DOCKER_COMPOSE) logs -f app
