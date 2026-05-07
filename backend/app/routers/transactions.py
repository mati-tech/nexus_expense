from collections import OrderedDict
from datetime import date, datetime, time, timedelta
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import func
from sqlalchemy.orm import Session

from .. import schemas
from ..auth import get_current_user
from ..database import get_db
from ..models import Transaction, TransactionType, User
from ..parser import categorize_for_type, parse_input

router = APIRouter(prefix="/transactions", tags=["transactions"])


def _label_for_date(d: date, today: date) -> str:
    if d == today:
        return "Today"
    if d == today - timedelta(days=1):
        return "Yesterday"
    return d.strftime("%B %d, %Y")


@router.post("", response_model=schemas.TransactionOut, status_code=status.HTTP_201_CREATED)
def create_transaction(
    payload: schemas.TransactionCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        name, amount = parse_input(payload.raw_input)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc))

    category = categorize_for_type(name, payload.type.value)

    transaction = Transaction(
        user_id=current_user.id,
        amount=amount,
        name=name,
        note=payload.note,
        type=payload.type,
        category=category,
    )

    if payload.type == TransactionType.IN:
        current_user.current_balance = Decimal(current_user.current_balance) + amount
    else:
        current_user.current_balance = Decimal(current_user.current_balance) - amount

    db.add(transaction)
    db.commit()
    db.refresh(transaction)
    return transaction


@router.get("", response_model=schemas.GroupedTransactions)
def list_transactions(
    current_user: User = Depends(get_current_user), db: Session = Depends(get_db)
):
    transactions = (
        db.query(Transaction)
        .filter(Transaction.user_id == current_user.id)
        .order_by(Transaction.timestamp.desc())
        .all()
    )

    today = datetime.utcnow().date()
    buckets: "OrderedDict[date, list[Transaction]]" = OrderedDict()
    for txn in transactions:
        bucket_date = txn.timestamp.date()
        buckets.setdefault(bucket_date, []).append(txn)

    groups = [
        schemas.TransactionGroup(
            label=_label_for_date(bucket_date, today),
            date_iso=bucket_date.isoformat(),
            transactions=[schemas.TransactionOut.model_validate(t) for t in items],
        )
        for bucket_date, items in buckets.items()
    ]
    return schemas.GroupedTransactions(groups=groups)


@router.delete("/{transaction_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_transaction(
    transaction_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    transaction = (
        db.query(Transaction)
        .filter(
            Transaction.id == transaction_id,
            Transaction.user_id == current_user.id,
        )
        .first()
    )
    if not transaction:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Transaction not found"
        )

    if transaction.type == TransactionType.IN:
        current_user.current_balance = (
            Decimal(current_user.current_balance) - transaction.amount
        )
    else:
        current_user.current_balance = (
            Decimal(current_user.current_balance) + transaction.amount
        )

    db.delete(transaction)
    db.commit()
    return None


@router.get("/summary/weekly", response_model=schemas.WeeklySummary)
def weekly_summary(
    current_user: User = Depends(get_current_user), db: Session = Depends(get_db)
):
    today = datetime.utcnow().date()
    week_start_date = today - timedelta(days=today.weekday())
    week_start = datetime.combine(week_start_date, time.min)
    week_end = week_start + timedelta(days=7)

    rows = (
        db.query(
            Transaction.type, func.coalesce(func.sum(Transaction.amount), 0)
        )
        .filter(
            Transaction.user_id == current_user.id,
            Transaction.timestamp >= week_start,
            Transaction.timestamp < week_end,
        )
        .group_by(Transaction.type)
        .all()
    )

    totals = {row[0]: Decimal(row[1]) for row in rows}
    earned = totals.get(TransactionType.IN, Decimal("0"))
    spent = totals.get(TransactionType.OUT, Decimal("0"))

    return schemas.WeeklySummary(
        spent=spent,
        earned=earned,
        net=earned - spent,
        week_start=week_start,
        week_end=week_end,
    )
