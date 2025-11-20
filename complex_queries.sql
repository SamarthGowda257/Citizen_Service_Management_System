-- =====================================================
-- COMPLEX MYSQL QUERIES FOR CITIZEN SERVICE MANAGEMENT SYSTEM
-- =====================================================

-- ==========================================
-- 1. ADVANCED JOIN QUERIES
-- ==========================================

-- 1.1 Get complete service request details with citizen, service, department, and payment info
SELECT 
    sr.Request_ID,
    c.Name AS Citizen_Name,
    c.Email AS Citizen_Email,
    s.Service_Name,
    s.Service_Type,
    d.Department_Name,
    sr.Request_Date,
    sr.Status AS Request_Status,
    p.Amount,
    p.Payment_Method,
    p.Payment_Date,
    p.Status AS Payment_Status
FROM Service_Request sr
INNER JOIN Citizen c ON sr.Citizen_ID = c.Citizen_ID
INNER JOIN Service s ON sr.Service_ID = s.Service_ID
INNER JOIN Department d ON s.Department_ID = d.Department_ID
LEFT JOIN Payment p ON sr.Payment_ID = p.Payment_ID
ORDER BY sr.Request_Date DESC;

-- 1.2 Get all grievances with citizen and department details
SELECT 
    g.Grievance_ID,
    c.Name AS Citizen_Name,
    c.Phone AS Citizen_Phone,
    c.Email AS Citizen_Email,
    d.Department_Name,
    d.Contact_Info AS Department_Contact,
    g.Description,
    g.Status,
    g.Date AS Grievance_Date,
    DATEDIFF(CURDATE(), g.Date) AS Days_Since_Reported
FROM Grievance g
INNER JOIN Citizen c ON g.Citizen_ID = c.Citizen_ID
INNER JOIN Department d ON g.Department_ID = d.Department_ID
ORDER BY g.Date DESC;

-- ==========================================
-- 2. SUBQUERIES
-- ==========================================

-- 2.1 Find citizens who have made more service requests than average
SELECT 
    c.Citizen_ID,
    c.Name,
    c.Email,
    COUNT(sr.Request_ID) AS Total_Requests
FROM Citizen c
INNER JOIN Service_Request sr ON c.Citizen_ID = sr.Citizen_ID
GROUP BY c.Citizen_ID, c.Name, c.Email
HAVING COUNT(sr.Request_ID) > (
    SELECT AVG(request_count)
    FROM (
        SELECT COUNT(*) AS request_count
        FROM Service_Request
        GROUP BY Citizen_ID
    ) AS avg_requests
);

-- 2.2 Find services that have never been requested
SELECT 
    s.Service_ID,
    s.Service_Name,
    s.Service_Type,
    d.Department_Name
FROM Service s
INNER JOIN Department d ON s.Department_ID = d.Department_ID
WHERE s.Service_ID NOT IN (
    SELECT DISTINCT Service_ID
    FROM Service_Request
);

-- 2.3 Find citizens who have paid more than the average payment amount
SELECT 
    c.Citizen_ID,
    c.Name,
    c.Email,
    SUM(p.Amount) AS Total_Paid
FROM Citizen c
INNER JOIN Service_Request sr ON c.Citizen_ID = sr.Citizen_ID
INNER JOIN Payment p ON sr.Payment_ID = p.Payment_ID
WHERE p.Status = 'Completed'
GROUP BY c.Citizen_ID, c.Name, c.Email
HAVING SUM(p.Amount) > (
    SELECT AVG(Amount)
    FROM Payment
    WHERE Status = 'Completed'
);

-- 2.4 Find departments with most grievances
SELECT 
    d.Department_ID,
    d.Department_Name,
    d.Contact_Info,
    (SELECT COUNT(*) 
     FROM Grievance g 
     WHERE g.Department_ID = d.Department_ID) AS Total_Grievances,
    (SELECT COUNT(*) 
     FROM Grievance g 
     WHERE g.Department_ID = d.Department_ID 
     AND g.Status = 'Open') AS Open_Grievances
FROM Department d
ORDER BY Total_Grievances DESC;

-- ==========================================
-- 3. AGGREGATE FUNCTIONS & GROUP BY
-- ==========================================

-- 3.1 Service request statistics by department
SELECT 
    d.Department_Name,
    COUNT(sr.Request_ID) AS Total_Requests,
    COUNT(CASE WHEN sr.Status = 'Completed' THEN 1 END) AS Completed_Requests,
    COUNT(CASE WHEN sr.Status = 'Pending' THEN 1 END) AS Pending_Requests,
    COUNT(CASE WHEN sr.Status = 'Processing' THEN 1 END) AS Processing_Requests,
    COUNT(CASE WHEN sr.Status = 'Rejected' THEN 1 END) AS Rejected_Requests,
    ROUND(COUNT(CASE WHEN sr.Status = 'Completed' THEN 1 END) * 100.0 / COUNT(sr.Request_ID), 2) AS Completion_Rate
FROM Department d
INNER JOIN Service s ON d.Department_ID = s.Department_ID
LEFT JOIN Service_Request sr ON s.Service_ID = sr.Service_ID
GROUP BY d.Department_ID, d.Department_Name
ORDER BY Total_Requests DESC;

