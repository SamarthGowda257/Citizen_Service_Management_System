import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: { 'Content-Type': 'application/json' },
});

// Dashboard APIs
export const getDashboardStats = () => api.get('/dashboard/stats');
export const getRecentRequests = (limit = 10) =>
  api.get(`/dashboard/recent-requests?limit=${limit}`);
export const getDepartmentPerformance = () => api.get('/dashboard/department-performance');
export const getMonthlyTrends = () => api.get('/dashboard/monthly-trends');

// Citizens APIs
export const getCitizens = (skip = 0, limit = 100) =>
  api.get(`/citizens?skip=${skip}&limit=${limit}`);
export const getCitizen = (id) => api.get(`/citizens/${id}`);
export const createCitizen = (data) => api.post('/citizens', data);
export const updateCitizen = (id, data) => api.put(`/citizens/${id}`, data);
export const deleteCitizen = (id) => api.delete(`/citizens/${id}`);

// ✅ NEW: Citizen Logs API (trigger-based insights)
export const getCitizenLogs = () => api.get('/citizen-logs');

// Departments APIs
export const getDepartments = () => api.get('/departments');
export const getDepartment = (id) => api.get(`/departments/${id}`);
export const createDepartment = (data) => api.post('/departments', data);

// Services APIs
export const getServices = () => api.get('/services');
export const getService = (id) => api.get(`/services/${id}`);
export const createService = (data) => api.post('/services', data);

// Service Requests APIs
export const getServiceRequests = (skip = 0, limit = 100) =>
  api.get(`/service-requests?skip=${skip}&limit=${limit}`);
export const createServiceRequest = (data) => api.post('/service-requests', data);

// Grievances APIs
export const getGrievances = (skip = 0, limit = 100) =>
  api.get(`/grievances?skip=${skip}&limit=${limit}`);
export const createGrievance = (data) => api.post('/grievances', data);

// ✅ Stored Procedure APIs
export const getDepartmentServiceCount = () =>
  api.get('/procedures/department-service-count');
export const getPendingRequests = () => api.get('/procedures/pending-requests');
export const getPaymentSummary = () => api.get('/procedures/payment-summary');
export const getGrievancesByDepartment = () =>
  api.get('/procedures/grievances-by-department');

// ✅ NEW SQL Function APIs
export const getDepartmentPerformanceFunction = () =>
  api.get('/dashboard/department-performance-function');

export const getServiceRevenueFunction = () =>
  api.get('/dashboard/service-revenue-function');

export default api;
