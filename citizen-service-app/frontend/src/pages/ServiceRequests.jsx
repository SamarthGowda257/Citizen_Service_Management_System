import { useState, useEffect } from 'react';
import { FileText, Calendar, DollarSign } from 'lucide-react';
import { getServiceRequests } from '../api/api';

const ServiceRequests = () => {
  const [requests, setRequests] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('All');

  useEffect(() => {
    fetchRequests();
  }, []);

  const fetchRequests = async () => {
    try {
      const response = await getServiceRequests();
      setRequests(response.data);
    } catch (error) {
      console.error('Error fetching requests:', error);
    } finally {
      setLoading(false);
    }
  };

  const getStatusBadge = (status) => {
    const badges = {
      'Completed': 'badge-success',
      'Pending': 'badge-warning',
      'Processing': 'badge-info',
      'Rejected': 'badge-danger',
    };
    return badges[status] || 'badge-info';
  };

  const filteredRequests = filter === 'All' 
    ? requests 
    : requests.filter(req => req.Status === filter);

  const statusCounts = {
    All: requests.length,
    Completed: requests.filter(r => r.Status === 'Completed').length,
    Pending: requests.filter(r => r.Status === 'Pending').length,
    Processing: requests.filter(r => r.Status === 'Processing').length,
    Rejected: requests.filter(r => r.Status === 'Rejected').length,
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Service Requests</h1>
        <p className="text-gray-600 mt-1">Track and manage all service requests</p>
      </div>

      {/* Filter Tabs */}
      <div className="card">
        <div className="flex flex-wrap gap-2">
          {Object.entries(statusCounts).map(([status, count]) => (
            <button
              key={status}
              onClick={() => setFilter(status)}
              className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                filter === status
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              {status} ({count})
            </button>
          ))}
        </div>
      </div>

      {/* Requests List */}
      <div className="grid grid-cols-1 gap-4">
        {filteredRequests.map((request) => (
          <div key={request.Request_ID} className="card hover:shadow-xl transition-shadow">
            <div className="flex items-start justify-between">
              <div className="flex-1">
                <div className="flex items-center space-x-3 mb-2">
                  <FileText className="w-5 h-5 text-primary-600" />
                  <h3 className="text-lg font-semibold text-gray-900">
                    Request #{request.Request_ID}
                  </h3>
                  <span className={`badge ${getStatusBadge(request.Status)}`}>
                    {request.Status}
                  </span>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
                  <div>
                    <p className="text-sm text-gray-500">Citizen ID</p>
                    <p className="font-medium text-gray-900">{request.Citizen_ID}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Service ID</p>
                    <p className="font-medium text-gray-900">{request.Service_ID}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Payment ID</p>
                    <p className="font-medium text-gray-900">{request.Payment_ID || 'N/A'}</p>
                  </div>
                </div>
              </div>
              <div className="text-right ml-4">
                <div className="flex items-center text-sm text-gray-600 mb-2">
                  <Calendar className="w-4 h-4 mr-1" />
                  {new Date(request.Request_Date).toLocaleDateString()}
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {filteredRequests.length === 0 && (
        <div className="card text-center py-12">
          <FileText className="w-16 h-16 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-600">No service requests found</p>
        </div>
      )}
    </div>
  );
};

export default ServiceRequests;
