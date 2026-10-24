# Упаковка в Docker Compose

[![hexlet-check](https://github.com/Absaidov/devops-engineer-from-scratch-project-74/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/Absaidov/devops-engineer-from-scratch-project-74/actions)
[![Docker CI](https://github.com/Absaidov/devops-engineer-from-scratch-project-74/actions/workflows/push.yml/badge.svg?branch=main)](https://github.com/Absaidov/devops-engineer-from-scratch-project-74/actions/workflows/push.yml)

Учебный проект по автоматизации развертывания локального окружения. Приложение [JS Fastify Blog](https://github.com/hexlet-components/js-fastify-blog) находится в каталоге `app/`.

Учебный проект Хекслета: https://ru.hexlet.io/programs/devops-engineer-from-scratch
Как это должно работать: https://asciinema.org/a/zVrFYtslVReMsTyqEEetdWUY5

## Стек

- Docker и Docker Compose
- Node.js 26 и pnpm 12.6.0 (в контейнере)
- Fastify, Vite и PostgreSQL (сервис `db` в Docker Compose)
- Caddy 2 (reverse proxy, локальный HTTPS и сжатие zstd)

## Установка

Установите и запустите Docker с Docker Compose v2 (минимальная версия Compose по заданию — 1.27.0). Для коротких команд нужен Make. Node.js и pnpm на хост-машине не требуются.

```bash
git clone https://github.com/Absaidov/devops-engineer-from-scratch-project-74.git
cd devops-engineer-from-scratch-project-74

# Создание .env, установка зависимостей и сборка приложения.
make setup
```

`make setup` создаёт корневой `.env` из `.env.example`, если файла ещё нет. Существующие настройки сохраняются. Отдельно подготовить окружение можно командой `make prepare-env`.

Автопроверка Хекслета также вызывает `make setup` непосредственно в `app/`. Поэтому команды `app/Makefile` используют установленный pnpm, а если его нет в PATH — запускают pnpm 12.6.0 через `npm exec`. Для такого запуска требуются Node.js 26 и npm; глобальная установка pnpm не нужна.

## Использование

Запустите приложение для разработки:

```bash
make dev
```

Откройте [https://localhost](https://localhost). Запросы на [http://localhost](http://localhost) автоматически перенаправляются на HTTPS. Caddy передаёт запросы сервису `app:8080`. Приложение также доступно напрямую на [http://localhost:8080](http://localhost:8080).

Для остановки нажмите `Ctrl+C`, затем удалите контейнеры:

```bash
make down
```

### Локальный HTTPS и Caddy

Сервис `caddy` определён в `docker-compose.override.yml` и запускается вместе с приложением. Каталог `services/caddy/` подключён к `/etc/caddy` только для чтения; конфигурация находится в `services/caddy/Caddyfile`. Caddy публикует порты 80 и 443, пишет access-логи в JSON и сжимает ответы в zstd, если клиент поддерживает этот формат.

`tls internal` выпускает сертификат для `localhost` через локальный центр сертификации Caddy. Браузер может показать предупреждение, пока этот центр не добавлен в доверенные на хост-машине. Данные центра и сертификаты сохраняются в Docker volume `caddy_data`, рабочая конфигурация — в `caddy_config`; `make down` сохраняет эти volumes.

Проверка перенаправления и HTTPS без изменения системного хранилища сертификатов:

```bash
curl -I http://localhost
docker compose cp caddy:/data/caddy/pki/authorities/local/root.crt /tmp/project-74-caddy-root.crt
curl --cacert /tmp/project-74-caddy-root.crt https://localhost
```

Логи всех сервисов доступны через `make logs`. После изменения Caddyfile конфигурацию можно перечитать без перезапуска контейнера:

```bash
docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile
```

### PostgreSQL и переменные окружения

Основной Compose-файл содержит сервис `db` с официальным образом `postgres:latest`. Приложение подключается к нему по имени `db` внутри Docker-сети; порт PostgreSQL на хост не публикуется. Healthcheck проверяет готовность сервера через `pg_isready`, а `app` запускается после перехода БД в состояние `healthy`.

Параметры подключения задаются в корневом `.env`:

```dotenv
DATABASE_HOST=db
DATABASE_NAME=postgres
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=password
DATABASE_PORT=5432
```

Compose передаёт эти значения приложению как `DATABASE_*`, а контейнеру БД — как `POSTGRES_DB`, `POSTGRES_USER` и `POSTGRES_PASSWORD`. `.env` исключён из Git и Docker-контекста; в репозитории хранится `.env.example`.

В текущей версии JS Fastify Blog нет `app/config/config.cjs`: PostgreSQL выбирается по переменным окружения в `app/server/plugins/db.js`, миграции Drizzle применяются при запуске приложения. PGlite остаётся вариантом для запуска приложения отдельно, без адреса внешней БД.

Данные PostgreSQL сохраняются в volume `postgres_data`, подключённом к `/var/lib/postgresql` (путь официального образа PostgreSQL 18+). `make down` сохраняет данные. Состояние сервисов и подключение к БД можно проверить командами:

```bash
docker compose ps
docker compose exec db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"'
```

### Тесты

```bash
make test
```

Основной файл `docker-compose.yml` собирает готовое приложение из `Dockerfile.production` и запускает в нём `make test` без монтирования локальных файлов. Тесты используют настоящий PostgreSQL из сервиса `db`. Команда `make test` пересобирает образ перед запуском, чтобы тесты проверяли текущий код.

`make test` и `make ci` используют отдельный Compose-проект `devops-engineer-from-scratch-project-74-test` с собственной БД. После прогона его контейнеры, сеть и volume удаляются, в том числе при ошибке тестов. Повторные прогоны начинают с чистой БД и не затрагивают данные разработки.

Для разработки Compose автоматически подключает `docker-compose.override.yml`: он выбирает `Dockerfile`, монтирует `app/` в `/app`, заменяет команду на `make dev`, публикует порт 8080 и добавляет Caddy на портах 80 и 443. Для этого режима используется отдельный локальный тег `devops-engineer-from-scratch-project-74:development`.

Для образа разработки задано `pull_policy: build`: Compose собирает его из `Dockerfile` и пропускает его при `docker compose pull`. Тег `development` используется локально и не требует публикации в Docker Hub.

`make test` явно выбирает только основной файл. Команда завершает Compose после окончания тестов и возвращает код завершения сервиса `app`:

```bash
docker compose -p devops-engineer-from-scratch-project-74-test -f docker-compose.yml \
  up --build --abort-on-container-exit --exit-code-from app
make test-clean
```

### GitHub Actions

Workflow `.github/workflows/push.yml` запускается на каждый `push` и вручную через `workflow_dispatch`. Сначала `make ci` собирает production-образ и запускает тесты с PostgreSQL через Docker Compose без override. После успешных тестов Docker Actions собирают `Dockerfile.production` и публикуют `dabsaidov/devops-engineer-from-scratch-project-74:latest`. При ошибке тестов публикация не выполняется.

Для автоматической публикации создайте в аккаунте `dabsaidov` [Docker Hub access token](https://docs.docker.com/security/access-tokens/personal-access-tokens/) с правами Read и Write. Сохраните его в [настройках секретов репозитория](https://github.com/Absaidov/devops-engineer-from-scratch-project-74/settings/secrets/actions) под именем `DOCKERHUB_TOKEN` (Settings → Secrets and variables → Actions → New repository secret). Логин `dabsaidov` уже указан в workflow. Локальный `docker login` не передаёт авторизацию в GitHub Actions.

После добавления секрета и отправки коммита проверьте [запуск Docker CI](https://github.com/Absaidov/devops-engineer-from-scratch-project-74/actions/workflows/push.yml). После успешной публикации badge станет зелёным. Повторить запуск можно через Re-run jobs или Run workflow.

Локальная проверка той же командой, которую использует CI:

```bash
make ci
```

### Production и Docker Hub

Production-образ: `dabsaidov/devops-engineer-from-scratch-project-74:latest` ([Docker Hub](https://hub.docker.com/r/dabsaidov/devops-engineer-from-scratch-project-74)). Он содержит код, зависимости и собранные стили; по умолчанию запускает `make start` от пользователя `node` и слушает порт 8080.

Приложение использует pnpm, поэтому перед копированием исходников в образ отдельно копируются `package.json`, `pnpm-lock.yaml` и `pnpm-workspace.yaml`, а зависимости устанавливаются через `pnpm install --frozen-lockfile`. Слой переиспользуется, пока эти файлы не меняются. Зависимости для разработки сохраняются в образе: они нужны для `make test` и проверки `make dev` по заданию.

Создайте репозиторий `devops-engineer-from-scratch-project-74` в аккаунте `dabsaidov` на Docker Hub и выполните вход:

```bash
docker login
make build-production
make push
```

Проверка опубликованного образа без локального кода (предварительно остановите локальное приложение командой `make down`):

```bash
docker pull dabsaidov/devops-engineer-from-scratch-project-74:latest
docker run --rm -p 8080:8080 -e NODE_ENV=development \
  dabsaidov/devops-engineer-from-scratch-project-74:latest make dev
```

Чтобы запустить production-команду образа, не передавайте `make dev`:

```bash
docker run --rm -p 8080:8080 \
  dabsaidov/devops-engineer-from-scratch-project-74:latest
```

### Команды

| Команда | Действие |
| --- | --- |
| `make setup` | Установить зависимости и собрать приложение |
| `make prepare-env` | Создать `.env` из `.env.example`, если его ещё нет |
| `make build` | Собрать образ для разработки |
| `make build-production` | Собрать готовое приложение для Docker Hub |
| `make push` | Загрузить production-образ на Docker Hub |
| `make dev` / `make up` | Запустить приложение для разработки |
| `make test` | Собрать production-образ и запустить тесты без override |
| `make ci` | Выполнить тот же прогон тестов, что и GitHub Actions |
| `make test-clean` | Удалить контейнеры и данные только тестового Compose-проекта |
| `make down` | Остановить и удалить контейнеры |
| `make logs` | Смотреть логи приложения, PostgreSQL и Caddy |

Для разработки Makefile передаёт UID/GID текущего пользователя, чтобы файлы не создавались от root. При использовании Compose напрямую задайте их в терминале:

```bash
export LOCAL_UID="$(id -u)"
export LOCAL_GID="$(id -g)"

make prepare-env
docker compose run --rm app make setup
docker compose up
```

В примерах используется `docker compose`. Если установлен отдельный `docker-compose`, команды Makefile можно вызывать с `DOCKER_COMPOSE=docker-compose`, например `make test DOCKER_COMPOSE=docker-compose`.

В режиме разработки кеши npm и pnpm находятся в `/tmp` контейнера. Зависимости копируются из кеша в `app/node_modules/`, чтобы установка работала и с примонтированными каталогами Docker Desktop. База хранится в Docker volume `postgres_data`. Каталоги зависимостей, результат сборки и `.env` исключены из Git.

---

<details>
<summary>Автоматические тесты Хекслета</summary>

Тесты запускаются на каждый коммит. За запуск отвечает файл `.github/workflows/hexlet-check.yml` — не удаляйте и не переименовывайте ни его, ни репозиторий.

</details>

## О Хекслете

[Хекслет](https://ru.hexlet.io/) — школа программирования: авторские программы обучения с практикой, поддержкой наставников и реальными проектами, которые остаются в резюме. Этот репозиторий — один из таких проектов.
