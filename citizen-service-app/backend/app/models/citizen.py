from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from app.database import Base

class Citizen(Base):
    __tablename__ = "Citizen"

    Citizen_ID = Column(Integer, primary_key=True, index=True)
    Name = Column(String(100), nullable=False)
    Address = Column(String(200))
    Phone = Column(String(15))
    Email = Column(String(100), unique=True)
    Aadhaar_Number = Column(String(20), unique=True)

    # Relationships
    service_requests = relationship("ServiceRequest", back_populates="citizen")
    grievances = relationship("Grievance", back_populates="citizen")
