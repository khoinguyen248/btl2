export default function TransactionList({ transactions, filters, onFilterChange, onEdit, onDelete }) {

  const handleChange = (e) => {
    const { name, value } = e.target;
    onFilterChange({ ...filters, [name]: value });
  };

  return (
    <div className="list-box">
      <h2>Danh sách giao dịch</h2>

      <div className="filters">
        <input name="walletId" placeholder="Wallet ID"
               value={filters.walletId || ""} onChange={handleChange} />

        <input type="date" name="fromDate"
               value={filters.fromDate || ""} onChange={handleChange} />

        <input type="date" name="toDate"
               value={filters.toDate || ""} onChange={handleChange} />
      </div>

      <table>
        <thead>
          <tr>
            <th>ID</th><th>Ngày</th><th>Loại</th><th>Số tiền</th>
            <th>Ví</th><th>Danh mục</th><th>Mô tả</th><th></th><th></th>
          </tr>
        </thead>

        <tbody>
          {transactions.map(t => (
            <tr key={t.transactionID}>
              <td>{t.transactionID}</td>
              <td>{t.transactionDate?.slice(0, 10)}</td>
              <td>{t.type}</td>
              <td>{t.amount}</td>
              <td>{t.walletName}</td>
              <td>{t.categoryName}</td>
              <td>{t.description}</td>

              <td><button onClick={() => onEdit(t)}>Sửa</button></td>
              <td><button onClick={() => onDelete(t.transactionID)}>Xóa</button></td>
            </tr>
          ))}

          {transactions.length === 0 &&
            <tr><td colSpan="9">Không có dữ liệu</td></tr>
          }
        </tbody>
      </table>
    </div>
  );
}
