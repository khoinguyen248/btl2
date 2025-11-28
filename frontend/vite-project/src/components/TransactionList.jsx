export default function TransactionList({ transactions, filters, onFilterChange, onEdit, onDelete }) {

  const handleChange = (e) => {
    const { name, value } = e.target;
    onFilterChange({ ...filters, [name]: value });
  };

  return (
    <div className="bg-slate-800 rounded-lg shadow-md p-6 border border-slate-700">
      <h2 className="text-xl font-semibold text-slate-100 mb-4">Danh sách giao dịch</h2>

      <div className="flex flex-wrap gap-4 mb-6">
        <input
          name="walletId"
          placeholder="Wallet ID"
          value={filters.walletId || ""}
          onChange={handleChange}
          className="px-3 py-2 bg-slate-700 border border-slate-600 rounded-md text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent placeholder-slate-400"
        />

        <input
          type="date"
          name="fromDate"
          value={filters.fromDate || ""}
          onChange={handleChange}
          className="px-3 py-2 bg-slate-700 border border-slate-600 rounded-md text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent placeholder-slate-400"
        />

        <input
          type="date"
          name="toDate"
          value={filters.toDate || ""}
          onChange={handleChange}
          className="px-3 py-2 bg-slate-700 border border-slate-600 rounded-md text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent placeholder-slate-400"
        />
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead className="bg-slate-700/50">
            <tr>
              <th className="p-3 border-b border-slate-600 text-slate-300 font-medium whitespace-nowrap">ID</th>
              <th className="p-3 border-b border-slate-600 text-slate-300 font-medium whitespace-nowrap">Ngày</th>
              <th className="p-3 border-b border-slate-600 text-slate-300 font-medium whitespace-nowrap">Loại</th>
              <th className="p-3 border-b border-slate-600 text-slate-300 font-medium whitespace-nowrap">Số tiền</th>
              <th className="p-3 border-b border-slate-600 text-slate-300 font-medium whitespace-nowrap">Ví</th>
              <th className="p-3 border-b border-slate-600 text-slate-300 font-medium whitespace-nowrap">Danh mục</th>
              <th className="p-3 border-b border-slate-600 text-slate-300 font-medium whitespace-nowrap">Mô tả</th>
              <th className="p-3 border-b border-slate-600 text-slate-300 font-medium whitespace-nowrap"></th>
              <th className="p-3 border-b border-slate-600 text-slate-300 font-medium whitespace-nowrap"></th>
            </tr>
          </thead>

          <tbody>
            {transactions.map(t => (
              <tr key={t.transactionID} className="hover:bg-slate-700/30 transition-colors">
                <td className="p-3 border-b border-slate-700 text-slate-200">{t.transactionID}</td>
                <td className="p-3 border-b border-slate-700 text-slate-200">{t.transactionDate?.slice(0, 10)}</td>
                <td className="p-3 border-b border-slate-700 text-slate-200">
                  <span className={`px-2 py-1 rounded text-xs font-medium ${t.type === 'income' ? 'bg-green-900/50 text-green-300' :
                      t.type === 'expense' ? 'bg-red-900/50 text-red-300' :
                        'bg-blue-900/50 text-blue-300'
                    }`}>
                    {t.type}
                  </span>
                </td>
                <td className="p-3 border-b border-slate-700 text-slate-200 font-medium">{t.amount}</td>
                <td className="p-3 border-b border-slate-700 text-slate-200">{t.walletName}</td>
                <td className="p-3 border-b border-slate-700 text-slate-200">{t.categoryName}</td>
                <td className="p-3 border-b border-slate-700 text-slate-200">{t.description}</td>

                <td className="p-3 border-b border-slate-700">
                  <button
                    onClick={() => onEdit(t)}
                    className="text-indigo-400 hover:text-indigo-300 font-medium transition-colors"
                  >
                    Sửa
                  </button>
                </td>
                <td className="p-3 border-b border-slate-700">
                  <button
                    onClick={() => onDelete(t.transactionID)}
                    className="text-red-400 hover:text-red-300 font-medium transition-colors"
                  >
                    Xóa
                  </button>
                </td>
              </tr>
            ))}

            {transactions.length === 0 &&
              <tr>
                <td colSpan="9" className="p-6 text-center text-slate-400 border-b border-slate-700">
                  Không có dữ liệu
                </td>
              </tr>
            }
          </tbody>
        </table>
      </div>
    </div>
  );
}
