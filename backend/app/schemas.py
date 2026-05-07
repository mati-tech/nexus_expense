from datetime import datetime
from decimal import Decimal
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field

from .models import TransactionType


class UserSignup(BaseModel):
    username: str = Field(min_length=3, max_length=64)
    nickname: str = Field(min_length=1, max_length=64)
    password: str = Field(min_length=6, max_length=128)
    starting_balance: Decimal = Field(default=Decimal("0"))


class UserLogin(BaseModel):
    username: str
    password: str


class UserOut(BaseModel):
    id: int
    username: str
    nickname: str
    current_balance: Decimal

    model_config = ConfigDict(from_attributes=True)


class BalanceUpdate(BaseModel):
    current_balance: Decimal


class NicknameUpdate(BaseModel):
    nickname: str = Field(min_length=1, max_length=64)


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut


class TransactionCreate(BaseModel):
    raw_input: str = Field(min_length=1, max_length=200)
    type: TransactionType
    note: Optional[str] = Field(default=None, max_length=500)


class TransactionOut(BaseModel):
    id: int
    amount: Decimal
    name: str
    note: Optional[str]
    type: TransactionType
    category: str
    timestamp: datetime

    model_config = ConfigDict(from_attributes=True)


class TransactionGroup(BaseModel):
    label: str
    date_iso: str
    transactions: list[TransactionOut]


class GroupedTransactions(BaseModel):
    groups: list[TransactionGroup]


class WeeklySummary(BaseModel):
    spent: Decimal
    earned: Decimal
    net: Decimal
    week_start: datetime
    week_end: datetime
