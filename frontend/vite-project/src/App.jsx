import { useState, useEffect } from "react";
import TransactionList from "./components/TransactionList";
import TransactionForm from "./components/TransactionForm";
import Report from "./components/Report";

function App() {
  const [view, setView] = useState("transactions"); // 'transactions' | 'reports'
  const [transactions, setTransactions] = useState([]);
  const [editing, setEditing] = useState(null);
  const [filters, setFilters] = useState({
    userId: 1,
    startDate: "",
    endDate: ""
  });
  const [error, setError] = useState(null);

  const fetchTransactions = async () => {
    try {
      const query = new URLSearchParams(filters).toString();
      const res = await fetch(`http://127.0.0.1:5000/api/transactions?${query}`);
      const data = await res.json();
      if (res.ok) {
        setTransactions(data);
        setError(null);
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError("Failed to connect to server");
    }
  };

  useEffect(() => {
    if (view === "transactions") {
      fetchTransactions();
    }
  }, [filters, view]);

  const handleCreate = async (payload) => {
    try {
      const res = await fetch("http://127.0.0.1:5000/api/transactions", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
      const data = await res.json();
      if (res.ok) {
        fetchTransactions();
        setError(null);
        alert(data.message);
      } else {
        setError(data.error);
        alert(`Lỗi: ${data.error}`);
      }
    } catch (err) {
      setError(err.message);
    }
  };

  const handleUpdate = async (payload) => {
    if (!editing) return;
    try {
      const res = await fetch(`http://127.0.0.1:5000/api/transactions/${editing.transactionID}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
      const data = await res.json();
      if (res.ok) {
        setEditing(null);
        fetchTransactions();
        setError(null);
        alert(data.message);
      } else {
        setError(data.error);
        alert(`Lỗi: ${data.error}`);
      }
    } catch (err) {
      setError(err.message);
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Bạn có chắc chắn muốn xóa?")) return;
    try {
      const res = await fetch(`http://127.0.0.1:5000/api/transactions/${id}`, {
        method: "DELETE",
      });
      const data = await res.json();
      if (res.ok) {
        fetchTransactions();
        setError(null);
        alert(data.message);
      } else {
        setError(data.error);
        alert(`Lỗi: ${data.error}`);
      }
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 p-8 font-sans">
      <div className="max-w-6xl mx-auto space-y-8">
        <header className="flex justify-between items-center border-b border-slate-700 pb-6">
          <h1 className="text-3xl font-bold bg-gradient-to-r from-indigo-400 to-cyan-400 bg-clip-text text-transparent">
            MoneyLover BTL2
          </h1>
          <nav className="flex space-x-4">
            <button
              onClick={() => setView("transactions")}
              className={`px-4 py-2 rounded-md transition-colors ${view === "transactions" ? "bg-indigo-600 text-white" : "text-slate-400 hover:text-slate-200"}`}
            >
              Giao dịch
            </button>
            <button
              onClick={() => setView("reports")}
              className={`px-4 py-2 rounded-md transition-colors ${view === "reports" ? "bg-indigo-600 text-white" : "text-slate-400 hover:text-slate-200"}`}
            >
              Báo cáo
            </button>
          </nav>
        </header>

        {error && (
          <div className="bg-red-900/50 border border-red-500 text-red-200 px-4 py-3 rounded relative" role="alert">
            <span className="block sm:inline">{error}</span>
          </div>
        )}

        {view === "transactions" ? (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div className="lg:col-span-1">
              <TransactionForm
                onSubmit={editing ? handleUpdate : handleCreate}
                editing={editing}
                onCancel={() => setEditing(null)}
              />
            </div>
            <div className="lg:col-span-2">
              <TransactionList
                transactions={transactions}
                filters={filters}
                onFilterChange={setFilters}
                onEdit={setEditing}
                onDelete={handleDelete}
              />
            </div>
          </div>
        ) : (
          <Report />
        )}
      </div>
    </div>
  );
}

export default App;
