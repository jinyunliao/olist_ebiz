FROM python:3.10-slim

WORKDIR /app

# Install system deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY . /app

# Install Python deps
RUN pip install --upgrade pip
RUN if [ -f requirements.txt ]; then pip install -r requirements.txt; else pip install dbt-core dbt-postgres; fi

ENV DBT_PROFILES_DIR=/app

CMD ["/bin/bash"]
