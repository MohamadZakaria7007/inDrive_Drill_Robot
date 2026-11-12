"""Money keywords. Decimal, never float: `total == subtotal + tax` must be exact."""

from __future__ import annotations

from decimal import Decimal

__all__ = ["parse_money", "sum_money"]


def parse_money(text: str) -> Decimal:
    """`Item total: $39.98` -> Decimal('39.98')."""
    return Decimal(text.rsplit("$", 1)[-1].strip())


def sum_money(*amounts: Decimal) -> Decimal:
    return sum(amounts, Decimal("0"))
