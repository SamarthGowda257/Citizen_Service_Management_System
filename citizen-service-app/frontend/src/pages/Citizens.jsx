import { useState, useEffect } from 'react';
import { Plus, Search, Edit, Trash2, Mail, Phone } from 'lucide-react';
import { getCitizens, createCitizen, updateCitizen, deleteCitizen } from '../api/api';

const Citizens = () => {
  const [citizens, setCitizens] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingCitizen, setEditingCitizen] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [formData, setFormData] = useState({
    Name: '',
    Address: '',
    Phone: '',
    Email: '',
    Aadhaar_Number: ''
  });

  useEffect(() => {
    fetchCitizens();
  }, []);

  const fetchCitizens = async () => {
    try {
      const response = await getCitizens();
      setCitizens(response.data);
    } catch (error) {
      console.error('Error fetching citizens:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editingCitizen) {
        await updateCitizen(editingCitizen.Citizen_ID, formData);
      } else {
        await createCitizen(formData);
      }
      setShowModal(false);
      resetForm();
      fetchCitizens();
    } catch (error) {
      console.error("Error saving citizen:", error);

      // Check for backend trigger message
      const message =
        error.response?.data?.detail ||
        error.message ||
        "An unexpected error occurred while saving the citizen.";

      alert("❌ " + message);
    }
  };

  const handleEdit = (citizen) => {
    setEditingCitizen(citizen);
    setFormData({
      Name: citizen.Name,
      Address: citizen.Address || '',
      Phone: citizen.Phone || '',
      Email: citizen.Email || '',
      Aadhaar_Number: citizen.Aadhaar_Number || ''
    });
    setShowModal(true);
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this citizen?')) {
      try {
        await deleteCitizen(id);
        fetchCitizens();
      } catch (error) {
        console.error('Error deleting citizen:', error);
        alert('Error deleting citizen. They may have related records.');
      }
    }
  };

  const resetForm = () => {
    setFormData({
      Name: '',
      Address: '',
      Phone: '',
      Email: '',
      Aadhaar_Number: ''
    });
    setEditingCitizen(null);
  };

  const filteredCitizens = citizens.filter(citizen =>
    citizen.Name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    citizen.Email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    citizen.Phone?.includes(searchTerm)
  );

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
          <h1 className="text-3xl font-bold text-gray-900">Citizens</h1>
          <p className="text-gray-600 mt-1">Manage citizen information and records</p>
        </div>
        <button
          onClick={() => {
            resetForm();
            setShowModal(true);
          }}
          className="btn-primary flex items-center space-x-2"
        >
          <Plus className="w-5 h-5" />
          <span>Add Citizen</span>
        </button>
      </div>

      {/* Search */}
      <div className="card">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
          <input
            type="text"
            placeholder="Search by name, email, or phone..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="input-field pl-10"
          />
        </div>
      </div>

      {/* Citizens Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredCitizens.map((citizen) => (
          <div key={citizen.Citizen_ID} className="card hover:shadow-xl transition-shadow">
            <div className="flex items-start justify-between mb-4">
              <div className="flex-1">
                <h3 className="text-lg font-semibold text-gray-900">{citizen.Name}</h3>
                <p className="text-sm text-gray-500">ID: {citizen.Citizen_ID}</p>
              </div>
              <div className="flex space-x-2">
                <button
                  onClick={() => handleEdit(citizen)}
                  className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                >
                  <Edit className="w-4 h-4" />
                </button>
                <button
                  onClick={() => handleDelete(citizen.Citizen_ID)}
                  className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            </div>
            <div className="space-y-2 text-sm">
              <div className="flex items-center text-gray-600">
                <Mail className="w-4 h-4 mr-2" />
                {citizen.Email || 'No email'}
              </div>
              <div className="flex items-center text-gray-600">
                <Phone className="w-4 h-4 mr-2" />
                {citizen.Phone || 'No phone'}
              </div>
              <div className="text-gray-600">
                <span className="font-medium">Address:</span> {citizen.Address || 'No address'}
              </div>
              <div className="text-gray-600">
                <span className="font-medium">Aadhaar:</span> {citizen.Aadhaar_Number || 'N/A'}
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl shadow-2xl max-w-md w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6 border-b border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900">
                {editingCitizen ? 'Edit Citizen' : 'Add New Citizen'}
              </h2>
            </div>

            {/* 🔧 Added noValidate to disable HTML validation */}
            <form onSubmit={handleSubmit} noValidate className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Full Name *
                </label>
                <input
                  type="text"
                  value={formData.Name}
                  onChange={(e) => setFormData({ ...formData, Name: e.target.value })}
                  className="input-field"
                  placeholder="Enter full name"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <input
                  type="email"
                  value={formData.Email}
                  onChange={(e) => setFormData({ ...formData, Email: e.target.value })}
                  className="input-field"
                  placeholder="email@example.com"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Phone</label>
                <input
                  type="tel"
                  value={formData.Phone}
                  onChange={(e) => setFormData({ ...formData, Phone: e.target.value })}
                  className="input-field"
                  placeholder="9876543210"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Address</label>
                <textarea
                  value={formData.Address}
                  onChange={(e) => setFormData({ ...formData, Address: e.target.value })}
                  className="input-field"
                  rows="3"
                  placeholder="Enter address"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Aadhaar Number
                </label>
                <input
                  type="text"
                  value={formData.Aadhaar_Number}
                  onChange={(e) => setFormData({ ...formData, Aadhaar_Number: e.target.value })}
                  className="input-field"
                  placeholder="1234-5678-9012"
                />
              </div>

              <div className="flex space-x-3 pt-4">
                <button type="submit" className="btn-primary flex-1">
                  {editingCitizen ? 'Update' : 'Create'}
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setShowModal(false);
                    resetForm();
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

export default Citizens;
