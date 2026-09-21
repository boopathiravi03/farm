const express = require("express");
const Payment = require("../models/Payment");
const Transaction = require("../models/Transaction");
const Order = require("../models/Order");

const authMiddleware = require("../middleware/authMiddleware");
const createNotification = require("../utils/notificationHelper");

const router = express.Router();

// ==========================================
// CREATE PAYMENT
// ==========================================

router.post("/", authMiddleware, async (req, res) => {
  try {
    const { orderId, paymentMethod } = req.body;

    if (!orderId || !paymentMethod) {
      return res.status(400).json({
        message: "Order ID and payment method are required",
      });
    }

    const order = await Order.findById(orderId);

    if (!order) {
      return res.status(404).json({
        message: "Order not found",
      });
    }

    // Only buyer can make payment
    if (order.buyer.toString() !== req.user.id) {
      return res.status(403).json({
        message: "Only the buyer can make payment",
      });
    }

    // Prevent duplicate successful payments
    const existingPayment = await Payment.findOne({
      order: orderId,
      status: "success",
    });

    if (existingPayment) {
      return res.status(400).json({
        message: "Order is already paid",
      });
    }

    // Generate demo transaction ID
    const transactionId =
      "FTX-" + Date.now() + "-" + Math.floor(Math.random() * 10000);

    // Create payment
    const payment = await Payment.create({
      order: order._id,
      buyer: order.buyer,
      farmer: order.farmer,
      amount: order.totalAmount,
      paymentMethod,
      transactionId,
      status: "success",
      paidAt: new Date(),
    });

    // Create transaction
    const transaction = await Transaction.create({
      payment: payment._id,
      order: order._id,
      buyer: order.buyer,
      farmer: order.farmer,
      amount: order.totalAmount,
      type: "purchase",
      status: "completed",
    });

    // Update order
    order.status = "processing";
    await order.save();

    // Notify farmer
    await createNotification({
      io: req.app.get("io"),
      userId: order.farmer,
      title: "Payment Received 💰",
      message: `Payment of ₹${order.totalAmount} has been received for an order.`,
      type: "order",
      relatedId: order._id,
    });

    res.status(201).json({
      message: "Payment successful",
      payment,
      transaction,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: "Payment failed",
    });
  }
});

// ==========================================
// BUYER PAYMENT HISTORY
// ==========================================

router.get("/my-payments", authMiddleware, async (req, res) => {
  try {
    const payments = await Payment.find({
      buyer: req.user.id,
    })
      .populate("order")
      .sort({ createdAt: -1 });

    res.json(payments);
  } catch (error) {
    res.status(500).json({
      message: "Failed to get payment history",
    });
  }
});

// ==========================================
// FARMER EARNINGS
// ==========================================

router.get("/farmer-earnings", authMiddleware, async (req, res) => {
  try {
    const transactions = await Transaction.find({
      farmer: req.user.id,
      status: "completed",
      type: "purchase",
    })
      .populate("order")
      .sort({ createdAt: -1 });

    const totalEarnings = transactions.reduce(
      (total, transaction) => total + transaction.amount,
      0,
    );

    res.json({
      totalEarnings,
      transactions,
    });
  } catch (error) {
    res.status(500).json({
      message: "Failed to get farmer earnings",
    });
  }
});

// ==========================================
// GET PAYMENT BY ORDER
// ==========================================

router.get("/order/:orderId", authMiddleware, async (req, res) => {
  try {
    const payment = await Payment.findOne({
      order: req.params.orderId,
    });

    if (!payment) {
      return res.status(404).json({
        message: "Payment not found",
      });
    }

    res.json(payment);
  } catch (error) {
    res.status(500).json({
      message: "Failed to get payment",
    });
  }
});

module.exports = router;
