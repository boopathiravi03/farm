import { useEffect, useState } from "react";
import { getFarmerAnalytics } from "../services/api";
import {
  LineChart,
  Line,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import "./FarmerAnalytics.css";

function FarmerAnalytics() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadAnalytics();
  }, []);

  async function loadAnalytics() {
    try {
      const result = await getFarmerAnalytics();

      if (result.success) {
        setData(result.analytics);
      }
    } catch (error) {
      console.error("Analytics loading error:", error);
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return (
      <div className="analytics-loading">
        Loading analytics...
      </div>
    );
  }

  if (!data) {
    return (
      <div className="analytics-error">
        Unable to load analytics.
      </div>
    );
  }

  return (
    <div className="analytics-page">
      <div className="analytics-header">
        <div>
          <h1>📊 Farmer Analytics</h1>
          <p>Track your farm business performance</p>
        </div>
      </div>

      {/* STAT CARDS */}
      <div className="stats-grid">
        <div className="stat-card">
          <span className="stat-icon">💰</span>
          <div>
            <p>Total Revenue</p>
            <h2>₹{data.totalRevenue.toLocaleString("en-IN")}</h2>
          </div>
        </div>

        <div className="stat-card">
          <span className="stat-icon">📦</span>
          <div>
            <p>Total Orders</p>
            <h2>{data.totalOrders}</h2>
          </div>
        </div>

        <div className="stat-card">
          <span className="stat-icon">🌱</span>
          <div>
            <p>Active Crops</p>
            <h2>{data.activeCrops}</h2>
          </div>
        </div>

        <div className="stat-card">
          <span className="stat-icon">🚚</span>
          <div>
            <p>Delivered</p>
            <h2>{data.deliveredOrders}</h2>
          </div>
        </div>

        <div className="stat-card">
          <span className="stat-icon">⏳</span>
          <div>
            <p>Pending</p>
            <h2>{data.pendingOrders}</h2>
          </div>
        </div>

        <div className="stat-card">
          <span className="stat-icon">🌾</span>
          <div>
            <p>Sold Crops</p>
            <h2>{data.soldCrops}</h2>
          </div>
        </div>
      </div>

      {/* MONTHLY SALES */}
      <div className="chart-card">
        <h2>📈 Monthly Sales</h2>

        {data.monthlySales.length === 0 ? (
          <p className="empty-text">No sales data available yet.</p>
        ) : (
          <ResponsiveContainer width="100%" height={320}>
            <LineChart data={data.monthlySales}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip
                formatter={(value) => [
                  `₹${value.toLocaleString("en-IN")}`,
                  "Sales",
                ]}
              />
              <Line type="monotone" dataKey="sales" strokeWidth={3} />
            </LineChart>
          </ResponsiveContainer>
        )}
      </div>

      {/* BEST SELLING */}
      <div className="chart-card">
        <h2>🏆 Best-Selling Crops</h2>

        {data.bestSellingCrops.length === 0 ? (
          <p className="empty-text">No crop sales available yet.</p>
        ) : (
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={data.bestSellingCrops}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="cropName" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="quantitySold" name="Quantity Sold" />
            </BarChart>
          </ResponsiveContainer>
        )}
      </div>

      {/* INSIGHTS */}
      <div className="insights-card">
        <h2>🤖 Smart Farm Insights</h2>

        {data.insights.map((insight, index) => (
          <div className="insight-item" key={index}>
            <span>💡</span>
            <p>{insight}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

export default FarmerAnalytics;
