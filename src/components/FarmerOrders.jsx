import { useEffect, useState } from "react";
import { getFarmerOrders, updateOrderStatus } from "../services/api";

function FarmerOrders() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadOrders();
  }, []);

  const loadOrders = async () => {
    try {
      const data = await getFarmerOrders();
      if (Array.isArray(data)) {
        setOrders(data);
      }
    } catch (error) {
      console.error("Failed to load farmer orders:", error);
    } finally {
      setLoading(false);
    }
  };

  const changeStatus = async (orderId, status) => {
    const result = await updateOrderStatus(orderId, status);
    if (result.order) {
      setOrders(
        orders.map((order) => (order._id === orderId ? result.order : order)),
      );
    }
  };

  if (loading) {
    return <p>Loading orders...</p>;
  }

  return (
    <div>
      <h2>Incoming Orders</h2>

      {orders.length === 0 ? (
        <p>No incoming orders yet.</p>
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
            <p>Buyer: {order.buyer?.name}</p>
            <p>Quantity: {order.quantity}</p>
            <p>Amount: ₹{order.totalAmount}</p>
            <p>Status: {order.status}</p>

            {order.status === "pending" && (
              <>
                <button onClick={() => changeStatus(order._id, "accepted")}>
                  Accept
                </button>
                <button onClick={() => changeStatus(order._id, "rejected")}>
                  Reject
                </button>
              </>
            )}

            {order.status === "accepted" && (
              <button onClick={() => changeStatus(order._id, "processing")}>
                Start Processing
              </button>
            )}

            {order.status === "processing" && (
              <button onClick={() => changeStatus(order._id, "shipped")}>
                Mark Shipped
              </button>
            )}

            {order.status === "shipped" && (
              <button onClick={() => changeStatus(order._id, "delivered")}>
                Mark Delivered
              </button>
            )}
          </div>
        ))
      )}
    </div>
  );
}

export default FarmerOrders;
