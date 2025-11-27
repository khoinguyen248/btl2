from flask import Flask, request, jsonify
from flask_cors import CORS
from db import get_connection
import pyodbc

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
        cursor.execute(
            "{CALL sp_InsertTransaction(?,?,?,?,?,?)}",
            data["amount"],
            data.get("description"),
            data["type"],
            data.get("sourceWalletID"),
            data.get("destinationWalletID"),
            data["categoryID"]
        )
        conn.commit()
        # Testcase 2: 201 + message
        return jsonify({"message": "Thêm giao dịch thành công"}), 201
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
        cursor.execute(
            "{CALL sp_UpdateTransaction(?,?,?,?)}",
            tid,
            data["amount"],
            data["description"],
            data["categoryID"]
        )
        conn.commit()
        # Testcase 3
        return jsonify({"message": "Cập nhật giao dịch thành công"}), 200
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
        cursor.execute("{CALL sp_DeleteTransaction(?)}", tid)
        conn.commit()
        # Testcase 4
        return jsonify({"message": "Xóa giao dịch thành công"}), 200
    except Exception as e:
        if conn:
            conn.rollback()
        # nếu sp báo lỗi ID không tồn tại -> trả error
        return jsonify({"error": str(e)}), 400
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# ----------- API: LIST (PROC2 - PROC của bạn) ----------
@app.route("/api/transactions", methods=["GET"])
def list_transactions():
    # lấy raw string
    wallet_id_raw = request.args.get("walletId", default=None, type=str)
    from_date = request.args.get("fromDate", default=None, type=str)
    to_date = request.args.get("toDate", default=None, type=str)

    # convert walletId -> int hoặc None (fix lỗi nvarchar -> int)
    wallet_id = None
    if wallet_id_raw not in (None, "", "null"):
        try:
            wallet_id = int(wallet_id_raw)
        except ValueError:
            return jsonify({"error": "walletId phải là số nguyên"}), 400

    if from_date in ("", "null"):
        from_date = None
    if to_date in ("", "null"):
        to_date = None

    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(
            "{CALL sp_GetTransactionsByWalletAndDate(?,?,?)}",
            wallet_id,
            from_date,
            to_date
        )
        rows = rows_to_dicts(cursor)
        # Testcase 1, 5, 7, 8, 9: luôn trả về array
        return jsonify(rows), 200
    except Exception as e:
        print("ERROR list_transactions:", e)
        # Cho Postman thấy lỗi, nhưng React sẽ xử lý thêm
        return jsonify({"error": str(e)}), 400
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

if __name__ == "__main__":
    app.run(debug=True)
