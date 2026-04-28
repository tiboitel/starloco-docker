FROM python:3.10-slim

ARG ZAAP_REPO=https://github.com/tiboitel/zaap.git
ARG ZAAP_REF=d2ba4204e7aee57d463a3b77fe4f98c7807fc835

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends git curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone "${ZAAP_REPO}" /app/zaap \
    && cd /app/zaap \
    && git checkout --detach "${ZAAP_REF}"

WORKDIR /app/zaap

RUN useradd --create-home --shell /bin/sh appuser \
    && chown -R appuser:appuser /app/zaap

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

USER appuser

RUN python -m venv /home/appuser/venv \
    && /home/appuser/venv/bin/pip install --no-cache-dir --upgrade pip \
    && /home/appuser/venv/bin/pip install --no-cache-dir .

ENV PATH="/home/appuser/venv/bin:$PATH"

EXPOSE 8000

ENV PYTHONUNBUFFERED=1

ENTRYPOINT ["/entrypoint.sh"]
