# Changelog

## 1.0.0 (2026-04-17)


### Features

* add TLS for MariaDB and non-root users ([ecbc6fb](https://github.com/tiboitel/starloco-docker/commit/ecbc6fb43665b19397530936eb7f6a9baf077057))
* add web service with Docker, secrets injection, and MariaDB health dependency ([e6253dc](https://github.com/tiboitel/starloco-docker/commit/e6253dc901a07362ea6f738938a6af6f6ec97974))


### Bug Fixes

* add GAME_SERVER_DEBUG env var and fix typo encryption ([4d46f9a](https://github.com/tiboitel/starloco-docker/commit/4d46f9ac65411b1354d11b0022f40206c89437a2))
* add missing healthchecks and web volume readonly ([6fe35ef](https://github.com/tiboitel/starloco-docker/commit/6fe35ef827ea4e05ca483e4a6baa39ae3d52a7c9))
* add retry and verification to world_servers update ([b62732f](https://github.com/tiboitel/starloco-docker/commit/b62732f1851961701ce400dc5ef80d91cc938ad8))
* build game service locally instead of pulling from registry ([59e2425](https://github.com/tiboitel/starloco-docker/commit/59e2425be67138ff24c116013431d5fb5522c482))
* correct argument parsing in run.sh ([72473ad](https://github.com/tiboitel/starloco-docker/commit/72473ad820949278ce263a37dbf83b156febd3e9))
* enforce resource limits in Compose with native keys ([93b854d](https://github.com/tiboitel/starloco-docker/commit/93b854dbf156730be51f6effb766a842c701e107))
* harden web container healthcheck ([c020530](https://github.com/tiboitel/starloco-docker/commit/c02053045dfe690ca0c0a4adebc9fc0020e8ebc4))
* move world_servers update to login startup to resolve race ([07181d1](https://github.com/tiboitel/starloco-docker/commit/07181d18f564cf789c1486e9e5ca74161437afe5))
* proper error exit and password handling in world_servers update ([a3d3f86](https://github.com/tiboitel/starloco-docker/commit/a3d3f86d43636854b80d7b07018c3f702e099cae))
* remove localhost grant from init SQL (caused init failure) ([7ab910c](https://github.com/tiboitel/starloco-docker/commit/7ab910c14bf1c67c1daf361ae1bd430c13388b5b))
* remove prod image tags, add redis dependency, add backup/restore, add README ([b87ffbb](https://github.com/tiboitel/starloco-docker/commit/b87ffbb06fd7c35d7b882ac8109b8226d752b42e))
* remove unused mariadb root secret wiring ([203752b](https://github.com/tiboitel/starloco-docker/commit/203752b8c7b8b7958e2a909ff1b6561ce5298702))
* resolve Copilot review comments ([d01ca0e](https://github.com/tiboitel/starloco-docker/commit/d01ca0eedd766559265e1023e9ac223d32dcb865))
* restrict drops to hunter job only (meats with job 41) ([a5a16a0](https://github.com/tiboitel/starloco-docker/commit/a5a16a0d837efe19c69f88e7d431a751a7012757))
* sync game server identity from env ([733d710](https://github.com/tiboitel/starloco-docker/commit/733d710c7c61e6fcbc90ffaf271540a13ea43956))
* use PHP healthcheck, remove dead static healthz ([0a712df](https://github.com/tiboitel/starloco-docker/commit/0a712df7adabc4eaacbb39359e73a29f2ce01d6c))
* wait for login health before game exchange ([2bf29b7](https://github.com/tiboitel/starloco-docker/commit/2bf29b70c338041cd408ac4908c7b5b60b676ad8))


### Performance Improvements

* parallelize CI builds with matrix strategy ([12b78c1](https://github.com/tiboitel/starloco-docker/commit/12b78c1fc253e5c7d99d29b4d3e5e6037c7e41dd))


### Reverts

* remove .opencode from git ([88b7aa6](https://github.com/tiboitel/starloco-docker/commit/88b7aa6ad57e87094fe08f942a1978cca35b47a4))
* remove TLS for MariaDB (SSL_CTX_set_default_verify_paths issue) ([c85ecaa](https://github.com/tiboitel/starloco-docker/commit/c85ecaa5ad20d4681f0721f87b4438db6332ff9c))
