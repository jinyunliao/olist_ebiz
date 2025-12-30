#!/usr/bin/env bash
set -euo pipefail

echo "Running dbt tests"
dbt deps
dbt run --profiles-dir .
dbt test --profiles-dir .

echo "Validating manifest"
python scripts/check_manifest.py

echo "All local tests passed"
