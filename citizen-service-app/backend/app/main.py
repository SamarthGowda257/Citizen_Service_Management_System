from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import (
    citizens,
    departments,
    services,
    dashboard,
    service_requests,
    grievances,
    procedures,
    citizen_logs,  # ✅ added
)
from app.database import engine
from sqlalchemy import text
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(
    title="Citizen Service Management System",
    description="API for managing citizen services, requests, grievances, and stored procedures",
    version="1.0.0",
)

origins = os.getenv("CORS_ORIGINS", "http://localhost:3000,http://localhost:5173").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ Include all routers
app.include_router(citizens.router, prefix="/api")
app.include_router(departments.router, prefix="/api")
app.include_router(services.router, prefix="/api")
app.include_router(service_requests.router, prefix="/api")
app.include_router(grievances.router, prefix="/api")
app.include_router(dashboard.router, prefix="/api")
app.include_router(procedures.router, prefix="/api")  # ✅ Added
app.include_router(citizen_logs.router, prefix="/api")


@app.get("/")
def read_root():
    return {
        "message": "Welcome to Citizen Service Management System API",
        "docs": "/docs",
        "version": "1.0.0",
    }

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.on_event("startup")
async def check_db():
    with engine.connect() as conn:
        db_name = conn.execute(text("SELECT DATABASE();")).fetchone()[0]
        print(f"✅ Connected to Database: {db_name}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
