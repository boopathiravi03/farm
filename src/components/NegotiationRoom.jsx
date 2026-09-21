import { useEffect, useState } from "react";
import {
  getNegotiation,
  sendOffer,
  acceptNegotiation,
  rejectNegotiation,
  placeOrder,
} from "../services/api";

function NegotiationRoom({ negotiationId, currentUserId, onOrderPlaced }) {
  const [negotiation, setNegotiation] = useState(null);
  const [offers, setOffers] = useState([]);
  const [counterPrice, setCounterPrice] = useState("");
  const [message, setMessage] = useState("");
  const [deliveryAddress, setDeliveryAddress] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
  }, [negotiationId]);

  const loadData = async () => {
    try {
      const data = await getNegotiation(negotiationId);
      if (data.negotiation) {
        setNegotiation(data.negotiation);
        setOffers(data.offers || []);
      }
    } catch (error) {
      console.error("Failed to load negotiation:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleSendOffer = async (e) => {
    e.preventDefault();
    if (!counterPrice) return;

    const result = await sendOffer(
      negotiationId,
      Number(counterPrice),
      message,
    );
    if (result.offer) {
      setOffers([...offers, result.offer]);
      setNegotiation({ ...negotiation, currentPrice: Number(counterPrice) });
      setCounterPrice("");
      setMessage("");
    } else {
      alert(result.message);
    }
  };

  const handleAccept = async () => {
    const result = await acceptNegotiation(negotiationId);
    if (result.negotiation) {
      setNegotiation(result.negotiation);
    } else {
      alert(result.message);
    }
  };

  const handleReject = async () => {
    const result = await rejectNegotiation(negotiationId);
    if (result.message) {
      setNegotiation({ ...negotiation, status: "rejected" });
    }
  };

  const handlePlaceAgreedOrder = async () => {
    if (!deliveryAddress) {
      alert("Please enter delivery address");
      return;
    }

    const result = await placeOrder({
      cropId: negotiation.crop._id,
      quantity: negotiation.quantity,
      deliveryAddress,
    });

    if (result.order) {
      alert("Agreed deal order placed successfully!");
      if (onOrderPlaced) onOrderPlaced(result.order);
    } else {
      alert(result.message);
    }
  };

  if (loading) return <p>Loading negotiation room...</p>;
  if (!negotiation) return <p>Negotiation not found.</p>;

  const agreedTotal = negotiation.quantity * negotiation.currentPrice;

  return (
    <div style={{ maxWidth: "600px", margin: "0 auto", padding: "20px" }}>
      <h2>🤝 Negotiation Room</h2>
      <div
        style={{
          background: "#f5f5f5",
          padding: "14px",
          borderRadius: "8px",
          marginBottom: "16px",
        }}
      >
        <h3>{negotiation.crop?.cropName}</h3>
        <p>Quantity: {negotiation.quantity} kg</p>
        <p>Original Listed Price: ₹{negotiation.crop?.price}/kg</p>
        <p>
          <strong>Current Active Offer: ₹{negotiation.currentPrice}/kg</strong>
        </p>
        <p>
          Status:{" "}
          <span style={{ fontWeight: "bold" }}>
            {negotiation.status.toUpperCase()}
          </span>
        </p>
      </div>

      {/* Offers Timeline */}
      <div
        style={{
          border: "1px solid #ddd",
          borderRadius: "8px",
          padding: "14px",
          marginBottom: "16px",
          maxHeight: "300px",
          overflowY: "auto",
        }}
      >
        <h4>Offer History</h4>
        {offers.map((offer) => {
          const isBuyer = offer.sender?.role === "buyer";
          return (
            <div
              key={offer._id}
              style={{
                padding: "8px 12px",
                margin: "8px 0",
                background: isBuyer ? "#e3f2fd" : "#e8f5e9",
                borderRadius: "6px",
              }}
            >
              <strong>
                {isBuyer ? "🛒 Buyer" : "👨🌾 Farmer"} ({offer.sender?.name}):
              </strong>
              <span
                style={{
                  fontSize: "16px",
                  fontWeight: "bold",
                  marginLeft: "10px",
                }}
              >
                ₹{offer.price}/kg
              </span>
              {offer.message && (
                <p style={{ margin: "4px 0 0 0", color: "#555" }}>
                  "{offer.message}"
                </p>
              )}
            </div>
          );
        })}
      </div>

      {/* If Deal Agreed */}
      {negotiation.status === "accepted" && (
        <div
          style={{
            background: "#e8f5e9",
            border: "2px solid #4caf50",
            padding: "16px",
            borderRadius: "10px",
            marginBottom: "16px",
            textAlign: "center",
          }}
        >
          <h3>🎉 DEAL AGREED</h3>
          <p>Crop: {negotiation.crop?.cropName}</p>
          <p>Quantity: {negotiation.quantity} kg</p>
          <p>Agreed Price: ₹{negotiation.currentPrice}/kg</p>
          <p style={{ fontSize: "18px", fontWeight: "bold" }}>
            Total: ₹{agreedTotal}
          </p>

          <input
            type="text"
            placeholder="Enter delivery address"
            value={deliveryAddress}
            onChange={(e) => setDeliveryAddress(e.target.value)}
            style={{ width: "80%", padding: "8px", margin: "10px 0" }}
          />
          <br />
          <button
            onClick={handlePlaceAgreedOrder}
            style={{
              background: "#2e7d32",
              color: "#fff",
              padding: "10px 20px",
              border: "none",
              borderRadius: "6px",
              cursor: "pointer",
            }}
          >
            🛒 Place Order (₹{agreedTotal})
          </button>
        </div>
      )}

      {/* Active Controls */}
      {negotiation.status === "active" && (
        <div>
          <form onSubmit={handleSendOffer} style={{ marginBottom: "12px" }}>
            <input
              type="number"
              placeholder="Counter Price (₹/kg)"
              value={counterPrice}
              onChange={(e) => setCounterPrice(e.target.value)}
              style={{ padding: "8px", marginRight: "8px" }}
            />
            <input
              type="text"
              placeholder="Message (optional)"
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              style={{ padding: "8px", marginRight: "8px" }}
            />
            <button type="submit">Send Offer</button>
          </form>

          <div>
            <button
              onClick={handleAccept}
              style={{
                background: "#4caf50",
                color: "#fff",
                padding: "8px 16px",
                marginRight: "10px",
                border: "none",
                borderRadius: "4px",
              }}
            >
              Accept Current Offer (₹{negotiation.currentPrice})
            </button>
            <button
              onClick={handleReject}
              style={{
                background: "#f44336",
                color: "#fff",
                padding: "8px 16px",
                border: "none",
                borderRadius: "4px",
              }}
            >
              Reject
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

export default NegotiationRoom;
