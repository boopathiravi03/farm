import NotificationBell from "../components/NotificationBell";
import MyCrops from "../components/MyCrops";
import FarmerOrders from "../components/FarmerOrders";

function FarmerDashboard() {
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
