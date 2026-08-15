#!/usr/bin/env python3
"""Validate every Client ID Document in docs/ against schema/client-id-document.schema.json,
plus one spec requirement the schema can't express on its own: Solid-OIDC 5.1 requires
a document's `client_id` field to equal the URI the document is itself dereferenced from.
Since a JSON Schema has no notion of "the URL this file will be served at", that check is
done here instead, by deriving the expected GitHub Pages URL from each file's path.
"""

import json
import sys
from pathlib import Path

from jsonschema import Draft202012Validator

REPO_ROOT = Path(__file__).resolve().parent.parent
DOCS_DIR = REPO_ROOT / "docs"
SCHEMA_PATH = REPO_ROOT / "schema" / "client-id-document.schema.json"
PAGES_BASE_URL = "https://wallaby-dev.github.io/solid-local-client-id"


def validate_document(path: Path, validator: Draft202012Validator) -> list[str]:
    errors = []
    try:
        document = json.loads(path.read_text())
    except json.JSONDecodeError as exc:
        return [f"not valid JSON ({exc})"]

    for error in sorted(validator.iter_errors(document), key=str):
        field = "/".join(str(p) for p in error.absolute_path) or "<root>"
        errors.append(f"{field}: {error.message}")

    expected_client_id = f"{PAGES_BASE_URL}/{path.relative_to(DOCS_DIR).as_posix()}"
    actual_client_id = document.get("client_id")
    if actual_client_id != expected_client_id:
        errors.append(
            f"client_id: expected {expected_client_id!r} (this document's own "
            f"GitHub Pages URL) but found {actual_client_id!r}"
        )

    return errors


def main() -> int:
    schema = json.loads(SCHEMA_PATH.read_text())
    validator = Draft202012Validator(schema)

    documents = sorted(DOCS_DIR.glob("*.jsonld"))
    if not documents:
        print(f"No .jsonld documents found under {DOCS_DIR}")
        return 1

    failed = False
    for path in documents:
        errors = validate_document(path, validator)
        relative_path = path.relative_to(REPO_ROOT)
        if errors:
            failed = True
            print(f"FAIL {relative_path}")
            for error in errors:
                print(f"  - {error}")
        else:
            print(f"OK   {relative_path}")

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
