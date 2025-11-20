-- =====================================================
-- SAMPLE DATA FOR CITIZEN SERVICE MANAGEMENT SYSTEM
-- =====================================================

-- Insert Citizens
INSERT INTO Citizen (Citizen_ID, Name, Address, Phone, Email, Aadhaar_Number) VALUES
(1, 'Rajesh Kumar', '123 MG Road, Mumbai', '9876543210', 'rajesh.kumar@email.com', '1234-5678-9012'),
(2, 'Priya Sharma', '456 Park Street, Delhi', '9876543211', 'priya.sharma@email.com', '2345-6789-0123'),
(3, 'Amit Patel', '789 Lake View, Bangalore', '9876543212', 'amit.patel@email.com', '3456-7890-1234'),
(4, 'Sneha Reddy', '321 Church Road, Chennai', '9876543213', 'sneha.reddy@email.com', '4567-8901-2345'),
(5, 'Vikram Singh', '654 Mall Road, Pune', '9876543214', 'vikram.singh@email.com', '5678-9012-3456'),
(6, 'Anita Verma', '987 Station Road, Kolkata', '9876543215', 'anita.verma@email.com', '6789-0123-4567'),
(7, 'Karan Mehta', '147 Beach Road, Mumbai', '9876543216', 'karan.mehta@email.com', '7890-1234-5678'),
(8, 'Neha Gupta', '258 Hill View, Delhi', '9876543217', 'neha.gupta@email.com', '8901-2345-6789'),
(9, 'Suresh Nair', '369 Garden Street, Bangalore', '9876543218', 'suresh.nair@email.com', '9012-3456-7890'),
(10, 'Pooja Joshi', '741 Market Road, Chennai', '9876543219', 'pooja.joshi@email.com', '0123-4567-8901');

-- Insert Departments
INSERT INTO Department (Department_ID, Department_Name, Contact_Info) VALUES
(1, 'Municipal Corporation', 'muni@gov.in, 022-12345678'),
(2, 'Revenue Department', 'revenue@gov.in, 011-23456789'),
(3, 'Police Department', 'police@gov.in, 080-34567890'),
(4, 'Health Department', 'health@gov.in, 044-45678901'),
(5, 'Transport Department', 'transport@gov.in, 020-56789012'),
(6, 'Education Department', 'education@gov.in, 033-67890123'),
(7, 'Water Supply Department', 'water@gov.in, 022-78901234');

-- Insert Services
INSERT INTO Service (Service_ID, Service_Name, Service_Type, Department_ID) VALUES
(1, 'Birth Certificate', 'Certificate', 1),
(2, 'Death Certificate', 'Certificate', 1),
(3, 'Property Tax Payment', 'Utility', 1),
(4, 'Land Registration', 'Certificate', 2),
(5, 'Income Certificate', 'Certificate', 2),
(6, 'Police Verification', 'Certificate', 3),
(7, 'Health Card', 'Certificate', 4),
(8, 'Driving License', 'Certificate', 5),
(9, 'Vehicle Registration', 'Certificate', 5),
(10, 'School Admission', 'Certificate', 6),
(11, 'Water Connection', 'Utility', 7),
(12, 'Water Bill Payment', 'Utility', 7);

-- Insert Payments
INSERT INTO Payment (Payment_ID, Amount, Payment_Date, Payment_Method, Status) VALUES
(1, 500.00, '2025-01-15', 'UPI', 'Completed'),
(2, 300.00, '2025-01-20', 'Card', 'Completed'),
(3, 1500.00, '2025-02-10', 'UPI', 'Completed'),
(4, 2000.00, '2025-02-15', 'Cash', 'Completed'),
(5, 400.00, '2025-03-05', 'UPI', 'Completed'),
(6, 800.00, '2025-03-10', 'Card', 'Pending'),
(7, 1000.00, '2025-04-01', 'UPI', 'Completed'),
(8, 600.00, '2025-04-15', 'Card', 'Completed'),
(9, 3000.00, '2025-05-20', 'UPI', 'Failed'),
(10, 500.00, '2025-06-10', 'Cash', 'Completed'),
(11, 750.00, '2025-07-05', 'UPI', 'Completed'),
(12, 450.00, '2025-08-12', 'Card', 'Completed'),
(13, 1200.00, '2025-09-18', 'UPI', 'Completed'),
(14, 900.00, '2025-10-01', 'Cash', 'Pending'),
(15, 550.00, '2025-10-20', 'UPI', 'Completed');

-- Insert Service Requests
INSERT INTO Service_Request (Request_ID, Citizen_ID, Service_ID, Request_Date, Status, Payment_ID) VALUES
(1, 1, 1, '2025-01-15', 'Completed', 1),
(2, 2, 3, '2025-01-20', 'Completed', 2),
(3, 3, 4, '2025-02-10', 'Completed', 3),
(4, 4, 8, '2025-02-15', 'Completed', 4),
(5, 5, 5, '2025-03-05', 'Processing', 5),
(6, 6, 6, '2025-03-10', 'Pending', 6),
(7, 7, 9, '2025-04-01', 'Completed', 7),
(8, 1, 7, '2025-04-15', 'Completed', 8),
(9, 2, 4, '2025-05-20', 'Rejected', 9),
(10, 8, 2, '2025-06-10', 'Completed', 10),
(11, 9, 11, '2025-07-05', 'Completed', 11),
(12, 10, 10, '2025-08-12', 'Processing', 12),
(13, 3, 12, '2025-09-18', 'Completed', 13),
(14, 4, 1, '2025-10-01', 'Pending', 14),
(15, 5, 3, '2025-10-20', 'Completed', 15);

-- Insert Grievances
INSERT INTO Grievance (Grievance_ID, Citizen_ID, Department_ID, Description, Status, Date) VALUES
(1, 1, 1, 'Street lights not working in my area', 'Resolved', '2025-01-10'),
(2, 2, 7, 'Water supply irregular for past week', 'Open', '2025-02-05'),
(3, 3, 1, 'Garbage collection not done regularly', 'In Progress', '2025-02-20'),
(4, 4, 5, 'Road conditions very poor, need repair', 'Open', '2025-03-15'),
(5, 5, 4, 'No cleanliness maintained at public hospital', 'Resolved', '2025-04-10'),
(6, 6, 3, 'Traffic congestion at main junction', 'In Progress', '2025-05-05'),
(7, 7, 7, 'Water contamination reported', 'Resolved', '2025-06-01'),
(8, 8, 1, 'Property tax calculation incorrect', 'Open', '2025-07-15'),
(9, 9, 2, 'Land records not updated', 'In Progress', '2025-08-20'),
(10, 10, 6, 'School infrastructure needs improvement', 'Open', '2025-09-10');
