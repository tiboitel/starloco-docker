FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache bash curl netcat-openbsd mariadb-client

WORKDIR /app

ARG STARLOCO_LOGIN_REF=v1.0.1
RUN mkdir -p config data && \
    curl -L -o /app/login.jar https://github.com/StarLoco/StarLoco-Login/releases/download/${STARLOCO_LOGIN_REF}/login.jar && \
    addgroup -g 1000 starloco && \
    adduser -u 1000 -G starloco -s /bin/sh -D starloco && \
    chown -R starloco:starloco /app

COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

EXPOSE 450 666

USER starloco

ENTRYPOINT ["./entrypoint.sh"]
