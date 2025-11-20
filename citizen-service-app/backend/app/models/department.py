from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from app.database import Base

class Department(Base):
    __tablename__ = "Department"

    Department_ID = Column(Integer, primary_key=True, index=True)
    Department_Name = Column(String(100), nullable=False)
    Contact_Info = Column(String(200))

    # Relationships
    services = relationship("Service", back_populates="department")
    grievances = relationship("Grievance", back_populates="department")
