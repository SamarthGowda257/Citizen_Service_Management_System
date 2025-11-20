from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from sqlalchemy.exc import IntegrityError, OperationalError
from typing import List
from app.database import get_db
from app.models.grievance import Grievance as GrievanceModel
from app.schemas.schemas import Grievance, GrievanceCreate

router = APIRouter(prefix="/grievances", tags=["grievances"])

@router.get("/", response_model=List[Grievance])
def get_grievances(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all grievances"""
    return db.query(GrievanceModel).offset(skip).limit(limit).all()

@router.post("/", response_model=Grievance)
def create_grievance(grievance: GrievanceCreate, db: Session = Depends(get_db)):
    """Create a new grievance with SQL trigger validation"""
    try:
        max_id = db.query(func.max(GrievanceModel.Grievance_ID)).scalar()
        next_id = (max_id or 0) + 1

        db_grievance = GrievanceModel(Grievance_ID=next_id, **grievance.model_dump())
        db.add(db_grievance)
        db.commit()
        db.refresh(db_grievance)
        return db_grievance

    except (IntegrityError, OperationalError) as e:
        db.rollback()
        # ✅ Forward MySQL trigger message to frontend
        raise HTTPException(status_code=400, detail=str(e.orig))
