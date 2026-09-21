const express = require("express");

const Order = require("../models/Order");
const Crop = require("../models/Crop");
const protect = require("../middleware/authMiddleware");

const router = express.Router();

// Place order
router.post("/", protect, async (req, res) => {
  try {
    const { cropId, quantity, deliveryAddress } = req.body;

    if (!cropId || !quantity || !deliveryAddress) {
      return res.status(400).json({
        message: "Crop, quantity and delivery address are required",
      });
    }

    const crop = await Crop.findById(cropId);

    if (!crop) {
      return res.status(404).json({
        message: "Crop not found",
      });
    }

    if (crop.status !== "available") {
      return res.status(400).json({
        message: "This crop is not available",
      });
    }

    if (quantity > crop.quantity) {
      return res.status(400).json({
        message: "Not enough crop quantity available",
      });
    }

    const totalAmount = Number(quantity) * Number(crop.price);

    const order = await Order.create({
      buyer: req.user.id,
      farmer: crop.farmer,
      crop: crop._id,
      quantity,
      pricePerUnit: crop.price,
      totalAmount,
      deliveryAddress,
    });

    res.status(201).json({
      message: "Order placed successfully",
      order,
    });
  } catch (error) {
    res.status(500).json({
      message: "Failed to place order",
      error: error.message,
    });
  }
});

// Get buyer orders
router.get("/my-orders", protect, async (req, res) => {
  try {
    const orders = await Order.find({
      buyer: req.user.id,
    })
      .populate("crop", "cropName image")
      .populate("farmer", "name location")
      .sort({ createdAt: -1 });

    res.json(orders);
  } catch (error) {
    res.status(500).json({
      message: "Failed to fetch orders",
      error: error.message,
    });
  }
});

// Get farmer orders
router.get("/farmer-orders", protect, async (req, res) => {
  try {
    const orders = await Order.find({
      farmer: req.user.id,
    })
      .populate("crop", "cropName image")
      .populate("buyer", "name email phone")
      .sort({ createdAt: -1 });

    res.json(orders);
  } catch (error) {
    res.status(500).json({
      message: "Failed to fetch farmer orders",
      error: error.message,
    });
  }
});

// Update order status
router.put("/:id/status", protect, async (req, res) => {
  try {
    const { status } = req.body;

    const allowedStatuses = [
      "accepted",
      "rejected",
      "processing",
      "shipped",
      "delivered",
      "cancelled",
    ];

    if (!allowedStatuses.includes(status)) {
      return res.status(400).json({
        message: "Invalid order status",
      });
    }

    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({
        message: "Order not found",
      });
    }

    const isBuyer = order.buyer.toString() === req.user.id;

    const isFarmer = order.farmer.toString() === req.user.id;

    if (!isBuyer && !isFarmer) {
      return res.status(403).json({
        message: "You are not allowed to update this order",
      });
    }

    // When accepting an order, decrement crop quantity
    if (status === "accepted" && order.status === "pending") {
      const crop = await Crop.findById(order.crop);

      if (!crop) {
        return res.status(404).json({
          message: "Crop not found",
        });
      }

      if (crop.quantity < order.quantity) {
        return res.status(400).json({
          message: "Insufficient crop quantity",
        });
      }

      crop.quantity -= order.quantity;

      if (crop.quantity === 0) {
        crop.status = "sold";
      }

      await crop.save();
    }

    order.status = status;

    await order.save();

    res.json({
      message: "Order status updated",
      order,
    });
  } catch (error) {
    res.status(500).json({
      message: "Failed to update order",
      error: error.message,
    });
  }
});

module.exports = router;
