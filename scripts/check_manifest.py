import json
import sys
from pathlib import Path


def main():
    manifest_path = Path("target/manifest.json")
    if not manifest_path.exists():
        print("ERROR: target/manifest.json not found. Did you run 'dbt run'?")
        sys.exit(2)

    with manifest_path.open() as f:
        manifest = json.load(f)

    models = manifest.get("nodes", {})
    if not models:
        print("ERROR: No models found in manifest.json — check dbt build/run results")
        sys.exit(3)

    print(f"OK: {len(models)} models found in manifest.json")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
