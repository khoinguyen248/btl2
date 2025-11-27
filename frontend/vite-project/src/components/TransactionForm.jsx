
import { useState, useEffect } from "react";

export default function TransactionForm({ onSubmit, editing, onCancel }) {

  const defaultForm = {
    amount: "",
    description: "",
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
        type: editing.type,
        sourceWalletID: editing.sourceWalletID || "",
        destinationWalletID: editing.destinationWalletID || "",
        categoryID: editing.categoryID || "",
      });
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
    setForm(defaultForm);
  };

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-xl font-semibold text-gray-800 mb-4">
        {editing ? "Cập nhật giao dịch" : "Thêm giao dịch mới"}
      </h2>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Số tiền</label>
          <input 
            name="amount" 
            type="number" 
            value={form.amount} 
            onChange={handleChange} 
            required 
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Mô tả</label>
          <input 
            name="description" 
            value={form.description} 
            onChange={handleChange} 
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Loại giao dịch</label>
          <select 
            name="type" 
            value={form.type} 
            onChange={handleChange}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="income">Income</option>
            <option value="expense">Expense</option>
            <option value="transfer">Transfer</option>
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Source Wallet ID</label>
          <input 
            name="sourceWalletID" 
            value={form.sourceWalletID} 
            onChange={handleChange} 
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Destination Wallet ID</label>
          <input 
            name="destinationWalletID" 
            value={form.destinationWalletID} 
            onChange={handleChange} 
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Category ID</label>
          <input 
            name="categoryID" 
            value={form.categoryID} 
            onChange={handleChange} 
            required 
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        <div className="flex space-x-2 pt-2">
          <button 
            type="submit" 
            className="flex-1 bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition duration-200"
          >
            {editing ? "Lưu" : "Thêm"}
          </button>
          {editing && (
            <button 
              type="button" 
              onClick={onCancel}
              className="flex-1 bg-gray-500 text-white py-2 px-4 rounded-md hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition duration-200"
            >
              Hủy
            </button>
          )}
        </div>
      </form>
    </div>
  );
}
