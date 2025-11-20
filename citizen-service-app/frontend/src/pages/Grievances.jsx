import { useState, useEffect } from 'react';
import { Plus, MessageSquare, Calendar, AlertCircle } from 'lucide-react';
import { getGrievances, createGrievance, getDepartments, getCitizens } from '../api/api';

const Grievances = () => {
  const [grievances, setGrievances] = useState([]);
  const [departments, setDepartments] = useState([]);
  const [citizens, setCitizens] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [filter, setFilter] = useState('All');
  const [formData, setFormData] = useState({
    Citizen_ID: '',
    Department_ID: '',
    Description: '',
    Status: '',
    Date: new Date().toISOString().split('T')[0],
  });

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const [grievancesRes, deptsRes, citizensRes] = await Promise.all([
        getGrievances(),
        getDepartments(),
        getCitizens(),
      ]);
      setGrievances(grievancesRes.data);
      setDepartments(deptsRes.data);
      setCitizens(citizensRes.data);
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await createGrievance({
        ...formData,
        Citizen_ID: formData.Citizen_ID ? parseInt(formData.Citizen_ID) : null,
        Department_ID: formData.Department_ID ? parseInt(formData.Department_ID) : null,
      });
      setShowModal(false);
      setFormData({
        Citizen_ID: '',
        Department_ID: '',
        Description: '',
        Status: '',
        Date: new Date().toISOString().split('T')[0],
      });
      fetchData();
    } catch (error) {
      console.error('Error creating grievance:', error);

      // ✅ Display SQL trigger or backend validation error
      const message =
        error.response?.data?.detail ||
        error.message ||
        'An unexpected error occurred while creating the grievance.';

      alert('❌ ' + message);
    }
  };

  const getStatusBadge = (status) => {
    const badges = {
      Open: 'badge-danger',
      'In Progress': 'badge-warning',
      Resolved: 'badge-success',
    };
    return badges[status] || 'badge-info';
  };

  const filteredGrievances =
    filter === 'All'
      ? grievances
      : grievances.filter((g) => g.Status === filter);

  const statusCounts = {
    All: grievances.length,
    Open: grievances.filter((g) => g.Status === 'Open').length,
    'In Progress': grievances.filter((g) => g.Status === 'In Progress').length,
    Resolved: grievances.filter((g) => g.Status === 'Resolved').length,
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
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Grievances</h1>
          <p className="text-gray-600 mt-1">Manage citizen complaints and issues</p>
        </div>
        <button
          onClick={() => setShowModal(true)}
          className="btn-primary flex items-center space-x-2"
        >
          <Plus className="w-5 h-5" />
          <span>New Grievance</span>
        </button>
      </div>

      {/* Status Filter */}
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

      {/* Grievances List */}
      <div className="grid grid-cols-1 gap-4">
        {filteredGrievances.map((grievance) => (
          <div
            key={grievance.Grievance_ID}
            className="card hover:shadow-xl transition-shadow"
          >
            <div className="flex items-start justify-between mb-4">
              <div className="flex items-center space-x-3">
                <div className="p-2 bg-orange-100 rounded-lg">
                  <AlertCircle className="w-6 h-6 text-orange-600" />
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">
                    Grievance #{grievance.Grievance_ID}
                  </h3>
                  <span
                    className={`badge ${getStatusBadge(grievance.Status)} mt-1`}
                  >
                    {grievance.Status}
                  </span>
                </div>
              </div>
              <div className="flex items-center text-sm text-gray-600">
                <Calendar className="w-4 h-4 mr-1" />
                {new Date(grievance.Date).toLocaleDateString()}
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 mb-4">
              <p className="text-gray-700">{grievance.Description}</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
              <div>
                <p className="text-gray-500">Citizen ID</p>
                <p className="font-medium text-gray-900">
                  {grievance.Citizen_ID}
                </p>
              </div>
              <div>
                <p className="text-gray-500">Department ID</p>
                <p className="font-medium text-gray-900">
                  {grievance.Department_ID}
                </p>
              </div>
            </div>
          </div>
        ))}
      </div>

      {filteredGrievances.length === 0 && (
        <div className="card text-center py-12">
          <MessageSquare className="w-16 h-16 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-600">No grievances found</p>
        </div>
      )}

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl shadow-2xl max-w-md w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6 border-b border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900">New Grievance</h2>
            </div>

            {/* 🔧 Disable browser validation completely */}
            <form onSubmit={handleSubmit} noValidate className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Citizen
                </label>
                <select
                  value={formData.Citizen_ID}
                  onChange={(e) =>
                    setFormData({ ...formData, Citizen_ID: e.target.value })
                  }
                  className="input-field"
                >
                  <option value="">Select citizen</option>
                  {citizens.map((citizen) => (
                    <option
                      key={citizen.Citizen_ID}
                      value={citizen.Citizen_ID}
                    >
                      {citizen.Name} (ID: {citizen.Citizen_ID})
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Department
                </label>
                <select
                  value={formData.Department_ID}
                  onChange={(e) =>
                    setFormData({ ...formData, Department_ID: e.target.value })
                  }
                  className="input-field"
                >
                  <option value="">Select department</option>
                  {departments.map((dept) => (
                    <option
                      key={dept.Department_ID}
                      value={dept.Department_ID}
                    >
                      {dept.Department_Name}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Description
                </label>
                <textarea
                  value={formData.Description}
                  onChange={(e) =>
                    setFormData({ ...formData, Description: e.target.value })
                  }
                  className="input-field"
                  rows="4"
                  placeholder="Describe the grievance..."
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Status
                </label>
                <select
                  value={formData.Status}
                  onChange={(e) =>
                    setFormData({ ...formData, Status: e.target.value })
                  }
                  className="input-field"
                >
                  <option value="">Select status</option>
                  <option value="Open">Open</option>
                  <option value="In Progress">In Progress</option>
                  <option value="Resolved">Resolved</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Date
                </label>
                <input
                  type="date"
                  value={formData.Date}
                  onChange={(e) =>
                    setFormData({ ...formData, Date: e.target.value })
                  }
                  className="input-field"
                />
              </div>

              <div className="flex space-x-3 pt-4">
                <button type="submit" className="btn-primary flex-1">
                  Submit
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setShowModal(false);
                    setFormData({
                      Citizen_ID: '',
                      Department_ID: '',
                      Description: '',
                      Status: '',
                      Date: new Date().toISOString().split('T')[0],
                    });
                  }}
                  className="btn-secondary flex-1"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Grievances;
