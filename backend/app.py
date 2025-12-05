from flask import Flask, request, jsonify
from flask_cors import CORS
from db import get_connection
import mysql.connector

app = Flask(__name__)
CORS(app)

# Convert cursor thành list dict
def rows_to_dicts(cursor):
    cols = [column[0] for column in cursor.description]
    return [dict(zip(cols, row)) for row in cursor.fetchall()]

# ----------- API: CREATE TRANSACTION (PROC Insert) -----------
@app.route("/api/transactions", methods=["POST"])
def create_transaction():
    data = request.get_json() or {}

    # Testcase 6: thiếu field -> trả về error rõ ràng
    required = ["amount", "type", "categoryID"]
    missing = [f for f in required if f not in data]
    if missing:
        return jsonify({"error": f"Missing fields: {', '.join(missing)}"}), 400

    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        # Call MySQL Procedure
        cursor.callproc('sp_InsertTransaction', [
            data["amount"],
            data.get("description"),
            data.get("transactionDate"), # Expecting 'YYYY-MM-DD HH:MM:SS'
            data["type"],
            data.get("status", "Completed"),
            data.get("sourceWalletID"),
            data.get("destinationWalletID"),
            data["categoryID"]
        ])
        conn.commit()
        # Testcase 2: 201 + message
        return jsonify({"message": "Thêm giao dịch thành công"}), 201
    except mysql.connector.Error as err:
        if conn:
            conn.rollback()
        # Return specific error message from trigger/procedure
        return jsonify({"error": str(err)}), 400
    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"error": str(e)}), 400
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# ----------- API: UPDATE TRANSACTION ----------
@app.route("/api/transactions/<int:tid>", methods=["PUT"])
def update_transaction(tid):
    data = request.get_json() or {}
    required = ["amount", "description", "categoryID"]
    missing = [f for f in required if f not in data]
    if missing:
        return jsonify({"error": f"Missing fields: {', '.join(missing)}"}), 400

    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.callproc('sp_UpdateTransaction', [
            tid,
            data["amount"],
            data["description"],
            data.get("transactionDate"),
            data.get("type"),
            data.get("status", "Completed"),
            data.get("sourceWalletID"),
            data.get("destinationWalletID"),
            data["categoryID"]
        ])
        conn.commit()
        # Testcase 3
        return jsonify({"message": "Cập nhật giao dịch thành công"}), 200
    except mysql.connector.Error as err:
        if conn:
            conn.rollback()
        return jsonify({"error": str(err)}), 400
    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"error": str(e)}), 400
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# ----------- API: DELETE TRANSACTION ----------
@app.route("/api/transactions/<int:tid>", methods=["DELETE"])
def delete_transaction(tid):
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.callproc('sp_DeleteTransaction', [tid])
        conn.commit()
        # Testcase 4
        return jsonify({"message": "Xóa giao dịch thành công"}), 200
    except mysql.connector.Error as err:
        if conn:
            conn.rollback()
        return jsonify({"error": str(err)}), 400
    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"error": str(e)}), 400
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# ----------- API: LIST (PROC2 - sp_GetTransactionsByUser) ----------
@app.route("/api/transactions", methods=["GET"])
def list_transactions():
    user_id = request.args.get("userId", default=1, type=int)
    start_date = request.args.get("startDate", default="", type=str)
    end_date = request.args.get("endDate", default="", type=str)

    # Handle empty strings - use default date range
    if not start_date or start_date == "":
        start_date = "2024-01-01"
    if not end_date or end_date == "":
        end_date = "2025-12-31"

    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # In MySQL connector, callproc returns the args. 
        # To get results, we must iterate stored_results()
        cursor.callproc('sp_GetTransactionsByUser', [user_id, start_date, end_date])
        
        results = []
        for result in cursor.stored_results():
            results = rows_to_dicts(result)
            break # We expect only one result set

        return jsonify(results), 200
    except Exception as e:
        print("ERROR list_transactions:", e)
        return jsonify({"error": str(e)}), 400
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# ----------- API: REPORT - EXPENSE BY CATEGORY (sp_SummaryExpenseByCategory) ----------
@app.route("/api/reports/expense-by-category", methods=["GET"])
def report_expense_by_category():
    user_id = request.args.get("userId", default=1, type=int)
    min_amount = request.args.get("minAmount", default=0, type=float)

    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        cursor.callproc('sp_SummaryExpenseByCategory', [user_id, min_amount])
        
        results = []
        for result in cursor.stored_results():
            results = rows_to_dicts(result)
            break

        return jsonify(results), 200
    except Exception as e:
        print("ERROR report_expense_by_category:", e)
        return jsonify({"error": str(e)}), 400
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# ----------- API: REPORT - MONTHLY EXPENSE (fn_UserMonthlyExpense) ----------
@app.route("/api/reports/monthly-expense", methods=["GET"])
def report_monthly_expense():
    user_id = request.args.get("userId", default=1, type=int)
    month = request.args.get("month", default=1, type=int)
    year = request.args.get("year", default=2025, type=int)

    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # Call function: SELECT fn_UserMonthlyExpense(?, ?, ?)
        query = "SELECT fn_UserMonthlyExpense(%s, %s, %s) AS totalExpense"
        cursor.execute(query, (user_id, month, year))
        
        result = rows_to_dicts(cursor)
        return jsonify(result[0] if result else {"totalExpense": 0}), 200
    except Exception as e:
        print("ERROR report_monthly_expense:", e)
        return jsonify({"error": str(e)}), 400
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

if __name__ == "__main__":
    app.run(debug=True)
