FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# Install Python dependencies first so this layer caches across code changes.
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy application code.
COPY app ./app

# Run as a non-root user.
RUN useradd --create-home --shell /bin/bash appuser \
 && chown -R appuser:appuser /app
USER appuser

# Render injects $PORT at runtime; this default is only used for local `docker run`.
ENV PORT=8000
EXPOSE 8000

# Shell form so $PORT is expanded at container start.
CMD uvicorn app.main:app --host 0.0.0.0 --port $PORT
