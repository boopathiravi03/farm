import { useEffect, useState } from "react";
import {
  getFarmerOrders,
  updateOrderStatus,
  createDelivery,
  getDelivery,
  updateDeliveryStatus,
} from "../services/api";

function FarmerOrders() {
  const [orders, setOrders] = useState([]);
  const [deliveries, setDeliveries] = useState({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadOrders();
  }, []);

  const loadOrders = async () => {
    try {
      const data = await getFarmerOrders();
      if (Array.isArray(data)) {
        setOrders(data);
        // Load deliveries for non-pending orders
        for (const order of data) {
          if (order.status !== "pending" && order.status !== "rejected") {
            loadOrderDelivery(order._id);
          }
        }
      }
    } catch (error) {
      console.error("Failed to load farmer orders:", error);
    } finally {
      setLoading(false);
    }
  };

  const loadOrderDelivery = async (orderId) => {
    try {
      const res = await getDelivery(orderId);
      if (res.delivery) {
        setDeliveries((prev) => ({ ...prev, [orderId]: res.delivery }));
      }
    } catch (error) {
      // No delivery yet, normal behavior
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

  const handleCreateDelivery = async (orderId) => {
    try {
      const result = await createDelivery(orderId);
      if (result.delivery) {
        alert(
          "Delivery created successfully! Tracking ID: " +
            result.delivery.trackingId,
        );
        setDeliveries((prev) => ({ ...prev, [orderId]: result.delivery }));
        loadOrders();
      } else {
        alert(result.message || "Failed to create delivery");
      }
    } catch (error) {
      console.error(error);
    }
  };

  const handleDeliveryStatus = async (orderId, deliveryId, status) => {
    try {
      const result = await updateDeliveryStatus(deliveryId, status);
      if (result.delivery) {
        alert("Delivery status updated to " + status + " ✅");
        setDeliveries((prev) => ({ ...prev, [orderId]: result.delivery }));
        setOrders(
          orders.map((order) =>
            order._id === orderId ? { ...order, status } : order,
          ),
        );
      } else {
        alert(result.message || "Failed to update delivery status");
      }
    } catch (error) {
      console.error(error);
    }
  };

  if (loading) {
    return <p>Loading orders...</p>;
  }

  return (
    <div>
      <h2>Incoming Orders & Delivery Controls</h2>

      {orders.length === 0 ? (
        <p>No incoming orders yet.</p>
      ) : (
        orders.map((order) => {
          const delivery = deliveries[order._id];

          return (
            <div
              key={order._id}
              style={{
                border: "1px solid #ccc",
                borderRadius: "8px",
                padding: "15px",
                marginBottom: "15px",
                backgroundColor: "#fff",
              }}
            >
              <h3>{order.crop?.cropName}</h3>
              <p>Buyer: {order.buyer?.name}</p>
              <p>Quantity: {order.quantity}</p>
              <p>Amount: ₹{order.totalAmount}</p>
              <p>Delivery Address: {order.deliveryAddress}</p>
              <p>
                <strong>Order Status:</strong> {order.status}
              </p>

              {order.status === "pending" && (
                <div
                  style={{ marginTop: "10px", display: "flex", gap: "10px" }}
                >
                  <button
                    onClick={() => changeStatus(order._id, "accepted")}
                    style={{
                      background: "#2e7d32",
                      color: "white",
                      padding: "6px 14px",
                      border: "none",
                      borderRadius: "4px",
                    }}
                  >
                    Accept
                  </button>
                  <button
                    onClick={() => changeStatus(order._id, "rejected")}
                    style={{
                      background: "#c62828",
                      color: "white",
                      padding: "6px 14px",
                      border: "none",
                      borderRadius: "4px",
                    }}
                  >
                    Reject
                  </button>
                </div>
              )}

              {/* Delivery Section */}
              {order.status !== "pending" && order.status !== "rejected" && (
                <div
                  style={{
                    marginTop: "15px",
                    padding: "12px",
                    background: "#f1f8e9",
                    borderRadius: "6px",
                    border: "1px solid #dcedc8",
                  }}
                >
                  <h4 style={{ margin: "0 0 10px 0" }}>🚚 Delivery Tracking</h4>

                  {!delivery ? (
                    <button
                      onClick={() => handleCreateDelivery(order._id)}
                      style={{
                        padding: "6px 14px",
                        background: "#2e7d32",
                        color: "white",
                        border: "none",
                        borderRadius: "4px",
                        cursor: "pointer",
                      }}
                    >
                      🚚 Create Delivery
                    </button>
                  ) : (
                    <div>
                      <p style={{ margin: "4px 0" }}>
                        Tracking ID: <strong>{delivery.trackingId}</strong>
                      </p>
                      <div
                        style={{
                          marginTop: "8px",
                          display: "flex",
                          alignItems: "center",
                          gap: "10px",
                        }}
                      >
                        <label>
                          <strong>Update Delivery Status:</strong>
                        </label>
                        <select
                          value={delivery.status}
                          onChange={(e) =>
                            handleDeliveryStatus(
                              order._id,
                              delivery._id,
                              e.target.value,
                            )
                          }
                          style={{ padding: "6px 10px", borderRadius: "4px" }}
                        >
                          <option value="processing">⚙️ Processing</option>
                          <option value="packed">📦 Packed</option>
                          <option value="shipped">🚚 Shipped</option>
                          <option value="out_for_delivery">
                            🛵 Out for Delivery
                          </option>
                          <option value="delivered">🏠 Delivered</option>
                        </select>
                      </div>
                    </div>
                  )}
                </div>
              )}
            </div>
          );
        })
      )}
    </div>
  );
}

export default FarmerOrders;
