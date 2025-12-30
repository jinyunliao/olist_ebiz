# Apache Superset — demo dashboard guide

This document explains how to create a simple demonstration dashboard in Apache Superset to visualize outputs from this dbt project (e.g., `fact_orders`, `dim_products`, `dim_customers`). It includes a minimal docker-compose example for local testing and step-by-step build instructions.

## Quick local setup (recommended)

1. Start the project's Postgres & dbt services (used as a sample data source):

   docker-compose up -d postgres

2. Bring up Superset (using the provided `docker-compose.superset.yml`):

   docker-compose -f docker-compose.superset.yml up -d

  3. Populate the demo dataset with dbt seeds so Superset can query sample models:

    cd /app && dbt seed --profiles-dir .

  4. Initialize Superset (initial admin user and DB migrations are handled in the compose file's entrypoint). If you run a manual container, run:

    docker exec -it <superset_container> superset fab create-admin --username admin --password admin --email admin@example.com --firstname Admin --lastname User
    docker exec -it <superset_container> superset db upgrade
    docker exec -it <superset_container> superset init

   docker exec -it <superset_container> superset fab create-admin --username admin --password admin --email admin@example.com --firstname Admin --lastname User
   docker exec -it <superset_container> superset db upgrade
   docker exec -it <superset_container> superset init

4. Open Superset UI at http://localhost:8088 and log in as `admin` / `admin`.

## Connect to the data source

- In Superset's UI, go to Data → Databases → + Database and add a SQLAlchemy connection to the project's Postgres instance. Example URI:

  postgresql://dbt:dbt@postgres:5432/analytics

## Create a dataset

1. Create a dataset based on a dbt model, e.g., `analytics.fact_orders` or use SQL to reference `{{ ref('fact_orders') }}` results.
2. Add commonly used fields and types (e.g., order_date timestamp, total_order_value numeric, marketplace string).

## Build simple charts & dashboard

- Chart 1: Time series — monthly revenue
  - SQL / Dataset: `fact_orders`
  - Metrics: SUM(total_order_value)
  - Time: order_date (monthly granularity)

- Chart 2: Top 5 products by revenue
  - Dataset: `fact_orders` joined with `dim_products`
  - Group by product name, metric SUM(total_order_value), order by metric DESC, limit 5

- Create a new Dashboard and add both charts. Add descriptive titles, filters (date picker), and a KPI box for total revenue.

## Export / Import dashboards

- After building the dashboard, you can export it via the Superset UI (Dashboard -> Export). Save the JSON under `notebooks/superset_example_dashboard.json` for sharing or CI-driven imports.

## Notes & tips

- For reproducible demos, keep a small sample dataset in `seeds/` or a test schema. Use `dbt seed` to populate data that Superset will query.
- The project's CI workflow now runs `dbt seed` and validates seed tests (tagged `superset_demo`) so seed integrity is checked on PRs.
- If you want automated creation/import of dashboards, Superset provides a CLI (`superset import-dashboards`) and APIs that can be scripted.
