const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const dotenv = require("dotenv");
const http = require("http");
const { Server } = require("socket.io");

dotenv.config();

const app = express();
const server = http.createServer(app);

const PORT = process.env.PORT || 5000;

// ===============================
// CHECK ENVIRONMENT VARIABLES
// ===============================

const mongoUriExists = Boolean(process.env.MONGO_URI);
const jwtSecretExists = Boolean(process.env.JWT_SECRET);

console.log(`Starting Farm Trading API on port: ${PORT}`);
console.log(`MONGO_URI configured: ${mongoUriExists ? "Yes ✅" : "No ❌"}`);
console.log(`JWT_SECRET configured: ${jwtSecretExists ? "Yes ✅" : "No ❌"}`);

if (!mongoUriExists) {
  console.error("❌ MONGO_URI environment variable is missing");
}

if (!jwtSecretExists) {
  console.error("❌ JWT_SECRET environment variable is missing");
}

// ===============================
// SOCKET.IO
// ===============================

const io = new Server(server, {
  cors: {
    origin: "*",
  },
});

// ===============================
// MIDDLEWARE
// ===============================

app.use(cors());
app.use(express.json());

// ===============================
// HEALTH CHECK
// ===============================

app.get("/", (req, res) => {
  res.json({
    message: "Farm Trading API is running",
    status: "healthy",
  });
});

// ===============================
// ROUTES
// ===============================

const authRoutes = require("./routes/authRoutes");
const cropRoutes = require("./routes/cropRoutes");
const orderRoutes = require("./routes/orderRoutes");
const negotiationRoutes = require("./routes/negotiationRoutes");
const notificationRoutes = require("./routes/notificationRoutes");
const paymentRoutes = require("./routes/paymentRoutes");
const deliveryRoutes = require("./routes/deliveryRoutes");
const aiRoutes = require("./routes/aiRoutes");
const analyticsRoutes = require("./routes/analyticsRoutes");
const weatherRoutes = require("./routes/weatherRoutes");
const passportRoutes = require("./routes/passportRoutes");
const adminRoutes = require("./routes/adminRoutes");
const marketPriceRoutes = require("./routes/marketPriceRoutes");
const profileRoutes = require("./routes/profileRoutes");
const bankRoutes = require("./routes/bankRoutes");
const marketPriceService = require("./services/marketPriceService");

app.use("/api/auth", authRoutes);
app.use("/api/crops", cropRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/negotiations", negotiationRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/payments", paymentRoutes);
app.use("/api/deliveries", deliveryRoutes);
app.use("/api/ai", aiRoutes);
app.use("/api/analytics", analyticsRoutes);
app.use("/api/weather", weatherRoutes);
app.use("/api/passports", passportRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/market-prices", marketPriceRoutes);
app.use("/api/profile", profileRoutes);
app.use("/api/bank", bankRoutes);
app.use("/api/bank-details", bankRoutes);

// ===============================
// SOCKET EVENTS
// ===============================

io.on("connection", (socket) => {
  console.log("User connected:", socket.id);

  socket.on("joinUser", (userId) => {
    socket.join(`user_${userId}`);
    console.log(`User ${userId} joined notification room`);
  });

  socket.on("disconnect", () => {
    console.log("User disconnected:", socket.id);
  });
});

app.set("io", io);

// ===============================
// START SERVER & CONNECT MONGODB
// ===============================

// Start listening immediately so Render detects port binding and health check responds
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

// Connect to MongoDB
if (process.env.MONGO_URI) {
  mongoose
    .connect(process.env.MONGO_URI)
    .then(() => {
      console.log("MongoDB connected successfully ✅");
      marketPriceService
        .getChennaiPrices()
        .catch((err) => console.warn("Init prices:", err.message));
    })
    .catch((error) => {
      console.error("MongoDB connection failed ❌");
      console.error("Error details:", error.message);
    });
}
