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

Установите и запустите Docker. Node.js и pnpm на хост-машине не требуются.

```bash
git clone https://github.com/Absaidov/devops-engineer-from-scratch-project-74.git
cd devops-engineer-from-scratch-project-74

# Используем UID/GID текущего пользователя, чтобы файлы не создавались от root.
export LOCAL_UID="$(id -u)"
export LOCAL_GID="$(id -g)"

# Установка зависимостей и сборка приложения.
docker compose run --rm app npm exec --yes --package=pnpm@12.6.0 -- make setup
```

## Использование

В том же терминале запустите приложение:

```bash
docker compose up
```

Откройте [http://localhost:8080](http://localhost:8080). Для остановки нажмите `Ctrl+C`, затем удалите контейнеры:

```bash
docker compose down
```

При запуске из нового терминала снова задайте `LOCAL_UID` и `LOCAL_GID` командами выше. pnpm запускается через `npm exec`, поскольку в образе Node.js 26 он не предустановлен.

Кеши npm и pnpm находятся в `/tmp` контейнера. Зависимости копируются из кеша в `app/node_modules/`, чтобы установка работала и с примонтированными каталогами Docker Desktop. Локальная база хранится в `app/database/`. Зависимости, база и результат сборки исключены из Git.

---

<details>
<summary>Автоматические тесты Хекслета</summary>

Тесты запускаются на каждый коммит. За запуск отвечает файл `.github/workflows/hexlet-check.yml` — не удаляйте и не переименовывайте ни его, ни репозиторий.

</details>

## О Хекслете

[Хекслет](https://ru.hexlet.io/) — школа программирования: авторские программы обучения с практикой, поддержкой наставников и реальными проектами, которые остаются в резюме. Этот репозиторий — один из таких проектов.
