import { useEffect, useState } from "react";
import { getFarmerEarnings } from "../services/api";

function FarmerEarnings() {
  const [data, setData] = useState({
    totalEarnings: 0,
    transactions: [],
  });

  useEffect(() => {
    loadEarnings();
  }, []);

  async function loadEarnings() {
    try {
      const result = await getFarmerEarnings();
      if (result) {
        setData({
          totalEarnings: result.totalEarnings || 0,
          transactions: result.transactions || [],
        });
      }
    } catch (error) {
      console.error(error);
    }
  }

  return (
    <div className="earnings-page" style={{ padding: "20px", maxWidth: "800px", margin: "0 auto" }}>
      <h1>💰 Farmer Earnings</h1>

      <div
        className="earnings-summary"
        style={{
          background: "#e8f5e9",
          padding: "20px",
          borderRadius: "8px",
          marginBottom: "20px",
          border: "1px solid #c8e6c9",
        }}
      >
        <h2 style={{ margin: "0 0 8px 0", color: "#2e7d32" }}>₹{data.totalEarnings}</h2>
        <p style={{ margin: 0, color: "#555" }}>Total Earnings</p>
      </div>

      <h2>Transactions</h2>

      {data.transactions.length === 0 ? (
        <p>No transactions yet.</p>
      ) : (
        data.transactions.map((transaction) => (
          <div
            className="transaction-card"
            key={transaction._id}
            style={{
              border: "1px solid #ddd",
              borderRadius: "8px",
              padding: "15px",
              marginBottom: "12px",
              background: "#fafafa",
            }}
          >
            <p>💰 ₹{transaction.amount}</p>
            <p>Status: {transaction.status}</p>
            <p>Date: {new Date(transaction.createdAt).toLocaleString()}</p>
          </div>
        ))
      )}
    </div>
  );
}

export default FarmerEarnings;
