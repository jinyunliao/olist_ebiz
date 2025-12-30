# Deployment examples

This document includes simple, illustrative deployment patterns for local dev and production scheduling.

## Local development (docker-compose)

See `docker-compose.yml` for a minimal local setup with Postgres and a dbt container. Use this for fast iteration and tests.

## Production scheduling (Kubernetes CronJob)

The `k8s/dbt-cronjob.yaml` shows a basic CronJob that runs dbt deps, dbt run, and dbt test on a schedule. In production, replace `image` with a hardened image, provide secrets via Kubernetes Secrets, and add proper logging/monitoring.

## Recommendations

- Use a managed scheduler (Cloud Composer, MWAA) for enterprise use when possible
- Use a secure artifact registry for Docker images and signed images
- Add alerts on job failures and SLA breaches; maintain a runbook for incident response
