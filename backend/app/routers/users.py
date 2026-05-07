from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from .. import schemas
from ..auth import get_current_user
from ..database import get_db
from ..models import User

router = APIRouter(prefix="/user", tags=["user"])


@router.get("/profile", response_model=schemas.UserOut)
def get_profile(current_user: User = Depends(get_current_user)):
    return current_user


@router.put("/balance", response_model=schemas.UserOut)
def update_balance(
    payload: schemas.BalanceUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    current_user.current_balance = payload.current_balance
    db.commit()
    db.refresh(current_user)
    return current_user


@router.put("/nickname", response_model=schemas.UserOut)
def update_nickname(
    payload: schemas.NicknameUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    current_user.nickname = payload.nickname
    db.commit()
    db.refresh(current_user)
    return current_user
