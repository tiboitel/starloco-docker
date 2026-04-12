FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache bash curl git netcat-openbsd

WORKDIR /app

RUN mkdir -p config data scripts/data scripts/models

COPY run.sh ./
RUN chmod +x run.sh

EXPOSE 5555 666

ENTRYPOINT ["./run.sh"]
