-- =====================================================
-- CITIZEN SERVICE MANAGEMENT SYSTEM
-- SQL FUNCTIONS + TRIGGERS (Compatible with your Schema)
-- =====================================================

USE citizen_service;

DELIMITER $$

-- =====================================================
-- 🧍 FUNCTION: Get total services used by a citizen
-- =====================================================
CREATE FUNCTION fn_citizen_service_count(citizenId INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_services INT;

    SELECT COUNT(DISTINCT Service_ID)
    INTO total_services
    FROM Service_Request
    WHERE Citizen_ID = citizenId;

    RETURN IFNULL(total_services, 0);
END$$


-- =====================================================
-- 🏛️ FUNCTION: Get department performance (% completed)
-- =====================================================
CREATE FUNCTION fn_department_performance(deptId INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE total_requests INT;
    DECLARE completed_requests INT;
    DECLARE performance DECIMAL(5,2);

    SELECT COUNT(sr.Request_ID)
    INTO total_requests
    FROM Service_Request sr
    JOIN Service s ON sr.Service_ID = s.Service_ID
    WHERE s.Department_ID = deptId;

    SELECT COUNT(sr.Request_ID)
    INTO completed_requests
    FROM Service_Request sr
    JOIN Service s ON sr.Service_ID = s.Service_ID
    WHERE s.Department_ID = deptId AND sr.Status = 'Completed';

    IF total_requests = 0 THEN
        SET performance = 0;
    ELSE
        SET performance = (completed_requests / total_requests) * 100;
    END IF;

    RETURN performance;
END$$


-- =====================================================
-- 🧾 FUNCTION: Get total revenue for a service
-- =====================================================
CREATE FUNCTION fn_service_revenue(serviceId INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_revenue DECIMAL(10,2);

    SELECT IFNULL(SUM(p.Amount), 0)
    INTO total_revenue
    FROM Payment p
    JOIN Service_Request sr ON p.Payment_ID = sr.Payment_ID
    WHERE sr.Service_ID = serviceId;

    RETURN total_revenue;
END$$


-- =====================================================
-- 💬 FUNCTION: Get total pending grievances for department
-- =====================================================
CREATE FUNCTION fn_grievance_pending_count(deptId INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_pending INT;

    SELECT COUNT(*)
    INTO total_pending
    FROM Grievance
    WHERE Department_ID = deptId
      AND Status IN ('Open', 'In Progress');

    RETURN IFNULL(total_pending, 0);
END$$


-- =====================================================
-- LOG TABLES (to store function results)
-- =====================================================

CREATE TABLE IF NOT EXISTS Citizen_Log (
    Log_ID INT AUTO_INCREMENT PRIMARY KEY,
    Citizen_ID INT,
    Total_Services INT,
    Log_Date DATETIME,
    FOREIGN KEY (Citizen_ID) REFERENCES Citizen(Citizen_ID)
);

CREATE TABLE IF NOT EXISTS Department_Log (
    Log_ID INT AUTO_INCREMENT PRIMARY KEY,
    Department_ID INT,
    Performance DECIMAL(5,2),
    Log_Date DATETIME,
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
);

CREATE TABLE IF NOT EXISTS Service_Log (
    Log_ID INT AUTO_INCREMENT PRIMARY KEY,
    Service_ID INT,
    Total_Revenue DECIMAL(10,2),
    Log_Date DATETIME,
    FOREIGN KEY (Service_ID) REFERENCES Service(Service_ID)
);

CREATE TABLE IF NOT EXISTS Grievance_Log (
    Log_ID INT AUTO_INCREMENT PRIMARY KEY,
    Department_ID INT,
    Total_Pending INT,
    Log_Date DATETIME,
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
);


-- =====================================================
-- 🧍 TRIGGER: After Citizen Insert
-- Logs how many services this citizen has used
-- =====================================================
CREATE TRIGGER trg_after_citizen_insert
AFTER INSERT ON Citizen
FOR EACH ROW
BEGIN
    INSERT INTO Citizen_Log (Citizen_ID, Total_Services, Log_Date)
    VALUES (NEW.Citizen_ID, fn_citizen_service_count(NEW.Citizen_ID), NOW());
END$$


-- =====================================================
-- 🏛️ TRIGGER: After Department Insert
-- Logs initial performance (0%)
-- =====================================================
CREATE TRIGGER trg_after_department_insert
AFTER INSERT ON Department
FOR EACH ROW
BEGIN
    INSERT INTO Department_Log (Department_ID, Performance, Log_Date)
    VALUES (NEW.Department_ID, fn_department_performance(NEW.Department_ID), NOW());
END$$


-- =====================================================
-- 🧾 TRIGGER: After Service Insert
-- Logs current revenue (initially 0)
-- =====================================================
CREATE TRIGGER trg_after_service_insert
AFTER INSERT ON Service
FOR EACH ROW
BEGIN
    INSERT INTO Service_Log (Service_ID, Total_Revenue, Log_Date)
    VALUES (NEW.Service_ID, fn_service_revenue(NEW.Service_ID), NOW());
END$$


-- =====================================================
-- 💬 TRIGGER: After Grievance Insert
-- Logs total pending grievances for that department
-- =====================================================
CREATE TRIGGER trg_after_grievance_insert
AFTER INSERT ON Grievance
FOR EACH ROW
BEGIN
    INSERT INTO Grievance_Log (Department_ID, Total_Pending, Log_Date)
    VALUES (NEW.Department_ID, fn_grievance_pending_count(NEW.Department_ID), NOW());
END$$

DELIMITER ;

-- =====================================================
-- ✅ END OF FILE
-- =====================================================