-- 3.2 Payment statistics by payment method
SELECT 
    p.Payment_Method,
    COUNT(p.Payment_ID) AS Total_Transactions,
    SUM(p.Amount) AS Total_Amount,
    AVG(p.Amount) AS Average_Amount,
    MIN(p.Amount) AS Min_Amount,
    MAX(p.Amount) AS Max_Amount,
    COUNT(CASE WHEN p.Status = 'Completed' THEN 1 END) AS Successful_Payments,
    COUNT(CASE WHEN p.Status = 'Failed' THEN 1 END) AS Failed_Payments
FROM Payment p
GROUP BY p.Payment_Method
ORDER BY Total_Amount DESC;

-- 3.3 Monthly service request trends
SELECT 
    YEAR(sr.Request_Date) AS Year,
    MONTH(sr.Request_Date) AS Month,
    MONTHNAME(sr.Request_Date) AS Month_Name,
    COUNT(sr.Request_ID) AS Total_Requests,
    SUM(p.Amount) AS Total_Revenue,
    AVG(p.Amount) AS Average_Payment
FROM Service_Request sr
LEFT JOIN Payment p ON sr.Payment_ID = p.Payment_ID
GROUP BY YEAR(sr.Request_Date), MONTH(sr.Request_Date), MONTHNAME(sr.Request_Date)
ORDER BY Year DESC, Month DESC;

-- 3.4 Citizen activity summary
SELECT 
    c.Citizen_ID,
    c.Name,
    c.Email,
    COUNT(DISTINCT sr.Request_ID) AS Total_Service_Requests,
    COUNT(DISTINCT g.Grievance_ID) AS Total_Grievances,
    SUM(p.Amount) AS Total_Amount_Paid,
    MAX(sr.Request_Date) AS Last_Service_Request_Date,
    MAX(g.Date) AS Last_Grievance_Date
FROM Citizen c
LEFT JOIN Service_Request sr ON c.Citizen_ID = sr.Citizen_ID
LEFT JOIN Grievance g ON c.Citizen_ID = g.Citizen_ID
LEFT JOIN Payment p ON sr.Payment_ID = p.Payment_ID AND p.Status = 'Completed'
GROUP BY c.Citizen_ID, c.Name, c.Email
ORDER BY Total_Service_Requests DESC;

-- ==========================================
-- 4. WINDOW FUNCTIONS (RANKING & ANALYTICS)
-- ==========================================

-- 4.1 Rank citizens by total payments made
SELECT 
    c.Citizen_ID,
    c.Name,
    SUM(p.Amount) AS Total_Paid,
    RANK() OVER (ORDER BY SUM(p.Amount) DESC) AS Payment_Rank,
    DENSE_RANK() OVER (ORDER BY SUM(p.Amount) DESC) AS Dense_Rank,
    ROW_NUMBER() OVER (ORDER BY SUM(p.Amount) DESC) AS Row_Num
FROM Citizen c
INNER JOIN Service_Request sr ON c.Citizen_ID = sr.Citizen_ID
INNER JOIN Payment p ON sr.Payment_ID = p.Payment_ID
WHERE p.Status = 'Completed'
GROUP BY c.Citizen_ID, c.Name;

