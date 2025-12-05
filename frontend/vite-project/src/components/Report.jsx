import { useState, useEffect } from "react";

export default function Report() {
    const [expenseByCategory, setExpenseByCategory] = useState([]);
    const [monthlyExpense, setMonthlyExpense] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    // Filters for Expense By Category
    const [categoryFilters, setCategoryFilters] = useState({
        userId: 1,
        minAmount: 0
    });

    // Filters for Monthly Expense
    const [monthFilters, setMonthFilters] = useState({
        userId: 1,
        month: new Date().getMonth() + 1,
        year: new Date().getFullYear()
    });

    const fetchExpenseByCategory = async () => {
        setLoading(true);
        setError(null);
        try {
            const query = new URLSearchParams(categoryFilters).toString();
            const res = await fetch(`http://127.0.0.1:5000/api/reports/expense-by-category?${query}`);
            const data = await res.json();
            if (res.ok) {
                setExpenseByCategory(data);
            } else {
                setError(data.error || "Failed to fetch expense by category");
            }
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    const fetchMonthlyExpense = async () => {
        setLoading(true);
        setError(null);
        try {
            const query = new URLSearchParams(monthFilters).toString();
            const res = await fetch(`http://127.0.0.1:5000/api/reports/monthly-expense?${query}`);
            const data = await res.json();
            if (res.ok) {
                setMonthlyExpense(data.totalExpense);
            } else {
                setError(data.error || "Failed to fetch monthly expense");
            }
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchExpenseByCategory();
    }, []);

    return (
        <div className="space-y-8">
            {error && (
                <div className="bg-red-900/50 border border-red-500 text-red-200 px-4 py-3 rounded relative" role="alert">
                    <span className="block sm:inline">{error}</span>
                </div>
            )}

            {/* Section 1: Expense By Category (Procedure 2.3) */}
            <div className="bg-slate-800 rounded-lg shadow-md p-6 border border-slate-700">
                <h2 className="text-xl font-semibold text-slate-100 mb-4">Thống kê chi tiêu theo danh mục</h2>
                <div className="flex flex-wrap gap-4 mb-4 items-end">
                    <div>
                        <label className="block text-xs text-slate-400 mb-1">User ID</label>
                        <input
                            type="number"
                            value={categoryFilters.userId}
                            onChange={(e) => setCategoryFilters({ ...categoryFilters, userId: e.target.value })}
                            className="px-3 py-2 bg-slate-700 border border-slate-600 rounded-md text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                        />
                    </div>
                    <div>
                        <label className="block text-xs text-slate-400 mb-1">Min Amount</label>
                        <input
                            type="number"
                            value={categoryFilters.minAmount}
                            onChange={(e) => setCategoryFilters({ ...categoryFilters, minAmount: e.target.value })}
                            className="px-3 py-2 bg-slate-700 border border-slate-600 rounded-md text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                        />
                    </div>
                    <button
                        onClick={fetchExpenseByCategory}
                        className="bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 transition-colors"
                    >
                        Xem báo cáo
                    </button>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead className="bg-slate-700/50">
                            <tr>
                                <th className="p-3 border-b border-slate-600 text-slate-300 font-medium">Danh mục</th>
                                <th className="p-3 border-b border-slate-600 text-slate-300 font-medium text-right">Tổng chi tiêu</th>
                            </tr>
                        </thead>
                        <tbody>
                            {expenseByCategory.length > 0 ? (
                                expenseByCategory.map((item, index) => (
                                    <tr key={index} className="hover:bg-slate-700/30">
                                        <td className="p-3 border-b border-slate-700 text-slate-200">{item.categoryName}</td>
                                        <td className="p-3 border-b border-slate-700 text-slate-200 text-right font-medium text-red-400">
                                            {parseFloat(item.totalExpense).toLocaleString('vi-VN')}
                                        </td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td colSpan="2" className="p-4 text-center text-slate-400">Không có dữ liệu</td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Section 2: Monthly Expense Calculation (Function 2.4) */}
            <div className="bg-slate-800 rounded-lg shadow-md p-6 border border-slate-700">
                <h2 className="text-xl font-semibold text-slate-100 mb-4">Tính tổng chi tiêu tháng (Hàm)</h2>
                <div className="flex flex-wrap gap-4 mb-4 items-end">
                    <div>
                        <label className="block text-xs text-slate-400 mb-1">User ID</label>
                        <input
                            type="number"
                            value={monthFilters.userId}
                            onChange={(e) => setMonthFilters({ ...monthFilters, userId: e.target.value })}
                            className="px-3 py-2 bg-slate-700 border border-slate-600 rounded-md text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                        />
                    </div>
                    <div>
                        <label className="block text-xs text-slate-400 mb-1">Tháng</label>
                        <input
                            type="number"
                            min="1" max="12"
                            value={monthFilters.month}
                            onChange={(e) => setMonthFilters({ ...monthFilters, month: e.target.value })}
                            className="px-3 py-2 bg-slate-700 border border-slate-600 rounded-md text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                        />
                    </div>
                    <div>
                        <label className="block text-xs text-slate-400 mb-1">Năm</label>
                        <input
                            type="number"
                            value={monthFilters.year}
                            onChange={(e) => setMonthFilters({ ...monthFilters, year: e.target.value })}
                            className="px-3 py-2 bg-slate-700 border border-slate-600 rounded-md text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                        />
                    </div>
                    <button
                        onClick={fetchMonthlyExpense}
                        className="bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700 transition-colors"
                    >
                        Tính toán
                    </button>
                </div>

                <div className="p-4 bg-slate-700/50 rounded-md text-center">
                    <p className="text-slate-300 mb-1">Tổng chi tiêu tháng {monthFilters.month}/{monthFilters.year}</p>
                    <p className="text-3xl font-bold text-slate-100">
                        {monthlyExpense !== null ? parseFloat(monthlyExpense).toLocaleString('vi-VN') : '---'}
                    </p>
                </div>
            </div>
        </div>
    );
}
