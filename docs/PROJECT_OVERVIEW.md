# Project overview — olist_ebiz

## Summary

This document provides an at-a-glance description of the olist_ebiz analytics project, its architecture, operational patterns, and recommended production practices.

## Architecture

- Ingest: source systems (e.g., raw CSVs, API, warehouse staging tables)
- Transform: `dbt` models organized into `staging/`, `intermediate/`, and `marts/`
- Orchestration: Airflow DAGs execute dbt runs, tests, and docs generation
- Storage: Warehouse (configured via `profiles.yml`) for transformed datasets
- Observability: dbt tests, Airflow task logs, and monitoring alerts

## Key dbt conventions

- Models are layered: staging -> intermediate -> mart
- Use `schema.yml` for model descriptions, tests, and docs
- Prefer descriptive model names and incremental models for large tables

## Airflow integration

- DAGs live in `airflow/dags/` and call dbt with a robust retry policy and SLA monitoring
- Recommended: use separate DAGs for `dbt_run`, `dbt_test`, and `docs_publish`

## Operational best practices

- CI should run `dbt deps`, `dbt seed` (where needed), `dbt run --models tag:ci`, and `dbt test`
- Run `dbt docs generate` and publish artifacts for product & stakeholder access
- Add quiet hours, concurrency limits, and SLA-based alerts for long-running jobs

## Monitoring & data quality

- Rigorously use `dbt` tests (unique, not_null, relationships) and custom generic tests
- Add daily/weekly data quality checks and an incident playbook for anomalies

## Next steps & recommended deliverables

- Add GitHub Actions to run dbt CI and publish artifacts
- Add a containerized runtime (Dockerfile) and a Makefile to standardize dev workflows
- Add a `CHANGELOG.md`, `CONTRIBUTING.md`, and a `LICENSE` for professional project hygiene
