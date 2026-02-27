# ============================================================================
# COBOL Protocol - Nafal Faturizki Edition
# Ultra-Extreme 8-Layer Decentralized Compression Engine
# Docker Image for Production Deployment
# ============================================================================

FROM python:3.11-slim-bullseye

# Metadata
LABEL maintainer="COBOL Protocol Team"
LABEL version="1.0"
LABEL description="Ultra-extreme 8-layer compression engine for LLM datasets"

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    libssl-dev \
    ca-certificates \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY requirements.txt .
COPY config.py .
COPY engine.py .
COPY __init__.py .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Create non-root user for security
RUN useradd -m -u 1000 cobol && chown -R cobol:cobol /app
USER cobol

# Expose ports for distributed node communication
EXPOSE 9000-9008

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONHASHSEED=random
ENV COBOL_PRODUCTION=1

# Health check script
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "from engine import CobolEngine; e = CobolEngine(); print('ready')"

# Default command: run engine in server mode
CMD ["python", "-m", "engine"]
