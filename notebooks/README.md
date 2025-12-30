# Demo notebooks

This folder contains example analyses and instructions to run them locally.

1. Start the development container: `make build && docker run -it -v $(pwd):/app olist_ebiz:latest`
2. Install dev dependencies: `pip install -r requirements-dev.txt`
3. Launch Jupyter and open `demo_analysis.md` or create a new notebook that queries the `analytics` schema.

Notebook examples should be lightweight, reproducible, and use the canonical models produced by dbt.
