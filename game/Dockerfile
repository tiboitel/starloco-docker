FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache bash curl git netcat-openbsd

WORKDIR /app

RUN mkdir -p config data scripts/data scripts/models && \
    addgroup -g 1000 starloco && \
    adduser -u 1000 -G starloco -s /bin/sh -D starloco && \
    chown -R starloco:starloco /app

COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

EXPOSE 5555 666

USER starloco

ENTRYPOINT ["./entrypoint.sh"]
