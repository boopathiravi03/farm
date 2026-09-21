import { useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { makePayment } from "../services/api";

function PaymentPage() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const orderId = searchParams.get("orderId");
  const [paymentMethod, setPaymentMethod] = useState("UPI");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");

  async function handlePayment() {
    if (!orderId) {
      setMessage("Order ID is missing");
      return;
    }

    try {
      setLoading(true);

      const result = await makePayment(orderId, paymentMethod);

      if (result.message === "Payment successful") {
        setMessage("Payment successful! 🎉");

        setTimeout(() => {
          navigate("/my-orders");
        }, 1500);
      } else {
        setMessage(result.message || "Payment failed");
      }
    } catch (error) {
      setMessage("Payment failed");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="payment-page">
      <div className="payment-card">
        <h1>💳 Farm Trading Payment</h1>
        <p>Complete your payment securely.</p>

        <div className="payment-methods">
          <label>
            <input
              type="radio"
              value="UPI"
              checked={paymentMethod === "UPI"}
              onChange={(e) => setPaymentMethod(e.target.value)}
            />
            UPI
          </label>

          <label>
            <input
              type="radio"
              value="CARD"
              checked={paymentMethod === "CARD"}
              onChange={(e) => setPaymentMethod(e.target.value)}
            />
            Credit / Debit Card
          </label>

          <label>
            <input
              type="radio"
              value="NET_BANKING"
              checked={paymentMethod === "NET_BANKING"}
              onChange={(e) => setPaymentMethod(e.target.value)}
            />
            Net Banking
          </label>

          <label>
            <input
              type="radio"
              value="COD"
              checked={paymentMethod === "COD"}
              onChange={(e) => setPaymentMethod(e.target.value)}
            />
            Cash on Delivery
          </label>
        </div>

        <button onClick={handlePayment} disabled={loading}>
          {loading ? "Processing..." : "Pay Now 💳"}
        </button>

        {message && <p className="payment-message">{message}</p>}
      </div>
    </div>
  );
}

export default PaymentPage;
