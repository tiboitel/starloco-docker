FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache bash curl netcat-openbsd mariadb-client

WORKDIR /app

ARG STARLOCO_LOGIN_REPO=https://github.com/StarLoco/StarLoco-Login.git
ARG STARLOCO_LOGIN_REF=v1.0.1
ARG STARLOCO_LOGIN_JAR=login.jar
RUN mkdir -p config data && \
    curl -L -o /app/${STARLOCO_LOGIN_JAR} ${STARLOCO_LOGIN_REPO%.*}/releases/download/${STARLOCO_LOGIN_REF}/${STARLOCO_LOGIN_JAR} && \
    addgroup -g 1000 starloco && \
    adduser -u 1000 -G starloco -s /bin/sh -D starloco && \
    chown -R starloco:starloco /app

COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

EXPOSE 450 666

USER starloco

ENTRYPOINT ["./entrypoint.sh"]
