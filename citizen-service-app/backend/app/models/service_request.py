from sqlalchemy import Column, Integer, String, Date, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class ServiceRequest(Base):
    __tablename__ = "Service_Request"

    Request_ID = Column(Integer, primary_key=True, index=True)
    Citizen_ID = Column(Integer, ForeignKey("Citizen.Citizen_ID"))
    Service_ID = Column(Integer, ForeignKey("Service.Service_ID"))
    Request_Date = Column(Date)
    Status = Column(String(50))
    Payment_ID = Column(Integer, ForeignKey("Payment.Payment_ID"))

    # Relationships
    citizen = relationship("Citizen", back_populates="service_requests")
    service = relationship("Service", back_populates="service_requests")
    payment = relationship("Payment", back_populates="service_requests")
