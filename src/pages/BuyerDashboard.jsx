import NotificationBell from "../components/NotificationBell";
import CropMarketplace from "../components/CropMarketplace";
import MyOrders from "../components/MyOrders";

function BuyerDashboard() {
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
