PY := python
PIP := pip

.PHONY: help build deps run seed test docs lint

help:
	@echo "Makefile commands: build, deps, run, seed, test, docs"

build:
	docker build -t olist_ebiz:latest .

deps:
	$(PIP) install -r requirements.txt || $(PIP) install dbt-core dbt-postgres

run:
	dbt run --profiles-dir .

seed:
	dbt seed --profiles-dir .

test:
	dbt test --profiles-dir .

docs:
	dbt docs generate --profiles-dir .

lint:
	# Add linters here (sqlfluff, flake8, etc.)
	@echo "Run linters (not configured)"

check:
	./tests/run_local_tests.sh
