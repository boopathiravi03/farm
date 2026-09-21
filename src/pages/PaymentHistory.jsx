import { useEffect, useState } from "react";
import { getMyPayments } from "../services/api";

function PaymentHistory() {
  const [payments, setPayments] = useState([]);

  useEffect(() => {
    loadPayments();
  }, []);

  async function loadPayments() {
    try {
      const data = await getMyPayments();
      if (Array.isArray(data)) {
        setPayments(data);
      }
    } catch (error) {
      console.error(error);
    }
  }

  return (
    <div className="payment-history" style={{ padding: "20px", maxWidth: "800px", margin: "0 auto" }}>
      <h1>💳 Payment History</h1>

      {payments.length === 0 ? (
        <p>No payments found.</p>
      ) : (
        payments.map((payment) => (
          <div
            className="payment-card"
            key={payment._id}
            style={{
              border: "1px solid #ddd",
              borderRadius: "8px",
              padding: "15px",
              marginBottom: "12px",
              background: "#fafafa",
            }}
          >
            <h3>Transaction: {payment.transactionId}</h3>
            <p>Amount: ₹{payment.amount}</p>
            <p>Method: {payment.paymentMethod}</p>
            <p>Status: {payment.status}</p>
            <p>Date: {new Date(payment.createdAt).toLocaleString()}</p>
          </div>
        ))
      )}
    </div>
  );
}

export default PaymentHistory;
