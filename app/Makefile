PNPM := $(if $(shell command -v pnpm 2>/dev/null),pnpm,npm exec --yes --package=pnpm@12.6.0 -- pnpm)

setup: install build

install:
	$(PNPM) install

build:
	$(PNPM) run build

prepare-env:
	cp -n .env.example .env

start:
	NODE_ENV=production $(PNPM) run start

dev:
	$(PNPM) exec concurrently "make start-frontend" "make start-backend"

start-backend:
	$(PNPM) run start --watch --verbose-watch --ignore-watch='node_modules .git dist database'

start-frontend:
	$(PNPM) exec vite build --watch

lint:
	$(PNPM) --silent run lint
	$(PNPM) --silent run format:check

lint-fix:
	$(PNPM) --silent run lint:fix

test:
	NODE_ENV=test $(PNPM) --silent test
