FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache bash curl git netcat-openbsd

WORKDIR /app

RUN mkdir -p config data scripts/data scripts/models

COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

EXPOSE 5555 666

ENTRYPOINT ["./entrypoint.sh"]
