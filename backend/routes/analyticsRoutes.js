const express = require("express");
const mongoose = require("mongoose");

const Order = require("../models/Order");
const Crop = require("../models/Crop");
const Transaction = require("../models/Transaction");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// GET FARMER ANALYTICS
router.get("/farmer", authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== "farmer") {
      return res.status(403).json({
        success: false,
        message: "Only farmers can access analytics",
      });
    }

    const farmerId = new mongoose.Types.ObjectId(req.user.id);

    // Revenue
    const revenueResult = await Transaction.aggregate([
      {
        $match: {
          farmer: farmerId,
          type: "purchase",
          status: "completed",
        },
      },
      {
        $group: {
          _id: null,
          total: { $sum: "$amount" },
        },
      },
    ]);

    const totalRevenue = revenueResult[0]?.total || 0;

    // Total orders
    const totalOrders = await Order.countDocuments({
      farmer: farmerId,
    });

    // Delivered orders
    const deliveredOrders = await Order.countDocuments({
      farmer: farmerId,
      status: "delivered",
    });

    // Pending orders
    const pendingOrders = await Order.countDocuments({
      farmer: farmerId,
      status: {
        $in: [
          "pending",
          "accepted",
          "processing",
          "packed",
          "shipped",
          "out_for_delivery",
        ],
      },
    });

    // Active crops
    const activeCrops = await Crop.countDocuments({
      farmer: farmerId,
      status: "available",
    });

    // Sold crops
    const soldCrops = await Crop.countDocuments({
      farmer: farmerId,
      status: "sold",
    });

    // Monthly sales
    const monthlySales = await Transaction.aggregate([
      {
        $match: {
          farmer: farmerId,
          type: "purchase",
          status: "completed",
        },
      },
      {
        $group: {
          _id: {
            month: { $month: "$createdAt" },
            year: { $year: "$createdAt" },
          },
          sales: { $sum: "$amount" },
        },
      },
      {
        $sort: {
          "_id.year": 1,
          "_id.month": 1,
        },
      },
    ]);

    const monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    const chartData = monthlySales.map((item) => ({
      month: monthNames[item._id.month - 1],
      sales: item.sales,
    }));

    // Best-selling crops
    const bestSellingCrops = await Order.aggregate([
      {
        $match: {
          farmer: farmerId,
          status: {
            $nin: ["rejected", "cancelled"],
          },
        },
      },
      {
        $group: {
          _id: "$crop",
          quantitySold: {
            $sum: "$quantity",
          },
          revenue: {
            $sum: "$totalAmount",
          },
        },
      },
      {
        $sort: {
          quantitySold: -1,
        },
      },
      {
        $limit: 5,
      },
      {
        $lookup: {
          from: "crops",
          localField: "_id",
          foreignField: "_id",
          as: "crop",
        },
      },
      {
        $unwind: {
          path: "$crop",
          preserveNullAndEmptyArrays: true,
        },
      },
      {
        $project: {
          _id: 0,
          cropName: "$crop.cropName",
          quantitySold: 1,
          revenue: 1,
        },
      },
    ]);

    // Smart insights
    const insights = [];

    if (activeCrops === 0) {
      insights.push(
        "You currently have no active crop listings. Consider adding new crops."
      );
    }

    if (pendingOrders > 0) {
      insights.push(
        `You have ${pendingOrders} pending order(s) that need attention.`
      );
    }

    if (bestSellingCrops.length > 0) {
      insights.push(
        `${bestSellingCrops[0].cropName} is currently your best-selling crop.`
      );
    }

    if (deliveredOrders > 0) {
      insights.push(
        `You have successfully delivered ${deliveredOrders} order(s).`
      );
    }

    if (totalRevenue === 0) {
      insights.push(
        "Start selling crops to generate your first sales."
      );
    } else {
      insights.push(
        `Your total completed sales revenue is ₹${totalRevenue.toLocaleString(
          "en-IN"
        )}.`
      );
    }

    res.json({
      success: true,
      analytics: {
        totalRevenue,
        totalOrders,
        deliveredOrders,
        pendingOrders,
        activeCrops,
        soldCrops,
        monthlySales: chartData,
        bestSellingCrops,
        insights,
      },
    });
  } catch (error) {
    console.error("Analytics error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to load analytics",
    });
  }
});

module.exports = router;
