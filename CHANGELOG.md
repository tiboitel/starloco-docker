# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-04-17

### Added
- Initial release: five services (login, game, mariadb, redis, web)
- One-command deployment via `./run.sh start`
- Auto-generated secrets
- Production mode with resource limits
- Health checks for all services
- JSON logging for observability
- CI/CD pipeline with PR validation
- Manual release workflow via GitHub Actions
- Experimental fork support with build args

### Features
- Login server on port 450
- Game server on port 5555
- Web portal on port 80
- MariaDB database
- Redis cache
- Backup and restore commands
- Troubleshooting guide

### Security
- Non-root containers for login and game
- PHP-FPM running as www-data
- Secrets managed via Docker secrets

### Documentation
- README.md with quick start
- Fork support guide
- Backup and restore guide
- Troubleshooting guide
- FAQ

[Unreleased]: https://github.com/tiboitel/starloco-docker/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/tiboitel/starloco-docker/releases/tag/v1.0.0