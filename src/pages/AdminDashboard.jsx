import NotificationBell from "../components/NotificationBell";
import React, { useEffect, useState } from "react";

import {
  getAdminStats,
  getAdminUsers,
  deleteAdminUser,
  getAdminCrops,
  deleteAdminCrop,
  getAdminOrders,
} from "../services/api";

import "./AdminDashboard.css";

function AdminDashboard() {
  const user = JSON.parse(localStorage.getItem("user") || "{}");
  const [stats, setStats] = useState({});
  const [users, setUsers] = useState([]);
  const [crops, setCrops] = useState([]);
  const [orders, setOrders] = useState([]);

  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboard();
  }, []);

  const loadDashboard = async () => {
    try {
      setLoading(true);

      const [
        statsData,
        usersData,
        cropsData,
        ordersData,
      ] = await Promise.all([
        getAdminStats(),
        getAdminUsers(),
        getAdminCrops(),
        getAdminOrders(),
      ]);

      if (statsData.success) {
        setStats(statsData.stats);
      }

      if (usersData.success) {
        setUsers(usersData.users);
      }

      if (cropsData.success) {
        setCrops(cropsData.crops);
      }

      if (ordersData.success) {
        setOrders(ordersData.orders);
      }
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteUser = async (id) => {
    const confirmDelete = window.confirm(
      "Are you sure you want to delete this user?"
    );

    if (!confirmDelete) return;

    const result = await deleteAdminUser(id);

    alert(result.message);

    if (result.success) {
      loadDashboard();
    }
  };

  const handleDeleteCrop = async (id) => {
    const confirmDelete = window.confirm(
      "Are you sure you want to delete this crop?"
    );

    if (!confirmDelete) return;

    const result = await deleteAdminCrop(id);

    alert(result.message);

    if (result.success) {
      loadDashboard();
    }
  };

  if (loading) {
    return (
      <div className="admin-loading">
        Loading Admin Dashboard...
      </div>
    );
  }

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
    <div className="admin-dashboard">
      {/* HEADER */}
      <div className="admin-header">
        <div>
          <p className="admin-label">FARM TRADING</p>
          <h1>Admin Dashboard</h1>
          <p>Manage users, crops, orders and platform activity.</p>
        </div>
      </nav>

      <main style={{ padding: "20px" }}>
        <h3>System Overview & Live Notifications</h3>
        <p>
          Monitor platform transactions, order flows, and real-time farmer-buyer
          alerts.
        </p>
      </main>
        <div className="admin-badge">👨💼 ADMIN</div>
      </div>

      {/* STAT CARDS */}
      <div className="admin-stats">
        <div className="admin-stat-card">
          <span>👥</span>
          <h3>Total Users</h3>
          <strong>{stats.totalUsers || 0}</strong>
        </div>

        <div className="admin-stat-card">
          <span>👨🌾</span>
          <h3>Farmers</h3>
          <strong>{stats.totalFarmers || 0}</strong>
        </div>

        <div className="admin-stat-card">
          <span>🛒</span>
          <h3>Buyers</h3>
          <strong>{stats.totalBuyers || 0}</strong>
        </div>

        <div className="admin-stat-card">
          <span>🌾</span>
          <h3>Total Crops</h3>
          <strong>{stats.totalCrops || 0}</strong>
        </div>

        <div className="admin-stat-card">
          <span>📦</span>
          <h3>Total Orders</h3>
          <strong>{stats.totalOrders || 0}</strong>
        </div>

        <div className="admin-stat-card revenue-card">
          <span>💰</span>
          <h3>Platform Revenue</h3>
          <strong>
            ₹{Number(stats.totalRevenue || 0).toLocaleString()}
          </strong>
        </div>
      </div>

      {/* ORDER SUMMARY */}
      <div className="admin-summary">
        <div>
          <span>Available Crops</span>
          <strong>{stats.availableCrops || 0}</strong>
        </div>

        <div>
          <span>Sold Crops</span>
          <strong>{stats.soldCrops || 0}</strong>
        </div>

        <div>
          <span>Pending Orders</span>
          <strong>{stats.pendingOrders || 0}</strong>
        </div>

        <div>
          <span>Delivered Orders</span>
          <strong>{stats.deliveredOrders || 0}</strong>
        </div>
      </div>

      {/* USERS */}
      <section className="admin-section">
        <div className="section-heading">
          <div>
            <h2>👥 User Management</h2>
            <p>Registered users on Farm Trading</p>
          </div>

          <span>{users.length} Users</span>
        </div>

        <div className="table-wrapper">
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Role</th>
                <th>Action</th>
              </tr>
            </thead>

            <tbody>
              {users.length === 0 ? (
                <tr>
                  <td colSpan="5">No users found</td>
                </tr>
              ) : (
                users.map((user) => (
                  <tr key={user._id}>
                    <td>{user.name}</td>
                    <td>{user.email}</td>
                    <td>{user.phone || "-"}</td>
                    <td>
                      <span className={`role ${user.role}`}>
                        {user.role}
                      </span>
                    </td>
                    <td>
                      {user.role !== "admin" && (
                        <button
                          className="delete-btn"
                          onClick={() => handleDeleteUser(user._id)}
                        >
                          Delete
                        </button>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>

      {/* CROPS */}
      <section className="admin-section">
        <div className="section-heading">
          <div>
            <h2>🌾 Crop Management</h2>
            <p>Monitor marketplace crop listings</p>
          </div>

          <span>{crops.length} Crops</span>
        </div>

        <div className="table-wrapper">
          <table>
            <thead>
              <tr>
                <th>Crop</th>
                <th>Category</th>
                <th>Farmer</th>
                <th>Quantity</th>
                <th>Price</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>

            <tbody>
              {crops.length === 0 ? (
                <tr>
                  <td colSpan="7">No crops found</td>
                </tr>
              ) : (
                crops.map((crop) => (
                  <tr key={crop._id}>
                    <td>{crop.cropName}</td>
                    <td>{crop.category || "-"}</td>
                    <td>{crop.farmer?.name || "Unknown"}</td>
                    <td>
                      {crop.quantity} {crop.unit}
                    </td>
                    <td>₹{crop.price}</td>
                    <td>
                      <span className={`status ${crop.status}`}>
                        {crop.status}
                      </span>
                    </td>
                    <td>
                      <button
                        className="delete-btn"
                        onClick={() => handleDeleteCrop(crop._id)}
                      >
                        Delete
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>

      {/* ORDERS */}
      <section className="admin-section">
        <div className="section-heading">
          <div>
            <h2>📦 Order Monitoring</h2>
            <p>All marketplace orders</p>
          </div>

          <span>{orders.length} Orders</span>
        </div>

        <div className="table-wrapper">
          <table>
            <thead>
              <tr>
                <th>Crop</th>
                <th>Buyer</th>
                <th>Farmer</th>
                <th>Quantity</th>
                <th>Total</th>
                <th>Status</th>
              </tr>
            </thead>

            <tbody>
              {orders.length === 0 ? (
                <tr>
                  <td colSpan="6">No orders found</td>
                </tr>
              ) : (
                orders.map((order) => (
                  <tr key={order._id}>
                    <td>{order.crop?.cropName || "Unknown"}</td>
                    <td>{order.buyer?.name || "Unknown"}</td>
                    <td>{order.farmer?.name || "Unknown"}</td>
                    <td>{order.quantity}</td>
                    <td>₹{order.totalAmount}</td>
                    <td>
                      <span className={`status ${order.status}`}>
                        {order.status}
                      </span>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>

      {/* FOOTER */}
      <div className="admin-footer">
        <h3>🚜 Farm Trading Administration</h3>
        <p>Marketplace management system for farmers and buyers.</p>
      </div>
    </div>
  );
}

export default AdminDashboard;
