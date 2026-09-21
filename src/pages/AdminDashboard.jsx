import NotificationBell from "../components/NotificationBell";

function AdminDashboard() {
  const user = JSON.parse(localStorage.getItem("user") || "{}");

  return (
    <div className="dashboard admin-dashboard">
      <nav
        className="dashboard-navbar"
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          padding: "10px 20px",
          background: "#37474f",
          color: "white",
        }}
      >
        <h2>📊 Farm Trading — Admin Overview</h2>
        <div style={{ display: "flex", alignItems: "center", gap: "15px" }}>
          <span>Admin: {user.name || "Administrator"}</span>
          <NotificationBell />
        </div>
      </nav>

      <main style={{ padding: "20px" }}>
        <h3>System Overview & Live Notifications</h3>
        <p>
          Monitor platform transactions, order flows, and real-time farmer-buyer
          alerts.
        </p>
      </main>
    </div>
  );
}

export default AdminDashboard;
