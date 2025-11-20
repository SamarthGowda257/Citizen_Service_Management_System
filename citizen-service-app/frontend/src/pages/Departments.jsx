import { useState, useEffect } from 'react';
import { Plus, Building2, Mail } from 'lucide-react';
import { getDepartments, createDepartment } from '../api/api';

const Departments = () => {
  const [departments, setDepartments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    Department_Name: '',
    Contact_Info: ''
  });

  useEffect(() => {
    fetchDepartments();
  }, []);

  const fetchDepartments = async () => {
    try {
      const response = await getDepartments();
      setDepartments(response.data);
    } catch (error) {
      console.error('Error fetching departments:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await createDepartment(formData);
      setShowModal(false);
      setFormData({ Department_Name: '', Contact_Info: '' });
      fetchDepartments();
    } catch (error) {
      console.error('Error creating department:', error);

      // ✅ Display backend trigger message (from SQL)
      let message =
        error.response?.data?.detail ||
        error.message ||
        'An unexpected error occurred while creating the department.';
      if (typeof message === 'object') {
        message = JSON.stringify(message);
      }
      alert('❌ ' + message);
    }
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
          <h1 className="text-3xl font-bold text-gray-900">Departments</h1>
          <p className="text-gray-600 mt-1">Government departments and offices</p>
        </div>
        <button
          onClick={() => setShowModal(true)}
          className="btn-primary flex items-center space-x-2"
        >
          <Plus className="w-5 h-5" />
          <span>Add Department</span>
        </button>
      </div>

      {/* Departments Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {departments.map((dept) => (
          <div key={dept.Department_ID} className="card hover:shadow-xl transition-shadow">
            <div className="flex items-start space-x-4">
              <div className="p-3 bg-gradient-to-br from-primary-500 to-primary-600 rounded-lg">
                <Building2 className="w-8 h-8 text-white" />
              </div>
              <div className="flex-1">
                <h3 className="text-lg font-semibold text-gray-900">
                  {dept.Department_Name}
                </h3>
                <p className="text-sm text-gray-500 mt-1">ID: {dept.Department_ID}</p>
              </div>
            </div>
            <div className="mt-4 pt-4 border-t border-gray-200">
              <div className="flex items-start text-sm text-gray-600">
                <Mail className="w-4 h-4 mr-2 mt-0.5 flex-shrink-0" />
                <span className="break-all">{dept.Contact_Info || 'No contact info'}</span>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl shadow-2xl max-w-md w-full">
            <div className="p-6 border-b border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900">Add New Department</h2>
            </div>

            {/* 🔧 Disable browser validation */}
            <form onSubmit={handleSubmit} noValidate className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Department Name
                </label>
                <input
                  type="text"
                  value={formData.Department_Name}
                  onChange={(e) =>
                    setFormData({ ...formData, Department_Name: e.target.value })
                  }
                  className="input-field"
                  placeholder="Enter department name"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Contact Information
                </label>
                <textarea
                  value={formData.Contact_Info}
                  onChange={(e) =>
                    setFormData({ ...formData, Contact_Info: e.target.value })
                  }
                  className="input-field"
                  rows="3"
                  placeholder="Email, phone, address..."
                />
              </div>

              <div className="flex space-x-3 pt-4">
                <button type="submit" className="btn-primary flex-1">
                  Create
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setShowModal(false);
                    setFormData({ Department_Name: '', Contact_Info: '' });
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

export default Departments;
