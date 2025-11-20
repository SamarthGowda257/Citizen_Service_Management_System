from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from sqlalchemy.exc import IntegrityError, OperationalError
from typing import List
from app.database import get_db
from app.models.service import Service as ServiceModel
from app.schemas.schemas import Service, ServiceCreate

router = APIRouter(prefix="/services", tags=["services"])

@router.get("/", response_model=List[Service])
def get_services(db: Session = Depends(get_db)):
    """Get all services"""
    return db.query(ServiceModel).all()

@router.get("/{service_id}", response_model=Service)
def get_service(service_id: int, db: Session = Depends(get_db)):
    """Get a specific service"""
    service = db.query(ServiceModel).filter(ServiceModel.Service_ID == service_id).first()
    if service is None:
        raise HTTPException(status_code=404, detail="Service not found")
    return service

@router.post("/", response_model=Service)
def create_service(service: ServiceCreate, db: Session = Depends(get_db)):
    """Create a new service with DB trigger handling"""
    try:
        max_id = db.query(func.max(ServiceModel.Service_ID)).scalar()
        next_id = (max_id or 0) + 1

        db_service = ServiceModel(Service_ID=next_id, **service.model_dump())
        db.add(db_service)
        db.commit()
        db.refresh(db_service)
        return db_service

    except (IntegrityError, OperationalError) as e:
        db.rollback()
        # Forward SQL trigger error message to frontend
        raise HTTPException(status_code=400, detail=str(e.orig))
