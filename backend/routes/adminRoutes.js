const express = require("express");
const mongoose = require("mongoose");

const User = require("../models/User");
const Crop = require("../models/Crop");
const Order = require("../models/Order");
const Transaction = require("../models/Transaction");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// ===============================
// ADMIN MIDDLEWARE
// ===============================

const adminOnly = (req, res, next) => {
  if (req.user.role !== "admin") {
    return res.status(403).json({
      success: false,
      message: "Admin access required",
    });
  }

  next();
};

// ===============================
// ADMIN DASHBOARD STATS
// ===============================

router.get("/stats", authMiddleware, adminOnly, async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();

    const totalFarmers = await User.countDocuments({
      role: "farmer",
    });

    const totalBuyers = await User.countDocuments({
      role: "buyer",
    });

    const totalAdmins = await User.countDocuments({
      role: "admin",
    });

    const totalCrops = await Crop.countDocuments();

    const availableCrops = await Crop.countDocuments({
      status: "available",
    });

    const soldCrops = await Crop.countDocuments({
      status: "sold",
    });

    const totalOrders = await Order.countDocuments();

    const pendingOrders = await Order.countDocuments({
      status: "pending",
    });

    const deliveredOrders = await Order.countDocuments({
      status: "delivered",
    });

    const revenueResult = await Transaction.aggregate([
      {
        $match: {
          type: "purchase",
          status: "completed",
        },
      },
      {
        $group: {
          _id: null,
          totalRevenue: {
            $sum: "$amount",
          },
        },
      },
    ]);

    const totalRevenue =
      revenueResult.length > 0 ? revenueResult[0].totalRevenue : 0;

    res.json({
      success: true,
      stats: {
        totalUsers,
        totalFarmers,
        totalBuyers,
        totalAdmins,
        totalCrops,
        availableCrops,
        soldCrops,
        totalOrders,
        pendingOrders,
        deliveredOrders,
        totalRevenue,
      },
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to load admin statistics",
    });
  }
});

// ===============================
// GET ALL USERS
// ===============================

router.get("/users", authMiddleware, adminOnly, async (req, res) => {
  try {
    const users = await User.find().select("-password").sort({ createdAt: -1 });

    res.json({
      success: true,
      users,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to load users",
    });
  }
});

// ===============================
// CHANGE USER ROLE
// ===============================

router.put("/users/:id/role", authMiddleware, adminOnly, async (req, res) => {
  try {
    const { role } = req.body;

    if (!["farmer", "buyer", "admin"].includes(role)) {
      return res.status(400).json({
        success: false,
        message: "Invalid role",
      });
    }

    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    user.role = role;

    await user.save();

    res.json({
      success: true,
      message: "User role updated",
      user,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to update user role",
    });
  }
});

// ===============================
// DELETE USER
// ===============================

router.delete("/users/:id", authMiddleware, adminOnly, async (req, res) => {
  try {
    if (req.params.id === req.user.id) {
      return res.status(400).json({
        success: false,
        message: "Admin cannot delete own account",
      });
    }

    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    if (user.role === "admin") {
      return res.status(400).json({
        success: false,
        message: "Admin users cannot be deleted",
      });
    }

    await User.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: "User deleted successfully",
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to delete user",
    });
  }
});

// ===============================
// GET ALL CROPS
// ===============================

router.get("/crops", authMiddleware, adminOnly, async (req, res) => {
  try {
    const crops = await Crop.find()
      .populate("farmer", "name email phone")
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      crops,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to load crops",
    });
  }
});

// ===============================
// DELETE CROP
// ===============================

router.delete("/crops/:id", authMiddleware, adminOnly, async (req, res) => {
  try {
    const crop = await Crop.findById(req.params.id);

    if (!crop) {
      return res.status(404).json({
        success: false,
        message: "Crop not found",
      });
    }

    await Crop.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: "Crop deleted successfully",
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to delete crop",
    });
  }
});

// ===============================
// GET ALL ORDERS
// ===============================

router.get("/orders", authMiddleware, adminOnly, async (req, res) => {
  try {
    const orders = await Order.find()
      .populate("buyer", "name email")
      .populate("farmer", "name email")
      .populate("crop", "cropName category")
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      orders,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to load orders",
    });
  }
});

module.exports = router;
