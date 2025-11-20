# Citizen Service Management System

A premium full-stack web application for managing citizen services, built with React, FastAPI, and MySQL.

## 🚀 Features

- **Dashboard** - Real-time statistics and analytics
- **Citizen Management** - Add, edit, and manage citizen records
- **Service Catalog** - Browse and manage government services
- **Service Requests** - Track service request status and history
- **Grievance System** - Submit and monitor grievances
- **Department Management** - Organize services by departments

## 🛠️ Technology Stack

### Frontend
- **React 18** - Modern UI library
- **Vite** - Fast build tool
- **Tailwind CSS** - Utility-first CSS framework
- **Lucide React** - Beautiful icons
- **Axios** - HTTP client
- **React Router** - Client-side routing

### Backend
- **FastAPI** - Modern Python web framework
- **SQLAlchemy** - SQL toolkit and ORM
- **PyMySQL** - MySQL database driver
- **Pydantic** - Data validation
- **Uvicorn** - ASGI server

### Database
- **MySQL** - Relational database

## 📋 Prerequisites

- Node.js 18+ and npm
- Python 3.8+
- MySQL 8.0+

## 🔧 Installation

### 1. Database Setup

```cmd
REM Create database
mysql -u root -p
```

```sql
CREATE DATABASE citizen_service;
USE citizen_service;

-- Run schema.sql from parent directory
SOURCE ../schema.sql;

-- Insert sample data (optional)
SOURCE ../sample_data.sql;
```

### 2. Backend Setup

```cmd
cd backend

REM Create virtual environment
python -m venv venv

REM Activate virtual environment
venv\Scripts\activate

REM Install dependencies
pip install -r requirements.txt

REM Create .env file
copy .env.example .env

REM Edit .env file with your database credentials
notepad .env
```

Update `.env` file:
```env
DATABASE_URL=mysql+pymysql://root:blueblacks2g@localhost:3306/citizen_service
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
```

### 3. Frontend Setup

```cmd
cd ..\frontend

REM Install dependencies
npm install

REM Start development server
npm run dev
```

## 🚀 Running the Application

### Start Backend Server

```cmd
cd backend
venv\Scripts\activate
python -m uvicorn app.main:app --reload
```

Backend will run on: **http://localhost:8000**
API Documentation: **http://localhost:8000/docs**

### Start Frontend Server

```cmd
cd frontend
npm run dev
```

Frontend will run on: **http://localhost:5173**

## 📱 Application Features

### Dashboard
- Total citizens, requests, grievances, and revenue statistics
- Pending actions and quick stats
- Recent service requests table
- Department performance metrics

### Citizens Module
- View all citizens in a card grid layout
- Add new citizens with complete information
- Edit existing citizen details
- Delete citizens (with confirmation)
- Search by name, email, or phone

### Services Module
- Browse all available services
- View services by type (Certificate, Utility, Grievance)
- See associated departments
- Add new services

### Service Requests Module
- Track all service requests
- Filter by status (All, Completed, Pending, Processing, Rejected)
- View request details including citizen, service, and payment info
- Status indicators with color-coded badges

### Grievances Module
- Submit new grievances
- Filter by status (Open, In Progress, Resolved)
- View detailed grievance descriptions
- Track resolution progress

### Departments Module
- View all government departments
- Department contact information
- Add new departments

## 🎨 UI/UX Features

- **Modern Design** - Clean, premium interface with smooth animations
- **Responsive** - Works on desktop, tablet, and mobile devices
- **Color-coded Status** - Visual indicators for different states
- **Search & Filter** - Quick access to information
- **Modal Forms** - Intuitive data entry
- **Loading States** - Smooth loading animations
- **Hover Effects** - Interactive elements with feedback

## 📊 API Endpoints

### Dashboard
- `GET /api/dashboard/stats` - Get dashboard statistics
- `GET /api/dashboard/recent-requests` - Get recent requests
- `GET /api/dashboard/department-performance` - Get department metrics
- `GET /api/dashboard/monthly-trends` - Get monthly trends

### Citizens
- `GET /api/citizens` - List all citizens
- `GET /api/citizens/{id}` - Get citizen details
- `POST /api/citizens` - Create new citizen
- `PUT /api/citizens/{id}` - Update citizen
- `DELETE /api/citizens/{id}` - Delete citizen

### Departments
- `GET /api/departments` - List all departments
- `POST /api/departments` - Create new department

### Services
- `GET /api/services` - List all services
- `POST /api/services` - Create new service

### Service Requests
- `GET /api/service-requests` - List all requests
- `POST /api/service-requests` - Create new request

### Grievances
- `GET /api/grievances` - List all grievances
- `POST /api/grievances` - Create new grievance

## 🔐 Security Features

- CORS protection
- SQL injection prevention via ORM
- Input validation with Pydantic
- Unique constraints on email and Aadhaar

## 🐛 Troubleshooting

### Database Connection Issues
- Verify MySQL is running
- Check DATABASE_URL in .env file
- Ensure database exists and has correct permissions

### Port Already in Use
- Backend: Change port in `app\main.py` (default: 8000)
- Frontend: Change port in `vite.config.js` (default: 5173)

### CORS Errors
- Ensure backend is running
- Check CORS_ORIGINS in .env includes frontend URL
- Clear browser cache

### Module Not Found
- Backend: Ensure virtual environment is activated and dependencies installed
- Frontend: Run `npm install` in frontend directory

## 📝 Future Enhancements

- User authentication and authorization
- Role-based access control
- Document upload for service requests
- Email notifications
- SMS alerts
- Payment gateway integration
- Advanced analytics and reports
- Export data to PDF/Excel
- Mobile app
- Multilingual support

## 👨‍💻 Development

### Build for Production

Frontend:
```cmd
cd frontend
npm run build
```

Backend:
```cmd
cd backend
pip install gunicorn
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker
```

## 📄 License

This project is for educational purposes.

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📧 Support


---




Department is trigger ready but trigger is not updated in triggers_and_procedures.sql