-- 4.2 Running total of revenue by date
SELECT 
    p.Payment_Date,
    p.Amount,
    p.Payment_Method,
    SUM(p.Amount) OVER (ORDER BY p.Payment_Date) AS Running_Total,
    AVG(p.Amount) OVER (ORDER BY p.Payment_Date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Moving_Average_3
FROM Payment p
WHERE p.Status = 'Completed'
ORDER BY p.Payment_Date;

-- 4.3 Partition service requests by department and rank by date
SELECT 
    d.Department_Name,
    s.Service_Name,
    sr.Request_ID,
    c.Name AS Citizen_Name,
    sr.Request_Date,
    sr.Status,
    ROW_NUMBER() OVER (PARTITION BY d.Department_ID ORDER BY sr.Request_Date DESC) AS Recent_Request_Rank
FROM Service_Request sr
INNER JOIN Service s ON sr.Service_ID = s.Service_ID
INNER JOIN Department d ON s.Department_ID = d.Department_ID
INNER JOIN Citizen c ON sr.Citizen_ID = c.Citizen_ID
ORDER BY d.Department_Name, Recent_Request_Rank;

-- ==========================================
-- 5. COMPLEX WHERE CLAUSES & FILTERING
-- ==========================================

-- 5.1 Find high-value pending service requests
SELECT 
    sr.Request_ID,
    c.Name AS Citizen_Name,
    s.Service_Name,
    d.Department_Name,
    sr.Request_Date,
    p.Amount,
    sr.Status,
    DATEDIFF(CURDATE(), sr.Request_Date) AS Days_Pending
FROM Service_Request sr
INNER JOIN Citizen c ON sr.Citizen_ID = c.Citizen_ID
INNER JOIN Service s ON sr.Service_ID = s.Service_ID
INNER JOIN Department d ON s.Department_ID = d.Department_ID
INNER JOIN Payment p ON sr.Payment_ID = p.Payment_ID
WHERE sr.Status IN ('Pending', 'Processing')
AND p.Amount > 500
AND DATEDIFF(CURDATE(), sr.Request_Date) > 7
ORDER BY Days_Pending DESC, p.Amount DESC;

-- 5.2 Find citizens with both service requests and grievances
SELECT DISTINCT
    c.Citizen_ID,
    c.Name,
    c.Email,
    c.Phone,
    (SELECT COUNT(*) FROM Service_Request WHERE Citizen_ID = c.Citizen_ID) AS Total_Requests,
    (SELECT COUNT(*) FROM Grievance WHERE Citizen_ID = c.Citizen_ID) AS Total_Grievances
FROM Citizen c
WHERE EXISTS (
    SELECT 1 FROM Service_Request sr WHERE sr.Citizen_ID = c.Citizen_ID
)
AND EXISTS (
    SELECT 1 FROM Grievance g WHERE g.Citizen_ID = c.Citizen_ID
);

-- ==========================================
-- 6. CASE STATEMENTS & CONDITIONAL LOGIC
-- ==========================================

-- 6.1 Categorize service requests by processing time
SELECT 
    sr.Request_ID,
    c.Name AS Citizen_Name,
    s.Service_Name,
    sr.Request_Date,
    sr.Status,
    DATEDIFF(CURDATE(), sr.Request_Date) AS Days_Since_Request,
    CASE 
        WHEN sr.Status = 'Completed' THEN 'Closed'
        WHEN DATEDIFF(CURDATE(), sr.Request_Date) <= 3 THEN 'Recent'
        WHEN DATEDIFF(CURDATE(), sr.Request_Date) BETWEEN 4 AND 7 THEN 'Normal'
        WHEN DATEDIFF(CURDATE(), sr.Request_Date) BETWEEN 8 AND 14 THEN 'Delayed'
        ELSE 'Critical'
    END AS Priority_Status,
    CASE 
        WHEN p.Amount < 500 THEN 'Low Value'
        WHEN p.Amount BETWEEN 500 AND 1000 THEN 'Medium Value'
        WHEN p.Amount BETWEEN 1001 AND 2000 THEN 'High Value'
        ELSE 'Premium Value'
    END AS Value_Category
FROM Service_Request sr
INNER JOIN Citizen c ON sr.Citizen_ID = c.Citizen_ID
INNER JOIN Service s ON sr.Service_ID = s.Service_ID
LEFT JOIN Payment p ON sr.Payment_ID = p.Payment_ID
ORDER BY Days_Since_Request DESC;

-- 6.2 Department performance scorecard
SELECT 
    d.Department_Name,
    COUNT(DISTINCT s.Service_ID) AS Total_Services,
    COUNT(sr.Request_ID) AS Total_Requests,
    COUNT(CASE WHEN sr.Status = 'Completed' THEN 1 END) AS Completed_Requests,
    COUNT(g.Grievance_ID) AS Total_Grievances,
    COUNT(CASE WHEN g.Status = 'Open' THEN 1 END) AS Open_Grievances,
    CASE 
        WHEN COUNT(sr.Request_ID) = 0 THEN 'No Activity'
        WHEN COUNT(CASE WHEN sr.Status = 'Completed' THEN 1 END) * 100.0 / COUNT(sr.Request_ID) >= 80 THEN 'Excellent'
        WHEN COUNT(CASE WHEN sr.Status = 'Completed' THEN 1 END) * 100.0 / COUNT(sr.Request_ID) >= 60 THEN 'Good'
        WHEN COUNT(CASE WHEN sr.Status = 'Completed' THEN 1 END) * 100.0 / COUNT(sr.Request_ID) >= 40 THEN 'Average'
        ELSE 'Needs Improvement'
    END AS Performance_Rating
FROM Department d
LEFT JOIN Service s ON d.Department_ID = s.Department_ID
LEFT JOIN Service_Request sr ON s.Service_ID = sr.Service_ID
LEFT JOIN Grievance g ON d.Department_ID = g.Department_ID
GROUP BY d.Department_ID, d.Department_Name
ORDER BY Performance_Rating DESC, Total_Requests DESC;

-- ==========================================
-- 7. CORRELATED SUBQUERIES
-- ==========================================

-- 7.1 Find citizens with above-average spending in their request count category
SELECT 
    c.Citizen_ID,
    c.Name,
    COUNT(sr.Request_ID) AS Request_Count,
    SUM(p.Amount) AS Total_Spent,
    (SELECT AVG(p2.Amount)
     FROM Service_Request sr2
     INNER JOIN Payment p2 ON sr2.Payment_ID = p2.Payment_ID
     WHERE sr2.Citizen_ID = c.Citizen_ID
     AND p2.Status = 'Completed') AS Avg_Per_Request
FROM Citizen c
INNER JOIN Service_Request sr ON c.Citizen_ID = sr.Citizen_ID
INNER JOIN Payment p ON sr.Payment_ID = p.Payment_ID
WHERE p.Status = 'Completed'
GROUP BY c.Citizen_ID, c.Name
HAVING SUM(p.Amount) > (
    SELECT AVG(total_amount)
    FROM (
        SELECT SUM(p3.Amount) AS total_amount
        FROM Service_Request sr3
        INNER JOIN Payment p3 ON sr3.Payment_ID = p3.Payment_ID
        WHERE p3.Status = 'Completed'
        GROUP BY sr3.Citizen_ID
    ) AS citizen_totals
);

-- 7.2 Services with request count higher than department average
SELECT 
    s.Service_ID,
    s.Service_Name,
    d.Department_Name,
    (SELECT COUNT(*) 
     FROM Service_Request sr 
     WHERE sr.Service_ID = s.Service_ID) AS Request_Count,
    (SELECT AVG(service_requests)
     FROM (
         SELECT COUNT(*) AS service_requests
         FROM Service_Request sr2
         INNER JOIN Service s2 ON sr2.Service_ID = s2.Service_ID
         WHERE s2.Department_ID = d.Department_ID
         GROUP BY s2.Service_ID
     ) AS dept_avg) AS Dept_Average
FROM Service s
INNER JOIN Department d ON s.Department_ID = d.Department_ID
HAVING Request_Count > Dept_Average
ORDER BY Request_Count DESC;

-- ==========================================
-- 8. SET OPERATIONS (UNION, INTERSECT, EXCEPT)
-- ==========================================

-- 8.1 All citizen interactions (Service Requests + Grievances)
SELECT 
    'Service Request' AS Interaction_Type,
    sr.Request_ID AS ID,
    c.Citizen_ID,
    c.Name AS Citizen_Name,
    sr.Request_Date AS Date,
    s.Service_Name AS Description,
    sr.Status
FROM Service_Request sr
INNER JOIN Citizen c ON sr.Citizen_ID = c.Citizen_ID
INNER JOIN Service s ON sr.Service_ID = s.Service_ID
UNION ALL
SELECT 
    'Grievance' AS Interaction_Type,
    g.Grievance_ID AS ID,
    c.Citizen_ID,
    c.Name AS Citizen_Name,
    g.Date,
    SUBSTRING(g.Description, 1, 50) AS Description,
    g.Status
FROM Grievance g
INNER JOIN Citizen c ON g.Citizen_ID = c.Citizen_ID
ORDER BY Date DESC;

-- 8.2 Citizens who have made requests but no grievances
SELECT 
    c.Citizen_ID,
    c.Name,
    c.Email,
    'Active User - No Complaints' AS Category
FROM Citizen c
WHERE c.Citizen_ID IN (SELECT DISTINCT Citizen_ID FROM Service_Request)
AND c.Citizen_ID NOT IN (SELECT DISTINCT Citizen_ID FROM Grievance);

-- ==========================================
-- 9. DATE & TIME FUNCTIONS
-- ==========================================

-- 9.1 Service requests by quarter
SELECT 
    YEAR(sr.Request_Date) AS Year,
    QUARTER(sr.Request_Date) AS Quarter,
    CONCAT('Q', QUARTER(sr.Request_Date), '-', YEAR(sr.Request_Date)) AS Quarter_Label,
    COUNT(sr.Request_ID) AS Total_Requests,
    SUM(p.Amount) AS Total_Revenue,
    COUNT(DISTINCT sr.Citizen_ID) AS Unique_Citizens
FROM Service_Request sr
LEFT JOIN Payment p ON sr.Payment_ID = p.Payment_ID
GROUP BY YEAR(sr.Request_Date), QUARTER(sr.Request_Date)
ORDER BY Year DESC, Quarter DESC;

-- 9.2 Weekday vs Weekend analysis
SELECT 
    CASE 
        WHEN DAYOFWEEK(sr.Request_Date) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    DAYNAME(sr.Request_Date) AS Day_Name,
    COUNT(sr.Request_ID) AS Request_Count,
    AVG(p.Amount) AS Average_Amount
FROM Service_Request sr
LEFT JOIN Payment p ON sr.Payment_ID = p.Payment_ID
GROUP BY Day_Type, Day_Name
ORDER BY Request_Count DESC;

-- 9.3 Grievance resolution time analysis
SELECT 
    g.Grievance_ID,
    c.Name AS Citizen_Name,
    d.Department_Name,
    g.Date AS Reported_Date,
    g.Status,
    DATEDIFF(CURDATE(), g.Date) AS Days_Open,
    CASE 
        WHEN g.Status = 'Resolved' THEN 'Closed'
        WHEN DATEDIFF(CURDATE(), g.Date) <= 7 THEN 'Within SLA'
        WHEN DATEDIFF(CURDATE(), g.Date) BETWEEN 8 AND 15 THEN 'Near Breach'
        ELSE 'SLA Breached'
    END AS SLA_Status
FROM Grievance g
INNER JOIN Citizen c ON g.Citizen_ID = c.Citizen_ID
INNER JOIN Department d ON g.Department_ID = d.Department_ID
ORDER BY Days_Open DESC;

-- ==========================================
-- 10. STRING FUNCTIONS & PATTERN MATCHING
-- ==========================================

-- 10.1 Find citizens with specific email domains
SELECT 
    Citizen_ID,
    Name,
    Email,
    SUBSTRING_INDEX(Email, '@', -1) AS Email_Domain,
    Phone,
    CONCAT(SUBSTRING(Phone, 1, 3), '-', SUBSTRING(Phone, 4, 3), '-', SUBSTRING(Phone, 7, 4)) AS Formatted_Phone
FROM Citizen
WHERE Email LIKE '%@email.com'
ORDER BY Email_Domain, Name;

-- 10.2 Search grievances by keyword
SELECT 
    g.Grievance_ID,
    c.Name AS Citizen_Name,
    d.Department_Name,
    g.Description,
    g.Status,
    g.Date,
    CASE 
        WHEN LOWER(g.Description) LIKE '%water%' THEN 'Water Related'
        WHEN LOWER(g.Description) LIKE '%road%' OR LOWER(g.Description) LIKE '%street%' THEN 'Infrastructure'
        WHEN LOWER(g.Description) LIKE '%garbage%' OR LOWER(g.Description) LIKE '%clean%' THEN 'Sanitation'
        WHEN LOWER(g.Description) LIKE '%light%' THEN 'Electricity'
        ELSE 'General'
    END AS Category
FROM Grievance g
INNER JOIN Citizen c ON g.Citizen_ID = c.Citizen_ID
INNER JOIN Department d ON g.Department_ID = d.Department_ID
ORDER BY g.Date DESC;

-- ==========================================
-- 11. HAVING CLAUSE WITH AGGREGATES
-- ==========================================

-- 11.1 Departments with high average payment amounts
SELECT 
    d.Department_Name,
    COUNT(sr.Request_ID) AS Total_Requests,
    AVG(p.Amount) AS Average_Payment,
    SUM(p.Amount) AS Total_Revenue
FROM Department d
INNER JOIN Service s ON d.Department_ID = s.Department_ID
INNER JOIN Service_Request sr ON s.Service_ID = sr.Service_ID
INNER JOIN Payment p ON sr.Payment_ID = p.Payment_ID
WHERE p.Status = 'Completed'
GROUP BY d.Department_ID, d.Department_Name
HAVING AVG(p.Amount) > 600
ORDER BY Average_Payment DESC;

-- 11.2 Citizens with multiple failed payments
SELECT 
    c.Citizen_ID,
    c.Name,
    c.Email,
    c.Phone,
    COUNT(p.Payment_ID) AS Failed_Payments,
    SUM(p.Amount) AS Failed_Amount
FROM Citizen c
INNER JOIN Service_Request sr ON c.Citizen_ID = sr.Citizen_ID
INNER JOIN Payment p ON sr.Payment_ID = p.Payment_ID
WHERE p.Status = 'Failed'
GROUP BY c.Citizen_ID, c.Name, c.Email, c.Phone
HAVING COUNT(p.Payment_ID) >= 1
ORDER BY Failed_Payments DESC, Failed_Amount DESC;

-- ==========================================
-- 12. SELF JOINS
-- ==========================================

-- 12.1 Find citizens from the same address
SELECT DISTINCT
    c1.Citizen_ID AS Citizen1_ID,
    c1.Name AS Citizen1_Name,
    c2.Citizen_ID AS Citizen2_ID,
    c2.Name AS Citizen2_Name,
    c1.Address AS Shared_Address,
    c1.Phone AS Citizen1_Phone,
    c2.Phone AS Citizen2_Phone
FROM Citizen c1
INNER JOIN Citizen c2 ON c1.Address = c2.Address
WHERE c1.Citizen_ID < c2.Citizen_ID;

-- 12.2 Compare service requests on the same day
SELECT 
    sr1.Request_ID AS Request1_ID,
    sr2.Request_ID AS Request2_ID,
    sr1.Request_Date,
    c1.Name AS Citizen1,
    c2.Name AS Citizen2,
    s1.Service_Name AS Service1,
    s2.Service_Name AS Service2
FROM Service_Request sr1
INNER JOIN Service_Request sr2 ON sr1.Request_Date = sr2.Request_Date
INNER JOIN Citizen c1 ON sr1.Citizen_ID = c1.Citizen_ID
INNER JOIN Citizen c2 ON sr2.Citizen_ID = c2.Citizen_ID
INNER JOIN Service s1 ON sr1.Service_ID = s1.Service_ID
INNER JOIN Service s2 ON sr2.Service_ID = s2.Service_ID
WHERE sr1.Request_ID < sr2.Request_ID
ORDER BY sr1.Request_Date DESC;

-- ==========================================
-- 13. VIEWS (COMPLEX VIRTUAL TABLES)
-- ==========================================

-- 13.1 Create view for citizen dashboard
CREATE OR REPLACE VIEW vw_Citizen_Dashboard AS
SELECT 
    c.Citizen_ID,
    c.Name,
    c.Email,
    c.Phone,
    COUNT(DISTINCT sr.Request_ID) AS Total_Requests,
    COUNT(DISTINCT CASE WHEN sr.Status = 'Completed' THEN sr.Request_ID END) AS Completed_Requests,
    COUNT(DISTINCT CASE WHEN sr.Status = 'Pending' THEN sr.Request_ID END) AS Pending_Requests,
    COUNT(DISTINCT g.Grievance_ID) AS Total_Grievances,
    COUNT(DISTINCT CASE WHEN g.Status = 'Open' THEN g.Grievance_ID END) AS Open_Grievances,
    COALESCE(SUM(p.Amount), 0) AS Total_Amount_Paid,
    MAX(sr.Request_Date) AS Last_Request_Date
FROM Citizen c
LEFT JOIN Service_Request sr ON c.Citizen_ID = sr.Citizen_ID
LEFT JOIN Grievance g ON c.Citizen_ID = g.Citizen_ID
LEFT JOIN Payment p ON sr.Payment_ID = p.Payment_ID AND p.Status = 'Completed'
GROUP BY c.Citizen_ID, c.Name, c.Email, c.Phone;

-- Query the view
SELECT * FROM vw_Citizen_Dashboard ORDER BY Total_Requests DESC;

-- 13.2 Create view for department analytics
CREATE OR REPLACE VIEW vw_Department_Analytics AS
SELECT 
    d.Department_ID,
    d.Department_Name,
    d.Contact_Info,
    COUNT(DISTINCT s.Service_ID) AS Total_Services,
    COUNT(DISTINCT sr.Request_ID) AS Total_Service_Requests,
    COUNT(DISTINCT g.Grievance_ID) AS Total_Grievances,
    COUNT(DISTINCT sr.Citizen_ID) AS Unique_Citizens_Served,
    COALESCE(SUM(p.Amount), 0) AS Total_Revenue,
    COALESCE(AVG(p.Amount), 0) AS Average_Transaction_Value,
    COUNT(CASE WHEN sr.Status = 'Completed' THEN 1 END) AS Completed_Requests,
    ROUND(COUNT(CASE WHEN sr.Status = 'Completed' THEN 1 END) * 100.0 / NULLIF(COUNT(sr.Request_ID), 0), 2) AS Completion_Rate
FROM Department d
LEFT JOIN Service s ON d.Department_ID = s.Department_ID
LEFT JOIN Service_Request sr ON s.Service_ID = sr.Service_ID
LEFT JOIN Grievance g ON d.Department_ID = g.Department_ID
LEFT JOIN Payment p ON sr.Payment_ID = p.Payment_ID AND p.Status = 'Completed'
GROUP BY d.Department_ID, d.Department_Name, d.Contact_Info;

-- Query the view
SELECT * FROM vw_Department_Analytics ORDER BY Total_Revenue DESC;

-- ==========================================
-- 14. COMMON TABLE EXPRESSIONS (CTEs)
-- ==========================================

-- 14.1 Multi-level CTE for citizen segmentation
WITH CitizenActivity AS (
    SELECT 
        c.Citizen_ID,
        c.Name,
        COUNT(sr.Request_ID) AS Request_Count,
        SUM(p.Amount) AS Total_Spent
    FROM Citizen c
    LEFT JOIN Service_Request sr ON c.Citizen_ID = sr.Citizen_ID
    LEFT JOIN Payment p ON sr.Payment_ID = p.Payment_ID AND p.Status = 'Completed'
    GROUP BY c.Citizen_ID, c.Name
),
ActivitySegments AS (
    SELECT 
        *,
        CASE 
            WHEN Total_Spent >= 2000 AND Request_Count >= 3 THEN 'Premium'
            WHEN Total_Spent >= 1000 OR Request_Count >= 2 THEN 'Active'
            WHEN Request_Count = 1 THEN 'New'
            ELSE 'Inactive'
        END AS Segment
    FROM CitizenActivity
)
SELECT 
    Segment,
    COUNT(*) AS Citizen_Count,
    AVG(Request_Count) AS Avg_Requests,
    AVG(Total_Spent) AS Avg_Spending,
    SUM(Total_Spent) AS Total_Segment_Revenue
FROM ActivitySegments
GROUP BY Segment
ORDER BY Total_Segment_Revenue DESC;

-- 14.2 Recursive CTE for date series (service request timeline)
WITH RECURSIVE DateSeries AS (
    SELECT DATE('2025-01-01') AS Date
    UNION ALL
    SELECT DATE_ADD(Date, INTERVAL 1 MONTH)
    FROM DateSeries
    WHERE Date < DATE('2025-12-01')
)
SELECT 
    ds.Date AS Month,
    COALESCE(COUNT(sr.Request_ID), 0) AS Total_Requests,
    COALESCE(SUM(p.Amount), 0) AS Total_Revenue
FROM DateSeries ds
LEFT JOIN Service_Request sr ON DATE_FORMAT(sr.Request_Date, '%Y-%m-01') = ds.Date
LEFT JOIN Payment p ON sr.Payment_ID = p.Payment_ID AND p.Status = 'Completed'
GROUP BY ds.Date
ORDER BY ds.Date;

-- 14.3 CTE for department comparison
WITH DepartmentMetrics AS (
    SELECT 
        d.Department_ID,
        d.Department_Name,
        COUNT(sr.Request_ID) AS Total_Requests,
        COUNT(CASE WHEN sr.Status = 'Completed' THEN 1 END) AS Completed,
        SUM(p.Amount) AS Revenue
    FROM Department d
    LEFT JOIN Service s ON d.Department_ID = s.Department_ID
    LEFT JOIN Service_Request sr ON s.Service_ID = sr.Service_ID
    LEFT JOIN Payment p ON sr.Payment_ID = p.Payment_ID
    GROUP BY d.Department_ID, d.Department_Name
),
AvgMetrics AS (
    SELECT 
        AVG(Total_Requests) AS Avg_Requests,
        AVG(Revenue) AS Avg_Revenue
    FROM DepartmentMetrics
)
SELECT 
    dm.Department_Name,
    dm.Total_Requests,
    dm.Completed,
    dm.Revenue,
    CASE 
        WHEN dm.Total_Requests > am.Avg_Requests THEN 'Above Average'
        WHEN dm.Total_Requests = am.Avg_Requests THEN 'Average'
        ELSE 'Below Average'
    END AS Performance_Category
FROM DepartmentMetrics dm
CROSS JOIN AvgMetrics am
ORDER BY dm.Total_Requests DESC;

-- ==========================================
-- 15. COMPLEX ANALYTICAL QUERIES
-- ==========================================

-- 15.1 Cohort analysis - Citizens by registration month
WITH CitizenCohort AS (
    SELECT 
        c.Citizen_ID,
        c.Name,
        MIN(sr.Request_Date) AS First_Request_Date,
        DATE_FORMAT(MIN(sr.Request_Date), '%Y-%m') AS Cohort_Month
    FROM Citizen c
    INNER JOIN Service_Request sr ON c.Citizen_ID = sr.Citizen_ID
    GROUP BY c.Citizen_ID, c.Name
)
SELECT 
    cc.Cohort_Month,
    COUNT(DISTINCT cc.Citizen_ID) AS Cohort_Size,
    COUNT(DISTINCT sr.Request_ID) AS Total_Requests,
    SUM(p.Amount) AS Total_Revenue,
    ROUND(SUM(p.Amount) / COUNT(DISTINCT cc.Citizen_ID), 2) AS Revenue_Per_Citizen
FROM CitizenCohort cc
LEFT JOIN Service_Request sr ON cc.Citizen_ID = sr.Citizen_ID
LEFT JOIN Payment p ON sr.Payment_ID = p.Payment_ID AND p.Status = 'Completed'
GROUP BY cc.Cohort_Month
ORDER BY cc.Cohort_Month;

-- 15.2 Service popularity and revenue analysis
SELECT 
    s.Service_Name,
    s.Service_Type,
    d.Department_Name,
    COUNT(sr.Request_ID) AS Request_Count,
    COUNT(CASE WHEN sr.Status = 'Completed' THEN 1 END) AS Completed_Count,
    COUNT(CASE WHEN sr.Status = 'Pending' THEN 1 END) AS Pending_Count,
    COUNT(CASE WHEN sr.Status = 'Rejected' THEN 1 END) AS Rejected_Count,
    COALESCE(SUM(p.Amount), 0) AS Total_Revenue,
    COALESCE(AVG(p.Amount), 0) AS Avg_Service_Fee,
    RANK() OVER (ORDER BY COUNT(sr.Request_ID) DESC) AS Popularity_Rank,
    RANK() OVER (ORDER BY SUM(p.Amount) DESC) AS Revenue_Rank
FROM Service s
INNER JOIN Department d ON s.Department_ID = d.Department_ID
LEFT JOIN Service_Request sr ON s.Service_ID = sr.Service_ID
LEFT JOIN Payment p ON sr.Payment_ID = p.Payment_ID AND p.Status = 'Completed'
GROUP BY s.Service_ID, s.Service_Name, s.Service_Type, d.Department_Name
ORDER BY Request_Count DESC;

-- 15.3 Citizen retention and churn analysis
WITH CitizenActivity AS (
    SELECT 
        c.Citizen_ID,
        c.Name,
        MIN(sr.Request_Date) AS First_Request,
        MAX(sr.Request_Date) AS Last_Request,
        COUNT(sr.Request_ID) AS Total_Requests,
        DATEDIFF(MAX(sr.Request_Date), MIN(sr.Request_Date)) AS Days_Active,
        DATEDIFF(CURDATE(), MAX(sr.Request_Date)) AS Days_Since_Last_Request
    FROM Citizen c
    INNER JOIN Service_Request sr ON c.Citizen_ID = sr.Citizen_ID
    GROUP BY c.Citizen_ID, c.Name
)
SELECT 
    Citizen_ID,
    Name,
    First_Request,
    Last_Request,
    Total_Requests,
    Days_Active,
    Days_Since_Last_Request,
    CASE 
        WHEN Days_Since_Last_Request <= 30 THEN 'Active'
        WHEN Days_Since_Last_Request BETWEEN 31 AND 90 THEN 'At Risk'
        WHEN Days_Since_Last_Request BETWEEN 91 AND 180 THEN 'Dormant'
        ELSE 'Churned'
    END AS Retention_Status,
    CASE 
        WHEN Total_Requests >= 3 THEN 'Loyal'
        WHEN Total_Requests = 2 THEN 'Repeat'
        ELSE 'One-Time'
    END AS Customer_Type
FROM CitizenActivity
ORDER BY Days_Since_Last_Request;

-- 15.4 Payment method effectiveness analysis
WITH PaymentAnalysis AS (
    SELECT 
        p.Payment_Method,
        COUNT(p.Payment_ID) AS Total_Transactions,
        COUNT(CASE WHEN p.Status = 'Completed' THEN 1 END) AS Successful,
        COUNT(CASE WHEN p.Status = 'Failed' THEN 1 END) AS Failed,
        COUNT(CASE WHEN p.Status = 'Pending' THEN 1 END) AS Pending,
        SUM(p.Amount) AS Total_Amount,
        AVG(p.Amount) AS Avg_Amount
    FROM Payment p
    GROUP BY p.Payment_Method
)
SELECT 
    Payment_Method,
    Total_Transactions,
    Successful,
    Failed,
    Pending,
    ROUND(Successful * 100.0 / Total_Transactions, 2) AS Success_Rate,
    ROUND(Failed * 100.0 / Total_Transactions, 2) AS Failure_Rate,
    Total_Amount,
    Avg_Amount,
    RANK() OVER (ORDER BY Successful * 100.0 / Total_Transactions DESC) AS Success_Rank
FROM PaymentAnalysis
ORDER BY Success_Rate DESC;

-- ==========================================
-- 16. PIVOT-LIKE QUERIES
-- ==========================================

-- 16.1 Service request status by department (pivot)
SELECT 
    d.Department_Name,
    COUNT(CASE WHEN sr.Status = 'Completed' THEN 1 END) AS Completed,
    COUNT(CASE WHEN sr.Status = 'Pending' THEN 1 END) AS Pending,
    COUNT(CASE WHEN sr.Status = 'Processing' THEN 1 END) AS Processing,
    COUNT(CASE WHEN sr.Status = 'Rejected' THEN 1 END) AS Rejected,
    COUNT(sr.Request_ID) AS Total
FROM Department d
LEFT JOIN Service s ON d.Department_ID = s.Department_ID
LEFT JOIN Service_Request sr ON s.Service_ID = sr.Service_ID
GROUP BY d.Department_ID, d.Department_Name
ORDER BY Total DESC;

-- 16.2 Monthly revenue by payment method (pivot)
SELECT 
    DATE_FORMAT(p.Payment_Date, '%Y-%m') AS Month,
    SUM(CASE WHEN p.Payment_Method = 'UPI' THEN p.Amount ELSE 0 END) AS UPI_Revenue,
    SUM(CASE WHEN p.Payment_Method = 'Card' THEN p.Amount ELSE 0 END) AS Card_Revenue,
    SUM(CASE WHEN p.Payment_Method = 'Cash' THEN p.Amount ELSE 0 END) AS Cash_Revenue,
    SUM(p.Amount) AS Total_Revenue
FROM Payment p
WHERE p.Status = 'Completed'
GROUP BY DATE_FORMAT(p.Payment_Date, '%Y-%m')
ORDER BY Month;

-- ==========================================
-- 17. PERFORMANCE & OPTIMIZATION QUERIES
-- ==========================================

-- 17.1 Index suggestions query - Find frequently joined columns
SELECT 
    'Service_Request' AS Table_Name,
    'Citizen_ID' AS Column_Name,
    COUNT(*) AS Join_Frequency,
    'Foreign Key - High Usage' AS Recommendation
FROM Service_Request
GROUP BY Citizen_ID
HAVING COUNT(*) > 1
UNION ALL
SELECT 
    'Service_Request' AS Table_Name,
    'Service_ID' AS Column_Name,
    COUNT(*) AS Join_Frequency,
    'Foreign Key - High Usage' AS Recommendation
FROM Service_Request
GROUP BY Service_ID
HAVING COUNT(*) > 1;

-- 17.2 Data quality check - Find incomplete records
SELECT 
    'Citizen' AS Table_Name,
    'Missing Email' AS Issue,
    COUNT(*) AS Count
FROM Citizen
WHERE Email IS NULL OR Email = ''
UNION ALL
SELECT 
    'Citizen' AS Table_Name,
    'Missing Phone' AS Issue,
    COUNT(*) AS Count
FROM Citizen
WHERE Phone IS NULL OR Phone = ''
UNION ALL
SELECT 
    'Service_Request' AS Table_Name,
    'Missing Payment' AS Issue,
    COUNT(*) AS Count
FROM Service_Request
WHERE Payment_ID IS NULL
UNION ALL
SELECT 
    'Payment' AS Table_Name,
    'Pending Payments > 30 Days' AS Issue,
    COUNT(*) AS Count
FROM Payment
WHERE Status = 'Pending' AND DATEDIFF(CURDATE(), Payment_Date) > 30;

-- ==========================================
-- END OF COMPLEX QUERIES
-- ==========================================
