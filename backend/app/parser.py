"""Smart input parser and auto-categorization for transactions.

Handles inputs like:
    "Pizza 15"          -> name="Pizza", amount=15
    "15 Pizza"          -> name="Pizza", amount=15
    "Salary 2000"       -> name="Salary", amount=2000
    "Coffee $5.50"      -> name="Coffee", amount=5.50
    "Bus ticket 2.75"   -> name="Bus ticket", amount=2.75
"""

import re
from decimal import Decimal, InvalidOperation
from typing import Optional, Tuple

# Maps lowercase keywords to a category. First match wins. Keep keywords specific.
CATEGORY_KEYWORDS: dict[str, tuple[str, ...]] = {
    "Groceries": (
        "bread", "milk", "eggs", "groceries", "grocery", "supermarket", "market",
        "vegetables", "fruit", "fruits", "meat", "rice", "pasta", "cheese", "yogurt",
    ),
    "Food & Drink": (
        "pizza", "burger", "coffee", "tea", "lunch", "dinner", "breakfast",
        "snack", "restaurant", "cafe", "starbucks", "mcdonalds", "kfc",
        "doordash", "ubereats", "delivery", "drink", "beer", "wine",
    ),
    "Transport": (
        "uber", "lyft", "taxi", "bus", "metro", "subway", "train", "fuel",
        "gas", "petrol", "diesel", "parking", "toll", "flight", "airline",
    ),
    "Entertainment": (
        "netflix", "spotify", "youtube", "hulu", "disney", "cinema", "movie",
        "concert", "game", "games", "steam", "xbox", "playstation", "ticket",
    ),
    "Bills & Utilities": (
        "rent", "electricity", "water", "internet", "wifi", "phone", "mobile",
        "utility", "bill", "insurance", "subscription",
    ),
    "Shopping": (
        "amazon", "clothes", "shirt", "shoes", "shopping", "jacket", "pants",
        "dress", "accessory", "electronics", "laptop", "headphones",
    ),
    "Health": (
        "pharmacy", "medicine", "doctor", "clinic", "hospital", "gym",
        "fitness", "dentist", "health",
    ),
    "Income": (
        "salary", "paycheck", "wage", "wages", "bonus", "freelance",
        "refund", "dividend", "interest", "gift",
    ),
}

_AMOUNT_PATTERN = re.compile(
    r"""
    (?:^|\s)            # start or whitespace
    \$?                 # optional currency symbol
    (\d+(?:[.,]\d{1,2})?)  # the number
    (?=\s|$)            # followed by whitespace or end
    """,
    re.VERBOSE,
)


def parse_input(raw: str) -> Tuple[str, Decimal]:
    """Extract (name, amount) from a free-form string.

    Raises ValueError if no number is found or the remaining name is empty.
    """
    raw = raw.strip()
    if not raw:
        raise ValueError("Input is empty")

    matches = list(_AMOUNT_PATTERN.finditer(raw))
    if not matches:
        raise ValueError("No amount found in input. Try a format like 'Pizza 15'.")

    # Prefer the last numeric token as the amount (handles "Bus ticket 2 5.50").
    match = matches[-1]
    amount_str = match.group(1).replace(",", ".")
    try:
        amount = Decimal(amount_str)
    except InvalidOperation as exc:
        raise ValueError(f"Could not parse amount '{amount_str}'") from exc

    if amount <= 0:
        raise ValueError("Amount must be greater than zero")

    name = (raw[: match.start()] + raw[match.end():]).strip()
    name = re.sub(r"\s{2,}", " ", name).strip(" -:,")
    if not name:
        raise ValueError("Item name is required. Try 'Pizza 15'.")

    name = " ".join(word.capitalize() for word in name.split())
    return name, amount


def categorize(name: str) -> str:
    """Return a best-guess category for the given item name."""
    lowered = name.lower()
    for category, keywords in CATEGORY_KEYWORDS.items():
        for keyword in keywords:
            if keyword in lowered:
                return category
    return "Other"


def categorize_for_type(name: str, txn_type: str) -> str:
    """Categorize, but force Income for IN transactions when no category matches."""
    category = categorize(name)
    if txn_type == "IN" and category == "Other":
        return "Income"
    if txn_type == "OUT" and category == "Income":
        return "Other"
    return category
