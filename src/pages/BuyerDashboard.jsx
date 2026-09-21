import { useNavigate } from "react-router-dom";
import NotificationBell from "../components/NotificationBell";
import CropMarketplace from "../components/CropMarketplace";
import MyOrders from "../components/MyOrders";

function BuyerDashboard() {
  const navigate = useNavigate();
  const user = JSON.parse(localStorage.getItem("user") || "{}");

  return (
    <div className="dashboard buyer-dashboard">
      <nav
        className="dashboard-navbar"
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          padding: "10px 20px",
          background: "#1565c0",
          color: "white",
        }}
      >
        <h2>🛒 Farm Trading — Buyer Marketplace</h2>
        <div style={{ display: "flex", alignItems: "center", gap: "15px" }}>
          <span>Welcome, {user.name || "Buyer"}</span>
          <button
            onClick={() => navigate("/payment-history")}
            style={{
              padding: "6px 12px",
              background: "#0d47a1",
              color: "white",
              border: "1px solid #90caf9",
              borderRadius: "4px",
              cursor: "pointer",
            }}
          >
            💳 Payment History
          </button>
          <NotificationBell />
        </div>
      </nav>

      <main style={{ padding: "20px" }}>
        <CropMarketplace />
        <hr style={{ margin: "30px 0" }} />
        <MyOrders />
      </main>
    </div>
  );
}

export default BuyerDashboard;
