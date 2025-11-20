from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from sqlalchemy.exc import IntegrityError, OperationalError
from typing import List
from app.database import get_db
from app.models.department import Department as DepartmentModel
from app.schemas.schemas import Department, DepartmentCreate

router = APIRouter(prefix="/departments", tags=["departments"])


@router.get("/", response_model=List[Department])
def get_departments(db: Session = Depends(get_db)):
    """Get all departments"""
    return db.query(DepartmentModel).all()


@router.get("/{department_id}", response_model=Department)
def get_department(department_id: int, db: Session = Depends(get_db)):
    """Get a specific department"""
    dept = (
        db.query(DepartmentModel)
        .filter(DepartmentModel.Department_ID == department_id)
        .first()
    )
    if dept is None:
        raise HTTPException(status_code=404, detail="Department not found")
    return dept


@router.post("/", response_model=Department)
def create_department(department: DepartmentCreate, db: Session = Depends(get_db)):
    """Create a new department with MySQL trigger validation"""
    try:
        max_id = db.query(func.max(DepartmentModel.Department_ID)).scalar()
        next_id = (max_id or 0) + 1

        db_dept = DepartmentModel(Department_ID=next_id, **department.model_dump())
        db.add(db_dept)
        db.commit()
        db.refresh(db_dept)
        return db_dept

    except (IntegrityError, OperationalError) as e:
        db.rollback()

        # ✅ Cleanly extract MySQL trigger message
        msg = str(e.orig)
        if isinstance(e.orig, tuple):
            msg = e.orig[1] if len(e.orig) > 1 else str(e.orig)
        elif hasattr(e.orig, "args") and len(e.orig.args) > 1:
            msg = e.orig.args[1]

        raise HTTPException(status_code=400, detail=msg)
