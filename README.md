# Упаковка в Docker Compose

[![hexlet-check](https://github.com/Absaidov/devops-engineer-from-scratch-project-74/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/Absaidov/devops-engineer-from-scratch-project-74/actions)

Учебный проект по автоматизации развертывания локального окружения. Приложение [JS Fastify Blog](https://github.com/hexlet-components/js-fastify-blog) находится в каталоге `app/`.

Учебный проект Хекслета: https://ru.hexlet.io/programs/devops-engineer-from-scratch
Как это должно работать: https://asciinema.org/a/zVrFYtslVReMsTyqEEetdWUY5

## Стек

- Docker и Docker Compose
- Node.js 26 и pnpm 12.6.0 (в контейнере)
- Fastify, Vite и PGlite (встроенная база данных приложения)

## Установка

Установите и запустите Docker с Docker Compose v2 (минимальная версия Compose по заданию — 1.27.0). Для коротких команд нужен Make. Node.js и pnpm на хост-машине не требуются.

```bash
git clone https://github.com/Absaidov/devops-engineer-from-scratch-project-74.git
cd devops-engineer-from-scratch-project-74

# Сборка образа, установка зависимостей и сборка приложения.
make setup
```

## Использование

Запустите приложение для разработки:

```bash
make dev
```

Откройте [http://localhost:8080](http://localhost:8080). Для остановки нажмите `Ctrl+C`, затем удалите контейнеры:

```bash
make down
```

### Тесты

```bash
make test
```

Основной файл `docker-compose.yml` собирает готовое приложение из `Dockerfile.production` и запускает в нём `make test` без монтирования локальных файлов. Команда `make test` пересобирает образ перед запуском, чтобы тесты проверяли текущий код.

Для разработки Compose автоматически подключает `docker-compose.override.yml`: он выбирает `Dockerfile`, монтирует `app/` в `/app`, заменяет команду на `make dev` и публикует порт 8080. Для этого режима используется отдельный локальный тег `devops-engineer-from-scratch-project-74:development`.

`make test` явно выбирает только основной файл. Команда завершает Compose после окончания тестов и возвращает код завершения сервиса `app`:

```bash
docker compose -f docker-compose.yml up --abort-on-container-exit --exit-code-from app
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
| `make build` | Собрать образ для разработки |
| `make build-production` | Собрать готовое приложение для Docker Hub |
| `make push` | Загрузить production-образ на Docker Hub |
| `make dev` / `make up` | Запустить приложение для разработки |
| `make test` | Собрать production-образ и запустить тесты без override |
| `make down` | Остановить и удалить контейнеры |
| `make logs` | Смотреть логи приложения |

Для разработки Makefile передаёт UID/GID текущего пользователя, чтобы файлы не создавались от root. При использовании Compose напрямую задайте их в терминале:

```bash
export LOCAL_UID="$(id -u)"
export LOCAL_GID="$(id -g)"

docker compose run --rm app make setup
docker compose up
```

В примерах используется `docker compose`. Если установлен отдельный `docker-compose`, команды Makefile можно вызывать с `DOCKER_COMPOSE=docker-compose`, например `make test DOCKER_COMPOSE=docker-compose`.

В режиме разработки кеши npm и pnpm находятся в `/tmp` контейнера. Зависимости копируются из кеша в `app/node_modules/`, чтобы установка работала и с примонтированными каталогами Docker Desktop. Локальная база хранится в `app/database/`. Зависимости, база и результат сборки исключены из Git.

---

<details>
<summary>Автоматические тесты Хекслета</summary>

Тесты запускаются на каждый коммит. За запуск отвечает файл `.github/workflows/hexlet-check.yml` — не удаляйте и не переименовывайте ни его, ни репозиторий.

</details>

## О Хекслете

[Хекслет](https://ru.hexlet.io/) — школа программирования: авторские программы обучения с практикой, поддержкой наставников и реальными проектами, которые остаются в резюме. Этот репозиторий — один из таких проектов.
