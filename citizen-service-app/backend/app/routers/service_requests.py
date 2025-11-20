from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List
from app.database import get_db
from app.models.service_request import ServiceRequest as ServiceRequestModel
from app.schemas.schemas import ServiceRequest, ServiceRequestCreate

router = APIRouter(prefix="/service-requests", tags=["service-requests"])

@router.get("/", response_model=List[ServiceRequest])
def get_service_requests(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all service requests"""
    return db.query(ServiceRequestModel).offset(skip).limit(limit).all()

@router.post("/", response_model=ServiceRequest)
def create_service_request(request: ServiceRequestCreate, db: Session = Depends(get_db)):
    """Create a new service request"""
    max_id = db.query(func.max(ServiceRequestModel.Request_ID)).scalar()
    next_id = (max_id or 0) + 1
    
    db_request = ServiceRequestModel(Request_ID=next_id, **request.model_dump())
    db.add(db_request)
    db.commit()
    db.refresh(db_request)
    return db_request
