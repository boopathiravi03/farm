import { useNavigate } from "react-router-dom";
import NotificationBell from "../components/NotificationBell";
import MyCrops from "../components/MyCrops";
import FarmerOrders from "../components/FarmerOrders";

function FarmerDashboard() {
  const navigate = useNavigate();
  const user = JSON.parse(localStorage.getItem("user") || "{}");

  return (
    <div className="dashboard farmer-dashboard">
      <nav
        className="dashboard-navbar"
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          padding: "10px 20px",
          background: "#2e7d32",
          color: "white",
        }}
      >
        <h2>🌾 Farm Trading — Farmer Portal</h2>
        <div style={{ display: "flex", alignItems: "center", gap: "15px" }}>
          <span>Welcome, {user.name || "Farmer"}</span>
          <button
            onClick={() => navigate("/farmer-earnings")}
            style={{
              padding: "6px 12px",
              background: "#1b5e20",
              color: "white",
              border: "1px solid #81c784",
              borderRadius: "4px",
              cursor: "pointer",
            }}
          >
            💰 My Earnings
          </button>
          <button
            onClick={() => navigate("/ai-assistant")}
            style={{
              padding: "6px 12px",
              background: "#2e7d32",
              color: "white",
              border: "1px solid #a5d6a7",
              borderRadius: "4px",
              cursor: "pointer",
              fontWeight: "bold",
            }}
          >
            🤖 AI Farmer Assistant
          </button>
          <button
            onClick={() => navigate("/farmer-analytics")}
            style={{
              padding: "6px 12px",
              background: "#1565c0",
              color: "white",
              border: "1px solid #90caf9",
              borderRadius: "4px",
              cursor: "pointer",
              fontWeight: "bold",
            }}
          >
            📊 Analytics Dashboard
          </button>
          <button
            onClick={() => navigate("/weather-advisor")}
            style={{
              padding: "6px 12px",
              background: "#0288d1",
              color: "white",
              border: "1px solid #81d4fa",
              borderRadius: "4px",
              cursor: "pointer",
              fontWeight: "bold",
            }}
          >
            🌦️ Weather & Crop Advisor
          </button>
          <button
            onClick={() => navigate("/marketplace-map")}
            style={{
              padding: "6px 12px",
              background: "#388e3c",
              color: "white",
              border: "1px solid #a5d6a7",
              borderRadius: "4px",
              cursor: "pointer",
              fontWeight: "bold",
            }}
          >
            📍 Marketplace Map
          </button>
          <button
            onClick={() => navigate("/add-crop")}
            style={{
              padding: "6px 12px",
              background: "#f57c00",
              color: "white",
              border: "1px solid #ffb74d",
              borderRadius: "4px",
              cursor: "pointer",
              fontWeight: "bold",
            }}
          >
            ➕ List Crop
          </button>
          <button
            onClick={() => navigate("/crop-quality")}
            style={{
              padding: "6px 12px",
              background: "#6a1b9a",
              color: "white",
              border: "1px solid #ce93d8",
              borderRadius: "4px",
              cursor: "pointer",
              fontWeight: "bold",
            }}
          >
            📷 AI Crop Quality
          </button>
          <button
            onClick={() => navigate("/crop-passport")}
            style={{
              padding: "6px 12px",
              background: "#00796b",
              color: "white",
              border: "1px solid #80cbc4",
              borderRadius: "4px",
              cursor: "pointer",
              fontWeight: "bold",
            }}
          >
            📱 Crop Passport
          </button>
          <NotificationBell />
        </div>
      </nav>

      <main style={{ padding: "20px" }}>
        <MyCrops />
        <hr style={{ margin: "30px 0" }} />
        <FarmerOrders />
      </main>
    </div>
  );
}

export default FarmerDashboard;
