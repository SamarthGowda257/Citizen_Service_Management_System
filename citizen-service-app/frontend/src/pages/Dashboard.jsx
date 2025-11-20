import { useEffect, useState } from "react";
import {
  Users,
  FileText,
  MessageSquare,
  DollarSign,
  BarChart3,
  LineChart as LineIcon,
  TrendingUp,
} from "lucide-react";
import {
  getDashboardStats,
  getRecentRequests,
  getDepartmentPerformance,
  getDepartmentServiceCount,
  getPendingRequests,
  getPaymentSummary,
  getGrievancesByDepartment,
  getDepartmentPerformanceFunction,
  getServiceRevenueFunction,
} from "../api/api";

import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
  Pie,
  PieChart as RePieChart,
  Cell,
  LineChart,
  Line,
  ResponsiveContainer,
  Legend,
} from "recharts";

const COLORS = ["#4f46e5", "#22c55e", "#f97316", "#ef4444", "#06b6d4"];

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [recentRequests, setRecentRequests] = useState([]);
  const [deptServices, setDeptServices] = useState([]);
  const [pendingRequests, setPendingRequests] = useState([]);
  const [paymentSummary, setPaymentSummary] = useState([]);
  const [grievanceSummary, setGrievanceSummary] = useState([]);
  const [deptFunctionPerformance, setDeptFunctionPerformance] = useState([]);
  const [serviceRevenueFunction, setServiceRevenueFunction] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchAllData();
  }, []);

  const fetchAllData = async () => {
    try {
      const [
        statsRes,
        requestsRes,
        deptRes,
        pendingRes,
        paymentRes,
        grievanceRes,
        deptFuncRes,
        serviceFuncRes,
      ] = await Promise.all([
        getDashboardStats(),
        getRecentRequests(5),
        getDepartmentServiceCount(),
        getPendingRequests(),
        getPaymentSummary(),
        getGrievancesByDepartment(),
        getDepartmentPerformanceFunction(),
        getServiceRevenueFunction(),
      ]);

      setStats(statsRes.data);
      setRecentRequests(requestsRes.data);
      setDeptServices(deptRes.data);
      setPendingRequests(pendingRes.data);
      setPaymentSummary(paymentRes.data);
      setGrievanceSummary(grievanceRes.data);
      setDeptFunctionPerformance(deptFuncRes.data);
      setServiceRevenueFunction(serviceFuncRes.data);
    } catch (error) {
      console.error("Error loading dashboard data:", error);
      alert("Error loading dashboard data");
    } finally {
      setLoading(false);
    }
  };

  const StatCard = ({ title, value, icon: Icon, gradient }) => (
    <div className={`gradient-card ${gradient} animate-slide-up`}>
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm opacity-90">{title}</p>
          <p className="text-3xl font-bold mt-2">{value}</p>
        </div>
        <div className="p-4 bg-white bg-opacity-20 rounded-full">
          <Icon className="w-8 h-8 text-white" />
        </div>
      </div>
    </div>
  );

  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-10 animate-slide-up">
      {/* Header */}
      <div className="text-center">
        <h1 className="text-4xl font-extrabold bg-clip-text text-transparent bg-gradient-to-r from-blue-600 to-purple-600">
          Analytics Dashboard
        </h1>
        <p className="text-gray-600 mt-2 text-lg">
          Interactive insights powered by SQL Functions ⚡
        </p>
      </div>

      {/* Stat Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Citizens"
          value={stats?.total_citizens || 0}
          icon={Users}
          gradient="gradient-blue"
        />
        <StatCard
          title="Service Requests"
          value={stats?.total_requests || 0}
          icon={FileText}
          gradient="gradient-green"
        />
        <StatCard
          title="Total Grievances"
          value={stats?.total_grievances || 0}
          icon={MessageSquare}
          gradient="gradient-orange"
        />
        <StatCard
          title="Total Revenue"
          value={`₹${stats?.total_revenue?.toLocaleString() || 0}`}
          icon={DollarSign}
          gradient="gradient-purple"
        />
      </div>

      {/* Graphs Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 animate-slide-up">
        {/* Department Service Count */}
        <div className="card">
          <div className="flex items-center mb-4">
            <BarChart3 className="w-5 h-5 text-blue-600 mr-2" />
            <h2 className="text-lg font-semibold text-gray-900">
              Department-wise Services
            </h2>
          </div>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={deptServices}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="Department_Name" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="Total_Services" fill="#4f46e5" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Grievances by Department */}
        <div className="card">
          <div className="flex items-center mb-4">
            <MessageSquare className="w-5 h-5 text-red-600 mr-2" />
            <h2 className="text-lg font-semibold text-gray-900">
              Grievances by Department
            </h2>
          </div>
          <ResponsiveContainer width="100%" height={300}>
            <RePieChart>
              <Pie
                data={grievanceSummary}
                dataKey="Total_Grievances"
                nameKey="Department_Name"
                cx="50%"
                cy="50%"
                outerRadius={100}
                label
              >
                {grievanceSummary.map((_, i) => (
                  <Cell key={i} fill={COLORS[i % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip />
              <Legend />
            </RePieChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* ✅ SQL FUNCTION CHARTS */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 animate-slide-up">
        {/* Department Performance Function */}
        <div className="card">
          <div className="flex items-center mb-4">
            <TrendingUp className="w-5 h-5 text-indigo-600 mr-2" />
            <h2 className="text-lg font-semibold text-gray-900">
              Department Performance (SQL Function)
            </h2>
          </div>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={deptFunctionPerformance}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="Department_Name" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="Performance" fill="#6366f1" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Service Revenue Function */}
        <div className="card">
          <div className="flex items-center mb-4">
            <DollarSign className="w-5 h-5 text-purple-600 mr-2" />
            <h2 className="text-lg font-semibold text-gray-900">
              Service Revenue (SQL Function)
            </h2>
          </div>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={serviceRevenueFunction}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="Service_Name" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="Total_Revenue" fill="#8b5cf6" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Payment Summary + Pending Requests */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 animate-slide-up">
        {/* Payment Summary */}
        <div className="card">
          <div className="flex items-center mb-4">
            <DollarSign className="w-5 h-5 text-green-600 mr-2" />
            <h2 className="text-lg font-semibold text-gray-900">
              Payment Summary
            </h2>
          </div>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={paymentSummary}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="Status" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="Total_Amount" fill="#22c55e" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Pending Requests Trend */}
        <div className="card">
          <div className="flex items-center mb-4">
            <LineIcon className="w-5 h-5 text-orange-600 mr-2" />
            <h2 className="text-lg font-semibold text-gray-900">
              Pending Requests Trend
            </h2>
          </div>
          {pendingRequests.length > 0 ? (
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={pendingRequests}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="Citizen_Name" />
                <YAxis />
                <Tooltip />
                <Line
                  type="monotone"
                  dataKey="Request_ID"
                  stroke="#f97316"
                  strokeWidth={2}
                />
              </LineChart>
            </ResponsiveContainer>
          ) : (
            <p className="text-gray-500 text-sm text-center mt-6">
              No pending requests found.
            </p>
          )}
        </div>
      </div>

      {/* Recent Requests */}
      <div className="card animate-slide-up">
        <h2 className="text-xl font-semibold mb-4 text-gray-900">
          Recent Service Requests
        </h2>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-200">
                {[
                  "Request ID",
                  "Citizen",
                  "Service",
                  "Department",
                  "Date",
                  "Status",
                ].map((h) => (
                  <th
                    key={h}
                    className="text-left py-3 px-4 font-semibold text-gray-700"
                  >
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {recentRequests.map((req, i) => (
                <tr
                  key={i}
                  className="border-b border-gray-100 hover:bg-gray-50 transition-colors"
                >
                  <td className="py-3 px-4 font-medium text-gray-900">
                    #{req.Request_ID}
                  </td>
                  <td className="py-3 px-4 text-gray-700">{req.Citizen_Name}</td>
                  <td className="py-3 px-4 text-gray-700">{req.Service_Name}</td>
                  <td className="py-3 px-4 text-gray-700">
                    {req.Department_Name}
                  </td>
                  <td className="py-3 px-4 text-gray-700">
                    {req.Request_Date
                      ? new Date(req.Request_Date).toLocaleDateString()
                      : "N/A"}
                  </td>
                  <td className="py-3 px-4 text-gray-700">{req.Status}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
