from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class Service(Base):
    __tablename__ = "Service"

    Service_ID = Column(Integer, primary_key=True, index=True)
    Service_Name = Column(String(100), nullable=False)  # triggers handle empty string
    Service_Type = Column(String(50))
    Department_ID = Column(Integer, ForeignKey("Department.Department_ID"))

    # Relationships
    department = relationship("Department", back_populates="services")
    service_requests = relationship("ServiceRequest", back_populates="service")
