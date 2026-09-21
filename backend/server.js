const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const dotenv = require("dotenv");
const http = require("http");
const { Server } = require("socket.io");

dotenv.config();

const authRoutes = require("./routes/authRoutes");
const cropRoutes = require("./routes/cropRoutes");
const orderRoutes = require("./routes/orderRoutes");
const negotiationRoutes = require("./routes/negotiationRoutes");
const notificationRoutes = require("./routes/notificationRoutes");
const paymentRoutes = require("./routes/paymentRoutes");

const app = express();

const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*",
  },
});

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.json({
    message: "Farm Trading API is running 🚜🌾",
  });
});

app.use("/api/auth", authRoutes);
app.use("/api/crops", cropRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/negotiations", negotiationRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/payments", paymentRoutes);

// Socket.IO
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

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log("MongoDB connected successfully ✅");

    server.listen(process.env.PORT || 5000, () => {
      console.log(
        `Server running on http://localhost:${process.env.PORT || 5000}`,
      );
    });
  })
  .catch((error) => {
    console.error("MongoDB connection failed ❌");
    console.error(error.message);
  });
