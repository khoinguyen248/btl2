
import { useState, useEffect } from "react";

export default function TransactionForm({ onSubmit, editing, onCancel }) {

  const defaultForm = {
    amount: "",
    description: "",
    transactionDate: new Date().toISOString().slice(0, 19).replace('T', ' '),
    type: "expense",
    sourceWalletID: "",
    destinationWalletID: "",
    categoryID: "",
  };

  const [form, setForm] = useState(defaultForm);

  useEffect(() => {
    if (editing) {
      setForm({
        amount: editing.amount,
        description: editing.description,
        transactionDate: editing.transactionDate ? new Date(editing.transactionDate).toISOString().slice(0, 19).replace('T', ' ') : "",
        type: editing.type,
        sourceWalletID: editing.sourceWalletID || "",
        destinationWalletID: editing.destinationWalletID || "",
        categoryID: editing.categoryID || "",
      });
    } else {
      setForm(defaultForm);
    }
  }, [editing]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    const payload = {
      ...form,
      amount: parseFloat(form.amount),
      sourceWalletID: form.sourceWalletID ? parseInt(form.sourceWalletID) : null,
      destinationWalletID: form.destinationWalletID ? parseInt(form.destinationWalletID) : null,
      categoryID: parseInt(form.categoryID),
    };

    onSubmit(payload);
    if (!editing) {
      setForm(defaultForm);
    }
  };

  return (
    <div className="bg-slate-800 rounded-lg shadow-md p-6 border border-slate-700">
      <h2 className="text-xl font-semibold text-slate-100 mb-4">
        {editing ? "Cập nhật giao dịch" : "Thêm giao dịch mới"}
      </h2>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">Số tiền</label>
            <input
              name="amount"
              type="number"
              value={form.amount}
              onChange={handleChange}
              required
              className="w-full px-3 py-2 bg-slate-700 border border-slate-600 rounded-md text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent placeholder-slate-400"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">Ngày giao dịch</label>
            <input
              name="transactionDate"
              type="datetime-local"
              step="1"
              value={form.transactionDate.replace(' ', 'T')}
              onChange={(e) => handleChange({ target: { name: 'transactionDate', value: e.target.value.replace('T', ' ') } })}
              required
              className="w-full px-3 py-2 bg-slate-700 border border-slate-600 rounded-md text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent placeholder-slate-400"
            />
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-slate-300 mb-1">Mô tả</label>
          <input
            name="description"
            value={form.description}
            onChange={handleChange}
            className="w-full px-3 py-2 bg-slate-700 border border-slate-600 rounded-md text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent placeholder-slate-400"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-slate-300 mb-1">Loại giao dịch</label>
          <select
            name="type"
            value={form.type}
            onChange={handleChange}
            className="w-full px-3 py-2 bg-slate-700 border border-slate-600 rounded-md text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
          >
            <option value="income">Income</option>
            <option value="expense">Expense</option>
            <option value="transfer">Transfer</option>
          </select>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">Source Wallet ID</label>
            <input
              name="sourceWalletID"
              value={form.sourceWalletID}
              onChange={handleChange}
              className="w-full px-3 py-2 bg-slate-700 border border-slate-600 rounded-md text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent placeholder-slate-400"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">Dest Wallet ID</label>
            <input
              name="destinationWalletID"
              value={form.destinationWalletID}
              onChange={handleChange}
              className="w-full px-3 py-2 bg-slate-700 border border-slate-600 rounded-md text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent placeholder-slate-400"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">Category ID</label>
            <input
              name="categoryID"
              value={form.categoryID}
              onChange={handleChange}
              required
              className="w-full px-3 py-2 bg-slate-700 border border-slate-600 rounded-md text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent placeholder-slate-400"
            />
          </div>
        </div>

        <div className="flex space-x-2 pt-2">
          <button
            type="submit"
            className="flex-1 bg-indigo-600 text-white py-2 px-4 rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 transition duration-200"
          >
            {editing ? "Lưu" : "Thêm"}
          </button>
          {editing && (
            <button
              type="button"
              onClick={onCancel}
              className="flex-1 bg-slate-600 text-white py-2 px-4 rounded-md hover:bg-slate-500 focus:outline-none focus:ring-2 focus:ring-slate-500 focus:ring-offset-2 transition duration-200"
            >
              Hủy
            </button>
          )}
        </div>
      </form>
    </div>
  );
}
