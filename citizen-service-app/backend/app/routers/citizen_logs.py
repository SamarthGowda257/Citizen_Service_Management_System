from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.database import get_db

router = APIRouter(prefix="/citizen-logs", tags=["citizen-logs"])

@router.get("/")
def get_citizen_logs(db: Session = Depends(get_db)):
    """
    Fetch recent Citizen Logs — automatically populated by trigger.
    """
    result = db.execute(text("""
        SELECT cl.Log_ID, cl.Citizen_ID, c.Name AS Citizen_Name, 
               cl.Total_Services, cl.Log_Date
        FROM Citizen_Log cl
        JOIN Citizen c ON c.Citizen_ID = cl.Citizen_ID
        ORDER BY cl.Log_Date DESC
        LIMIT 50;
    """)).fetchall()
    
    return [dict(row._mapping) for row in result]
