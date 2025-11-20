-- =====================================================
-- CITIZEN SERVICE MANAGEMENT SYSTEM - DATABASE SCHEMA
-- =====================================================

-- 1. Citizen
CREATE TABLE Citizen (
    Citizen_ID INT,
    Name VARCHAR(100) NOT NULL,
    Address VARCHAR(200),
    Phone VARCHAR(15),
    Email VARCHAR(100) UNIQUE,
    Aadhaar_Number VARCHAR(20) UNIQUE,
    CONSTRAINT pk_citizen PRIMARY KEY (Citizen_ID)
);

-- 2. Department
CREATE TABLE Department (
    Department_ID INT,
    Department_Name VARCHAR(100) NOT NULL,
    Contact_Info VARCHAR(200),
    CONSTRAINT pk_department PRIMARY KEY (Department_ID)
);

-- 3. Service
CREATE TABLE Service (
    Service_ID INT,
    Service_Name VARCHAR(100) NOT NULL,
    Service_Type VARCHAR(50), -- Utility, Certificate, Grievance
    Department_ID INT,
    CONSTRAINT pk_service PRIMARY KEY (Service_ID),
    CONSTRAINT fk_service_department FOREIGN KEY (Department_ID)
        REFERENCES Department(Department_ID)
);

-- 4. Payment
CREATE TABLE Payment (
    Payment_ID INT,
    Amount DECIMAL(10,2),
    Payment_Date DATE,
    Payment_Method VARCHAR(50), -- UPI, Card, Cash
    Status VARCHAR(50),
    CONSTRAINT pk_payment PRIMARY KEY (Payment_ID)
);

-- 5. Service_Request
CREATE TABLE Service_Request (
    Request_ID INT,
    Citizen_ID INT,
    Service_ID INT,
    Request_Date DATE,
    Status VARCHAR(50),
    Payment_ID INT,
    CONSTRAINT pk_request PRIMARY KEY (Request_ID),
    CONSTRAINT fk_request_citizen FOREIGN KEY (Citizen_ID)
        REFERENCES Citizen(Citizen_ID),
    CONSTRAINT fk_request_service FOREIGN KEY (Service_ID)
        REFERENCES Service(Service_ID),
    CONSTRAINT fk_request_payment FOREIGN KEY (Payment_ID)
        REFERENCES Payment(Payment_ID)
);

-- 6. Grievance
CREATE TABLE Grievance (
    Grievance_ID INT,
    Citizen_ID INT,
    Department_ID INT,
    Description TEXT,
    Status VARCHAR(50),
    Date DATE,
    CONSTRAINT pk_grievance PRIMARY KEY (Grievance_ID),
    CONSTRAINT fk_grievance_citizen FOREIGN KEY (Citizen_ID)
        REFERENCES Citizen(Citizen_ID),
    CONSTRAINT fk_grievance_department FOREIGN KEY (Department_ID)
        REFERENCES Department(Department_ID)
);

CREATE TABLE IF NOT EXISTS Citizen_Log (
    Log_ID INT AUTO_INCREMENT PRIMARY KEY,
    Citizen_ID INT,
    Total_Services INT,
    Log_Date DATETIME,
    FOREIGN KEY (Citizen_ID) REFERENCES Citizen(Citizen_ID)
);
