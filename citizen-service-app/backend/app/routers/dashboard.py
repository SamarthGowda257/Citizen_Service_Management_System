from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func, text
from typing import List, Dict, Any
from app.database import get_db
from app.models.citizen import Citizen
from app.models.service_request import ServiceRequest
from app.models.grievance import Grievance
from app.models.payment import Payment
from app.schemas.schemas import DashboardStats

router = APIRouter(prefix="/dashboard", tags=["dashboard"])

@router.get("/stats", response_model=DashboardStats)
def get_dashboard_stats(db: Session = Depends(get_db)):
    """Get dashboard statistics"""
    total_citizens = db.query(func.count(Citizen.Citizen_ID)).scalar()
    total_requests = db.query(func.count(ServiceRequest.Request_ID)).scalar()
    total_grievances = db.query(func.count(Grievance.Grievance_ID)).scalar()
    
    total_revenue = db.query(func.sum(Payment.Amount)).filter(
        Payment.Status == 'Completed'
    ).scalar() or 0.0
    
    pending_requests = db.query(func.count(ServiceRequest.Request_ID)).filter(
        ServiceRequest.Status.in_(['Pending', 'Processing'])
    ).scalar()
    
    open_grievances = db.query(func.count(Grievance.Grievance_ID)).filter(
        Grievance.Status.in_(['Open', 'In Progress'])
    ).scalar()
    
    return DashboardStats(
        total_citizens=total_citizens,
        total_requests=total_requests,
        total_grievances=total_grievances,
        total_revenue=float(total_revenue),
        pending_requests=pending_requests,
        open_grievances=open_grievances
    )


@router.get("/recent-requests")
def get_recent_requests(limit: int = 10, db: Session = Depends(get_db)):
    """Get recent service requests with details"""
    query = text("""
        SELECT 
            sr.Request_ID,
            c.Name AS Citizen_Name,
            s.Service_Name,
            d.Department_Name,
            sr.Request_Date,
            sr.Status,
            p.Amount,
            p.Payment_Method
        FROM Service_Request sr
        INNER JOIN Citizen c ON sr.Citizen_ID = c.Citizen_ID
        INNER JOIN Service s ON sr.Service_ID = s.Service_ID
        INNER JOIN Department d ON s.Department_ID = d.Department_ID
        LEFT JOIN Payment p ON sr.Payment_ID = p.Payment_ID
        ORDER BY sr.Request_Date DESC
        LIMIT :limit
    """)
    result = db.execute(query, {"limit": limit})
    return [dict(row._mapping) for row in result]


@router.get("/department-performance")
def get_department_performance(db: Session = Depends(get_db)):
    """Get department performance metrics"""
    query = text("""
        SELECT 
            d.Department_Name,
            COUNT(sr.Request_ID) AS Total_Requests,
            COUNT(CASE WHEN sr.Status = 'Completed' THEN 1 END) AS Completed_Requests,
            COUNT(CASE WHEN sr.Status = 'Pending' THEN 1 END) AS Pending_Requests,
            COALESCE(SUM(p.Amount), 0) AS Total_Revenue,
            ROUND(COUNT(CASE WHEN sr.Status = 'Completed' THEN 1 END) * 100.0 / 
                  NULLIF(COUNT(sr.Request_ID), 0), 2) AS Completion_Rate
        FROM Department d
        LEFT JOIN Service s ON d.Department_ID = s.Department_ID
        LEFT JOIN Service_Request sr ON s.Service_ID = sr.Service_ID
        LEFT JOIN Payment p ON sr.Payment_ID = p.Payment_ID AND p.Status = 'Completed'
        GROUP BY d.Department_ID, d.Department_Name
        ORDER BY Total_Requests DESC
    """)
    result = db.execute(query)
    return [dict(row._mapping) for row in result]


@router.get("/monthly-trends")
def get_monthly_trends(db: Session = Depends(get_db)):
    """Get monthly service request trends"""
    query = text("""
        SELECT 
            DATE_FORMAT(sr.Request_Date, '%Y-%m') AS Month,
            COUNT(sr.Request_ID) AS Total_Requests,
            COALESCE(SUM(p.Amount), 0) AS Total_Revenue,
            COUNT(DISTINCT sr.Citizen_ID) AS Unique_Citizens
        FROM Service_Request sr
        LEFT JOIN Payment p ON sr.Payment_ID = p.Payment_ID AND p.Status = 'Completed'
        GROUP BY DATE_FORMAT(sr.Request_Date, '%Y-%m')
        ORDER BY Month DESC
        LIMIT 12
    """)
    result = db.execute(query)
    return [dict(row._mapping) for row in result]


# ✅ NEW FUNCTION CALLS BELOW

@router.get("/department-performance-function")
def get_department_performance_function(db: Session = Depends(get_db)):
    """Call SQL function fn_department_performance for all departments"""
    query = text("""
        SELECT 
            d.Department_ID,
            d.Department_Name,
            fn_department_performance(d.Department_ID) AS Performance
        FROM Department d;
    """)
    result = db.execute(query)
    return [dict(row._mapping) for row in result]


@router.get("/service-revenue-function")
def get_service_revenue_function(db: Session = Depends(get_db)):
    """Call SQL function fn_service_revenue for all services"""
    query = text("""
        SELECT 
            s.Service_ID,
            s.Service_Name,
            fn_service_revenue(s.Service_ID) AS Total_Revenue
        FROM Service s;
    """)
    result = db.execute(query)
    return [dict(row._mapping) for row in result]
