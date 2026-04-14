FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache bash curl

WORKDIR /app

RUN mkdir -p config data

COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

EXPOSE 450 666

ENTRYPOINT ["./entrypoint.sh"]
