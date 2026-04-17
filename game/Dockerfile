FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache bash curl git netcat-openbsd mariadb-client

WORKDIR /app

ARG STARLOCO_GAME_REF=v1.0.6
RUN mkdir -p config data scripts/data scripts/models && \
    git clone --depth 1 --branch ${STARLOCO_GAME_REF} https://github.com/StarLoco/StarLoco-Game.git /tmp/starloco-game && \
    cp -r /tmp/starloco-game/scripts/* /app/scripts/ && \
    curl -L -o /app/game.jar https://github.com/StarLoco/StarLoco-Game/releases/download/${STARLOCO_GAME_REF}/game.jar && \
    rm -rf /tmp/starloco-game && \
    addgroup -g 1000 starloco && \
    adduser -u 1000 -G starloco -s /bin/sh -D starloco && \
    chown -R starloco:starloco /app

COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

EXPOSE 5555 666

USER starloco

ENTRYPOINT ["./entrypoint.sh"]
