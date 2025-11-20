from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.database import get_db

router = APIRouter(prefix="/procedures", tags=["procedures"])

# 🏛️ Department-Wise Service Count
@router.get("/department-service-count")
def department_service_count(db: Session = Depends(get_db)):
    """Call sp_department_service_count stored procedure"""
    try:
        result = db.execute(text("CALL sp_department_service_count();"))
        rows = result.fetchall()
        columns = result.keys()
        return [dict(zip(columns, row)) for row in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# 👨‍💼 Pending Service Requests
@router.get("/pending-requests")
def pending_requests(db: Session = Depends(get_db)):
    """Call sp_pending_requests stored procedure"""
    try:
        result = db.execute(text("CALL sp_pending_requests();"))
        rows = result.fetchall()
        columns = result.keys()
        return [dict(zip(columns, row)) for row in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# 💰 Payment Summary
@router.get("/payment-summary")
def payment_summary(db: Session = Depends(get_db)):
    """Call sp_payment_summary stored procedure"""
    try:
        result = db.execute(text("CALL sp_payment_summary();"))
        rows = result.fetchall()
        columns = result.keys()
        return [dict(zip(columns, row)) for row in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# 📣 Grievances by Department
@router.get("/grievances-by-department")
def grievances_by_department(db: Session = Depends(get_db)):
    """Call sp_grievances_by_department stored procedure"""
    try:
        result = db.execute(text("CALL sp_grievances_by_department();"))
        rows = result.fetchall()
        columns = result.keys()
        return [dict(zip(columns, row)) for row in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
