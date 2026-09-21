import { useEffect, useState } from "react";
import { getMyOrders } from "../services/api";

function MyOrders() {
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
          </div>
        ))
      )}
    </div>
  );
}

export default MyOrders;
