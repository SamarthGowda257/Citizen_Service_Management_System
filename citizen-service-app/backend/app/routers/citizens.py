from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func, desc
from typing import List
from app.database import get_db
from app.models.citizen import Citizen as CitizenModel
from app.schemas.schemas import Citizen, CitizenCreate
from sqlalchemy.exc import SQLAlchemyError, IntegrityError, OperationalError


router = APIRouter(prefix="/citizens", tags=["citizens"])

@router.get("/", response_model=List[Citizen])
def get_citizens(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all citizens"""
    citizens = db.query(CitizenModel).offset(skip).limit(limit).all()
    return citizens

@router.get("/{citizen_id}", response_model=Citizen)
def get_citizen(citizen_id: int, db: Session = Depends(get_db)):
    """Get a specific citizen by ID"""
    citizen = db.query(CitizenModel).filter(CitizenModel.Citizen_ID == citizen_id).first()
    if citizen is None:
        raise HTTPException(status_code=404, detail="Citizen not found")
    return citizen

@router.post("/", response_model=Citizen)

def create_citizen(citizen: CitizenCreate, db: Session = Depends(get_db)):
    """Create a new citizen"""
    try:
        max_id = db.query(func.max(CitizenModel.Citizen_ID)).scalar()
        next_id = (max_id or 0) + 1

        db_citizen = CitizenModel(Citizen_ID=next_id, **citizen.model_dump())
        db.add(db_citizen)
        db.commit()
        db.refresh(db_citizen)
        return db_citizen

    except (IntegrityError, OperationalError) as e:
        db.rollback()
        # Return the SQL trigger message to frontend
        raise HTTPException(status_code=400, detail=str(e.orig))


@router.put("/{citizen_id}", response_model=Citizen)
def update_citizen(citizen_id: int, citizen: CitizenCreate, db: Session = Depends(get_db)):
    """Update a citizen"""
    db_citizen = db.query(CitizenModel).filter(CitizenModel.Citizen_ID == citizen_id).first()
    if db_citizen is None:
        raise HTTPException(status_code=404, detail="Citizen not found")
    
    for key, value in citizen.model_dump().items():
        setattr(db_citizen, key, value)
    
    db.commit()
    db.refresh(db_citizen)
    return db_citizen

@router.delete("/{citizen_id}")
def delete_citizen(citizen_id: int, db: Session = Depends(get_db)):
    """Delete a citizen"""
    db_citizen = db.query(CitizenModel).filter(CitizenModel.Citizen_ID == citizen_id).first()
    if db_citizen is None:
        raise HTTPException(status_code=404, detail="Citizen not found")
    
    db.delete(db_citizen)
    db.commit()
    return {"message": "Citizen deleted successfully"}
