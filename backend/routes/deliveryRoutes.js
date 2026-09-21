const express = require("express");

const Delivery = require("../models/Delivery");
const DeliveryHistory = require("../models/DeliveryHistory");
const Order = require("../models/Order");

const authMiddleware = require("../middleware/authMiddleware");
const createNotification = require("../utils/notificationHelper");

const router = express.Router();

// ==========================================
// CREATE DELIVERY
// ==========================================

router.post("/", authMiddleware, async (req, res) => {
  try {
    const { orderId } = req.body;

    const order = await Order.findById(orderId);

    if (!order) {
      return res.status(404).json({
        message: "Order not found",
      });
    }

    // Only farmer can create delivery
    if (order.farmer.toString() !== req.user.id) {
      return res.status(403).json({
        message: "Only the farmer can create delivery",
      });
    }

    // Check existing delivery
    const existingDelivery = await Delivery.findOne({
      order: orderId,
    });

    if (existingDelivery) {
      return res.status(400).json({
        message: "Delivery already exists",
      });
    }

    // Generate tracking ID
    const trackingId =
      "FTD-" + Date.now() + "-" + Math.floor(Math.random() * 10000);

    // Estimated delivery = 3 days
    const estimatedDelivery = new Date();

    estimatedDelivery.setDate(estimatedDelivery.getDate() + 3);

    const delivery = await Delivery.create({
      order: order._id,
      buyer: order.buyer,
      farmer: order.farmer,
      deliveryAddress: order.deliveryAddress,
      trackingId,
      estimatedDelivery,
      status: "processing",
    });

    // First tracking event
    await DeliveryHistory.create({
      delivery: delivery._id,
      status: "processing",
      message: "Your order is being processed.",
      updatedBy: req.user.id,
    });

    res.status(201).json({
      message: "Delivery created successfully",
      delivery,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: "Failed to create delivery",
    });
  }
});

// ==========================================
// GET DELIVERY BY ORDER
// ==========================================

router.get("/order/:orderId", authMiddleware, async (req, res) => {
  try {
    const order = await Order.findById(req.params.orderId);

    if (!order) {
      return res.status(404).json({
        message: "Order not found",
      });
    }

    const isBuyer = order.buyer.toString() === req.user.id;

    const isFarmer = order.farmer.toString() === req.user.id;

    if (!isBuyer && !isFarmer) {
      return res.status(403).json({
        message: "You are not authorized",
      });
    }

    const delivery = await Delivery.findOne({
      order: req.params.orderId,
    });

    if (!delivery) {
      return res.status(404).json({
        message: "Delivery has not been created yet",
      });
    }

    const history = await DeliveryHistory.find({
      delivery: delivery._id,
    }).sort({ timestamp: 1 });

    res.json({
      delivery,
      history,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: "Failed to get delivery",
    });
  }
});

// ==========================================
// UPDATE DELIVERY STATUS
// ==========================================

router.put("/:id/status", authMiddleware, async (req, res) => {
  try {
    const { status } = req.body;

    const validStatuses = [
      "processing",
      "packed",
      "shipped",
      "out_for_delivery",
      "delivered",
    ];

    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        message: "Invalid delivery status",
      });
    }

    const delivery = await Delivery.findById(req.params.id);

    if (!delivery) {
      return res.status(404).json({
        message: "Delivery not found",
      });
    }

    // Only farmer can update delivery
    if (delivery.farmer.toString() !== req.user.id) {
      return res.status(403).json({
        message: "Only the farmer can update delivery",
      });
    }

    delivery.status = status;

    if (status === "delivered") {
      delivery.deliveredAt = new Date();
    }

    await delivery.save();

    // Update order status
    const order = await Order.findById(delivery.order);

    if (order) {
      order.status = status;
      await order.save();
    }

    // Status message
    const messages = {
      processing: "Your order is being processed.",
      packed: "Your order has been packed.",
      shipped: "Your order has been shipped.",
      out_for_delivery: "Your order is out for delivery.",
      delivered: "Your order has been delivered successfully.",
    };

    // Save tracking history
    await DeliveryHistory.create({
      delivery: delivery._id,
      status,
      message: messages[status],
      updatedBy: req.user.id,
    });

    // Notify buyer
    await createNotification({
      io: req.app.get("io"),
      userId: delivery.buyer,
      title: "Delivery Update 🚚",
      message: messages[status],
      type: "order",
      relatedId: delivery.order,
    });

    res.json({
      message: "Delivery status updated",
      delivery,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: "Failed to update delivery",
    });
  }
});

module.exports = router;
