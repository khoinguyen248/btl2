import { useEffect, useState } from "react";
import {
  getTransactions,
  createTransaction,
  updateTransaction,
  deleteTransaction,
} from "./api";

import TransactionForm from "./components/TransactionForm";
import TransactionList from "./components/TransactionList";

export default function App() {

  const [transactions, setTransactions] = useState([]);
  const [filters, setFilters] = useState({});
  const [editing, setEditing] = useState(null);
  const [message, setMessage] = useState("");

  const loadTransactions = async (f = filters) => {
    try {
      const data = await getTransactions(f);
      console.log("API trả về:", data);

      if (Array.isArray(data)) {
        setTransactions(data);
      } else {
        // nếu backend trả error object
        setTransactions([]);
        setMessage("Lỗi backend: " + (data.error || "Không phải mảng"));
      }
    } catch (err) {
      setMessage("Lỗi tải dữ liệu: " + err.message);
    }
  };


  useEffect(() => {
    loadTransactions();
  }, []);

  const handleFilter = (f) => {
    setFilters(f);
    loadTransactions(f);
  };

  const handleSubmit = async (payload) => {
    try {
      if (editing) {
        await updateTransaction(editing.transactionID, payload);
        setMessage("Cập nhật thành công!");
      } else {
        await createTransaction(payload);
        setMessage("Thêm thành công!");
      }
      setEditing(null);
      loadTransactions();
    } catch (e) {
      setMessage("Lỗi: " + e.response?.data?.error || e.message);
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Xóa?")) return;

    try {
      await deleteTransaction(id);
      loadTransactions();
    } catch (e) {
      setMessage("Lỗi xóa: " + e.response?.data?.error || e.message);
    }
  };

  return (
    <div className="min-h-screen bg-slate-900 py-8 text-slate-100">
      <div className="container mx-auto px-4 max-w-6xl">
        <h1 className="text-3xl font-bold text-center text-slate-100 mb-8">
          Quản lý giao dịch | React + Flask + SQL Server
        </h1>

        {message && (
          <div className={`mb-6 p-4 rounded-lg border ${message.includes("Lỗi")
              ? "bg-red-900/20 text-red-200 border-red-800"
              : "bg-green-900/20 text-green-200 border-green-800"
            }`}>
            {message}
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-1">
            <TransactionForm
              editing={editing}
              onSubmit={handleSubmit}
              onCancel={() => setEditing(null)}
            />
          </div>

          <div className="lg:col-span-2">
            <TransactionList
              transactions={transactions}
              filters={filters}
              onFilterChange={handleFilter}
              onEdit={(t) => setEditing(t)}
              onDelete={handleDelete}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
