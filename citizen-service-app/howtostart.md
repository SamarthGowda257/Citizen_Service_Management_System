# Quick Start Guide

## Windows Setup

### 1. Setup Database

```cmd
REM Start MySQL
mysql -u root -p

REM In MySQL prompt:
CREATE DATABASE citizen_service;
USE citizen_service;
EXIT;
```

### 2. Setup Backend

```cmd
cd C:\Users\ccls6\Desktop\DBMS\citizen-service-app\backend

REM Create virtual environment
python -m venv venv

REM Activate it
venv\Scripts\activate

REM Install packages
pip install -r requirements.txt

REM Create .env file
copy .env.example .env

REM Edit .env - Replace 'password' with your MySQL root password
notepad .env
```

**Update `.env`:**
```
DATABASE_URL=mysql+pymysql://root:blueblacks2g@localhost:3306/citizen_service
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
```

### 3. Setup Frontend

Open a **NEW** Command Prompt:

```cmd
cd C:\Users\ccls6\Desktop\DBMS\citizen-service-app\frontend

REM Install dependencies
npm install

REM Create .env file (optional)
copy .env.example .env
```

### 4. Run Application

**Terminal 1 - Backend:**
```cmd
cd C:\Users\ccls6\Desktop\DBMS\citizen-service-app\backend
venv\Scripts\activate
python3 -m uvicorn app.main:app --reload
```

**Terminal 2 - Frontend:**
```cmd
cd C:\Users\ccls6\Desktop\DBMS\citizen-service-app\frontend
npm run dev
```

### 5. Access Application

- **Frontend:** http://localhost:5173
- **Backend API:** http://localhost:8000
- **API Docs:** http://localhost:8000/docs

## Default Login

No authentication required - system is open for testing.

## Test the Application

1. Open http://localhost:5173
2. View Dashboard with statistics
3. Navigate to Citizens and add a new citizen
4. Check Services available
5. Create a service request
6. Submit a grievance

## Stopping the Application

Press `Ctrl + C` in both terminal windows.

## Common Issues

### Port Already in Use
```cmd
REM Check what's using port 8000
netstat -ano | findstr :8000

REM Kill process (replace PID with actual process ID)
taskkill /PID <PID> /F
```

### Database Connection Error
- Ensure MySQL is running
- Check username/password in .env file
- Verify database exists: `SHOW DATABASES;`

### Module Not Found (Python)
```cmd
REM Make sure venv is activated
venv\Scripts\activate

REM Reinstall packages
pip install -r requirements.txt
```

### Module Not Found (Node)
```cmd
REM Delete node_modules and reinstall
rmdir /s /q node_modules
npm install
```

