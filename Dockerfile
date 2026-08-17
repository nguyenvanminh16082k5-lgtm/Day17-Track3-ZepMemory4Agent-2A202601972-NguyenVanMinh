FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONPATH=/workspace

WORKDIR /workspace

# Dùng uv để cài đặt song song siêu tốc và không bị lỗi timeout dependency
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
COPY requirements.txt /tmp/requirements.txt
RUN uv pip install --system -r /tmp/requirements.txt

COPY . /workspace

CMD ["sleep", "infinity"]
