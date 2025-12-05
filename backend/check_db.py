import mysql.connector

conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='',
    database='EERD_Project'
)

cursor = conn.cursor()

# Count total transactions
cursor.execute('SELECT COUNT(*) FROM Transaction')
total = cursor.fetchone()[0]
print(f'Total transactions in database: {total}')

# Get all transactions
cursor.execute('''
    SELECT t.transactionID, t.amount, t.type, t.transactionDate, 
           c.categoryName, t.sourceWalletID, t.destinationWalletID
    FROM Transaction t 
    LEFT JOIN Category c ON t.categoryID = c.categoryID 
    ORDER BY t.transactionID
''')

print('\nAll transactions:')
print('-' * 80)
for row in cursor.fetchall():
    print(f'ID {row[0]:2d} | {row[2]:8s} | {row[1]:12,.0f} | {row[3]} | {row[4]} | Src:{row[5]} Dst:{row[6]}')

# Check wallets
cursor.execute('SELECT walletID, userID, walletName, balance FROM Wallet ORDER BY walletID')
print('\n\nWallet balances:')
print('-' * 60)
for row in cursor.fetchall():
    print(f'Wallet {row[0]:2d} | User {row[1]} | {row[2]:20s} | {row[3]:12,.0f}')

conn.close()
