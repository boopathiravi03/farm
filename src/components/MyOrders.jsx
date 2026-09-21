import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { getMyOrders } from "../services/api";

function MyOrders() {
  const navigate = useNavigate();
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadOrders();
  }, []);

  const loadOrders = async () => {
    try {
      const data = await getMyOrders();
      if (Array.isArray(data)) {
        setOrders(data);
      }
    } catch (error) {
      console.error("Failed to load orders:", error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <p>Loading orders...</p>;
  }

  return (
    <div>
      <h2>My Orders</h2>

      {orders.length === 0 ? (
        <p>No orders yet.</p>
      ) : (
        orders.map((order) => (
          <div
            key={order._id}
            style={{
              border: "1px solid #ccc",
              padding: "10px",
              marginBottom: "10px",
            }}
          >
            <h3>{order.crop?.cropName}</h3>
            <p>Quantity: {order.quantity}</p>
            <p>Total: ₹{order.totalAmount}</p>
            <p>Farmer: {order.farmer?.name}</p>
            <p>Status: {order.status}</p>
            <p>Delivery: {order.deliveryAddress}</p>

            {order.status === "pending" && (
              <button
                onClick={() => navigate(`/payment?orderId=${order._id}`)}
                style={{
                  marginTop: "8px",
                  padding: "6px 14px",
                  backgroundColor: "#2e7d32",
                  color: "white",
                  border: "none",
                  borderRadius: "4px",
                  cursor: "pointer",
                  fontWeight: "bold",
                }}
              >
                💳 Pay Now
              </button>
            )}

            <button
              onClick={() => navigate(`/order-tracking?orderId=${order._id}`)}
              style={{
                marginTop: "8px",
                marginLeft: order.status === "pending" ? "8px" : "0",
                padding: "6px 14px",
                backgroundColor: "#1976d2",
                color: "white",
                border: "none",
                borderRadius: "4px",
                cursor: "pointer",
                fontWeight: "bold",
              }}
            >
              🚚 Track Order
            </button>
          </div>
        ))
      )}
    </div>
  );
}

export default MyOrders;
