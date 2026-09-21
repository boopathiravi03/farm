import { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";
import { getDelivery } from "../services/api";
import "./OrderTracking.css";

function OrderTracking() {
  const [searchParams] = useSearchParams();
  const orderId = searchParams.get("orderId");
  const [delivery, setDelivery] = useState(null);
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (orderId) {
      loadTracking();
    }
  }, [orderId]);

  async function loadTracking() {
    try {
      const result = await getDelivery(orderId);
      setDelivery(result.delivery);
      setHistory(result.history || []);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return <div className="tracking-page">Loading tracking...</div>;
  }

  if (!delivery) {
    return (
      <div className="tracking-page">
        <h2>🚚 Delivery Not Created</h2>
        <p>Tracking will appear once the farmer creates the delivery.</p>
      </div>
    );
  }

  return (
    <div className="tracking-page">
      <h1>🚚 Track Your Order</h1>

      <div className="tracking-info">
        <h3>Tracking ID</h3>
        <p>{delivery.trackingId}</p>

        <h3>Delivery Address</h3>
        <p>{delivery.deliveryAddress}</p>

        <h3>Estimated Delivery</h3>
        <p>
          {delivery.estimatedDelivery
            ? new Date(delivery.estimatedDelivery).toLocaleDateString()
            : "Not available"}
        </p>
      </div>

      <div className="tracking-timeline">
        {history.map((item, index) => (
          <div className="timeline-item" key={item._id}>
            <div className="timeline-dot">
              {index === history.length - 1 ? "📍" : "✓"}
            </div>

            <div className="timeline-content">
              <h3>{formatStatus(item.status)}</h3>
              <p>{item.message}</p>
              <small>{new Date(item.timestamp).toLocaleString()}</small>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function formatStatus(status) {
  const names = {
    processing: "⚙️ Processing",
    packed: "📦 Packed",
    shipped: "🚚 Shipped",
    out_for_delivery: "🛵 Out for Delivery",
    delivered: "🏠 Delivered",
  };

  return names[status] || status;
}

export default OrderTracking;
