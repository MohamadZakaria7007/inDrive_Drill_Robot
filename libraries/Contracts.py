"""JSON-schema contract checks for API responses.

    Response Should Match Schema    ${response}    created_booking

Schemas live in /schemas (strict: additionalProperties false, exact types, ISO dates) and can
$ref each other by file name.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from jsonschema import Draft202012Validator, FormatChecker
from referencing import Registry, Resource

SCHEMA_DIR = Path(__file__).resolve().parent.parent / "schemas"


class Contracts:
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self) -> None:
        self._schemas = {
            path.stem: json.loads(path.read_text(encoding="utf-8"))
            for path in SCHEMA_DIR.glob("*.json")
        }
        self._registry = Registry().with_resources(
            (f"{name}.json", Resource.from_contents(schema))
            for name, schema in self._schemas.items()
        )

    def response_should_match_schema(self, response: Any, schema_name: str) -> None:
        """Fail with every violation (path + message) and the response body."""
        try:
            body = response.json()
        except ValueError as error:
            raise AssertionError(f"Response is not JSON: {response.text[:500]}") from error
        self.json_should_match_schema(body, schema_name)

    def json_should_match_schema(self, data: Any, schema_name: str) -> None:
        if schema_name not in self._schemas:
            raise AssertionError(f"Unknown schema '{schema_name}'. Known: {sorted(self._schemas)}")
        validator = Draft202012Validator(
            self._schemas[schema_name], registry=self._registry, format_checker=FormatChecker()
        )
        errors = sorted(validator.iter_errors(data), key=lambda e: list(e.absolute_path))
        if errors:
            details = "\n".join(
                f"- {'/'.join(map(str, e.absolute_path)) or '<root>'}: {e.message}" for e in errors
            )
            raise AssertionError(
                f"Does not match schema '{schema_name}':\n{details}\nbody: {json.dumps(data)[:500]}"
            )
