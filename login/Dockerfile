FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache bash curl

WORKDIR /app

RUN mkdir -p config data

COPY run.sh ./
RUN chmod +x run.sh

EXPOSE 450 666

ENTRYPOINT ["./run.sh"]
