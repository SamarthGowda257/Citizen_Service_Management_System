-- =====================================================
-- CITIZEN SERVICE MANAGEMENT SYSTEM
-- TRIGGERS & STORED PROCEDURES
-- DATABASE: citizen_services
-- =====================================================

USE citizen_service;

DELIMITER $$

-- =====================================================
-- 1️⃣ VALIDATION TRIGGERS
-- =====================================================

-- 🧾 Validate Citizen Data
CREATE TRIGGER trg_validate_citizen
BEFORE INSERT ON Citizen
FOR EACH ROW
BEGIN
    IF NEW.Name IS NULL OR NEW.Name = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Citizen name cannot be empty';
    END IF;

    IF LENGTH(NEW.Phone) < 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid phone number';
    END IF;
END$$


-- 💳 Validate Payment Data
CREATE TRIGGER trg_validate_payment
BEFORE INSERT ON Payment
FOR EACH ROW
BEGIN
    IF NEW.Amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment amount must be greater than zero';
    END IF;

    IF NEW.Status NOT IN ('Pending', 'Success', 'Failed') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid payment status. Use Pending, Success, or Failed.';
    END IF;
END$$


-- ⚙️ Validate Service Data
CREATE TRIGGER trg_validate_service
BEFORE INSERT ON Service
FOR EACH ROW
BEGIN
    IF NEW.Service_Name IS NULL OR NEW.Service_Name = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Service name cannot be empty';
    END IF;

    IF NEW.Service_Type NOT IN ('Utility', 'Certificate', 'Grievance') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Service Type. Must be Utility, Certificate, or Grievance';
    END IF;
END$$


-- 📋 Validate Grievance Status
CREATE TRIGGER trg_validate_grievance
BEFORE INSERT ON Grievance
FOR EACH ROW
BEGIN
    IF NEW.Status NOT IN ('Pending', 'In Progress', 'Resolved', 'Rejected') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid grievance status';
    END IF;
END$$


-- =====================================================
-- 2️⃣ BUSINESS LOGIC TRIGGERS
-- =====================================================

-- 🧾 When a payment is successful, mark Service_Request as "Approved"
CREATE TRIGGER trg_update_request_after_payment
AFTER UPDATE ON Payment
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Success' THEN
        UPDATE Service_Request
        SET Status = 'Approved'
        WHERE Payment_ID = NEW.Payment_ID;
    END IF;
END$$


-- 🧠 Log Grievance Status Changes
CREATE TABLE IF NOT EXISTS Grievance_Log (
    Log_ID INT AUTO_INCREMENT PRIMARY KEY,
    Grievance_ID INT,
    Old_Status VARCHAR(50),
    New_Status VARCHAR(50),
    Changed_On TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_grievance_status_change
AFTER UPDATE ON Grievance
FOR EACH ROW
BEGIN
    IF OLD.Status <> NEW.Status THEN
        INSERT INTO Grievance_Log (Grievance_ID, Old_Status, New_Status)
        VALUES (OLD.Grievance_ID, OLD.Status, NEW.Status);
    END IF;
END$$


-- =====================================================
-- 3️⃣ STORED PROCEDURES
-- =====================================================

-- 🏛️ Procedure to Get Department-Wise Service Count
CREATE PROCEDURE sp_department_service_count()
BEGIN
    SELECT d.Department_Name, COUNT(s.Service_ID) AS Total_Services
    FROM Department d
    LEFT JOIN Service s ON d.Department_ID = s.Department_ID
    GROUP BY d.Department_ID;
END$$


-- 👨‍💼 Procedure to Get Pending Service Requests
CREATE PROCEDURE sp_pending_requests()
BEGIN
    SELECT sr.Request_ID, c.Name AS Citizen_Name, s.Service_Name, sr.Status
    FROM Service_Request sr
    JOIN Citizen c ON sr.Citizen_ID = c.Citizen_ID
    JOIN Service s ON sr.Service_ID = s.Service_ID
    WHERE sr.Status = 'Pending';
END$$


-- 💰 Procedure to Calculate Total Payments by Status
CREATE PROCEDURE sp_payment_summary()
BEGIN
    SELECT Status, SUM(Amount) AS Total_Amount, COUNT(*) AS Payment_Count
    FROM Payment
    GROUP BY Status;
END$$


-- 📣 Procedure to Get Grievances by Department
CREATE PROCEDURE sp_grievances_by_department()
BEGIN
    SELECT d.Department_Name, COUNT(g.Grievance_ID) AS Total_Grievances
    FROM Department d
    LEFT JOIN Grievance g ON d.Department_ID = g.Department_ID
    GROUP BY d.Department_ID;
END$$

DELIMITER ;

-- =====================================================
-- ✅ END OF FILE
-- =====================================================