from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import date

# Citizen Schemas
class CitizenBase(BaseModel):
    Name: str
    Address: Optional[str] = None
    Phone: Optional[str] = None
    Email: Optional[EmailStr] = None
    Aadhaar_Number: Optional[str] = None

class CitizenCreate(CitizenBase):
    pass

class Citizen(CitizenBase):
    Citizen_ID: int

    class Config:
        from_attributes = True

# Department Schemas
class DepartmentBase(BaseModel):
    Department_Name: str
    Contact_Info: Optional[str] = None

class DepartmentCreate(DepartmentBase):
    pass

class Department(DepartmentBase):
    Department_ID: int

    class Config:
        from_attributes = True

# Service Schemas
class ServiceBase(BaseModel):
    Service_Name: str
    Service_Type: Optional[str] = None
    Department_ID: int

class ServiceCreate(ServiceBase):
    pass

class Service(ServiceBase):
    Service_ID: int

    class Config:
        from_attributes = True

# Payment Schemas
class PaymentBase(BaseModel):
    Amount: float
    Payment_Date: date
    Payment_Method: str
    Status: str

class PaymentCreate(PaymentBase):
    pass

class Payment(PaymentBase):
    Payment_ID: int

    class Config:
        from_attributes = True

# Service Request Schemas
class ServiceRequestBase(BaseModel):
    Citizen_ID: int
    Service_ID: int
    Request_Date: date
    Status: str
    Payment_ID: Optional[int] = None

class ServiceRequestCreate(ServiceRequestBase):
    pass

class ServiceRequest(ServiceRequestBase):
    Request_ID: int

    class Config:
        from_attributes = True

# Grievance Schemas
class GrievanceBase(BaseModel):
    Citizen_ID: int
    Department_ID: int
    Description: str
    Status: str
    Date: date

class GrievanceCreate(GrievanceBase):
    pass

class Grievance(GrievanceBase):
    Grievance_ID: int

    class Config:
        from_attributes = True

# Dashboard Statistics
class DashboardStats(BaseModel):
    total_citizens: int
    total_requests: int
    total_grievances: int
    total_revenue: float
    pending_requests: int
    open_grievances: int
