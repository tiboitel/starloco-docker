FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache bash curl git netcat-openbsd mariadb-client

WORKDIR /app

ARG STARLOCO_GAME_REPO=https://github.com/StarLoco/StarLoco-Game.git
ARG STARLOCO_GAME_REF=v1.0.6
ARG STARLOCO_GAME_JAR=game.jar
RUN mkdir -p config data scripts/data scripts/models && \
    git clone --depth 1 --branch ${STARLOCO_GAME_REF} ${STARLOCO_GAME_REPO} /tmp/starloco-game && \
    cp -r /tmp/starloco-game/scripts/* /app/scripts/ && \
    curl -L -o /app/${STARLOCO_GAME_JAR} ${STARLOCO_GAME_REPO%.*}/releases/download/${STARLOCO_GAME_REF}/${STARLOCO_GAME_JAR} && \
    rm -rf /tmp/starloco-game && \
    addgroup -g 1000 starloco && \
    adduser -u 1000 -G starloco -s /bin/sh -D starloco && \
    chown -R starloco:starloco /app

COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

EXPOSE 5555 666

USER starloco

ENTRYPOINT ["./entrypoint.sh"]
