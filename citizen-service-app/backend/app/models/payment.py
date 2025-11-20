from sqlalchemy import Column, Integer, String, DECIMAL, Date
from sqlalchemy.orm import relationship
from app.database import Base

class Payment(Base):
    __tablename__ = "Payment"

    Payment_ID = Column(Integer, primary_key=True, index=True)
    Amount = Column(DECIMAL(10, 2))
    Payment_Date = Column(Date)
    Payment_Method = Column(String(50))
    Status = Column(String(50))

    # Relationships
    service_requests = relationship("ServiceRequest", back_populates="payment")
