---
description: Start the MoneyLover application (Database, Backend, Frontend)
---

# Start MoneyLover Application

This workflow will help you start the database, backend, and frontend services.

## 1. Database Setup
Ensure your MySQL service is running (e.g., via XAMPP or Service Manager).
If you haven't set up the database yet, run the following commands to import the schema and data.
**Note**: You may need to adjust the `mysql` command with your specific credentials (e.g., `-u root -p`).

```bash
cd database
# Windows PowerShell:
# cmd /c "mysql -u root -p < CodeDatabase2.sql"
# cmd /c "mysql -u root -p < dlmBTL2.sql"

# Git Bash / Linux / Mac:
# mysql -u root -p < CodeDatabase2.sql
# mysql -u root -p < dlmBTL2.sql
```

## 2. Backend Setup
Navigate to the backend directory, install dependencies, and start the Flask server.

```bash
cd backend
// turbo
pip install mysql-connector-python python-dotenv flask-cors
python app.py
```

## 3. Frontend Setup
Open a new terminal, navigate to the frontend directory, install dependencies, and start the Vite server.

```bash
cd frontend/vite-project
// turbo
npm install
npm run dev
```
