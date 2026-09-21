const express = require("express");

const Negotiation = require("../models/Negotiation");
const Offer = require("../models/Offer");
const Crop = require("../models/Crop");
const protect = require("../middleware/authMiddleware");
const createNotification = require("../utils/notificationHelper");

const router = express.Router();

// Start negotiation
router.post("/", protect, async (req, res) => {
  try {
    const { cropId, quantity, offerPrice, message } = req.body;

    if (!cropId || !quantity || !offerPrice) {
      return res.status(400).json({
        message: "Crop, quantity and offer price are required",
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
        message: "Requested quantity is not available",
      });
    }

    const negotiation = await Negotiation.create({
      crop: crop._id,
      buyer: req.user.id,
      farmer: crop.farmer,
      quantity,
      currentPrice: offerPrice,
    });

    await Offer.create({
      negotiation: negotiation._id,
      sender: req.user.id,
      price: offerPrice,
      message: message || "Initial offer",
    });

    const io = req.app.get("io");

    await createNotification({
      io,
      userId: negotiation.farmer,
      title: "New Price Offer 💰",
      message: `A buyer made a new offer of ₹${offerPrice}.`,
      type: "negotiation",
      relatedId: negotiation._id,
    });

    res.status(201).json({
      message: "Negotiation started",
      negotiation,
    });
  } catch (error) {
    res.status(500).json({
      message: "Failed to start negotiation",
      error: error.message,
    });
  }
});

// Send counter offer
router.post("/:id/offer", protect, async (req, res) => {
  try {
    const { price, message } = req.body;

    if (!price) {
      return res.status(400).json({
        message: "Offer price is required",
      });
    }

    const negotiation = await Negotiation.findById(req.params.id);

    if (!negotiation) {
      return res.status(404).json({
        message: "Negotiation not found",
      });
    }

    const isBuyer = negotiation.buyer.toString() === req.user.id;

    const isFarmer = negotiation.farmer.toString() === req.user.id;

    if (!isBuyer && !isFarmer) {
      return res.status(403).json({
        message: "You are not part of this negotiation",
      });
    }

    if (negotiation.status !== "active") {
      return res.status(400).json({
        message: "Negotiation is no longer active",
      });
    }

    const offer = await Offer.create({
      negotiation: negotiation._id,
      sender: req.user.id,
      price,
      message: message || "",
    });

    negotiation.currentPrice = price;
    await negotiation.save();

    const receiverId =
      req.user.id === negotiation.buyer.toString()
        ? negotiation.farmer
        : negotiation.buyer;

    await createNotification({
      io: req.app.get("io"),
      userId: receiverId,
      title: "New Negotiation Offer 💰",
      message: `You received a new price offer of ₹${price}.`,
      type: "negotiation",
      relatedId: negotiation._id,
    });

    res.status(201).json({
      message: "Offer sent successfully",
      offer,
    });
  } catch (error) {
    res.status(500).json({
      message: "Failed to send offer",
      error: error.message,
    });
  }
});

// Get negotiation details
router.get("/:id", protect, async (req, res) => {
  try {
    const negotiation = await Negotiation.findById(req.params.id)
      .populate("crop", "cropName price quantity image")
      .populate("buyer", "name email")
      .populate("farmer", "name email");

    if (!negotiation) {
      return res.status(404).json({
        message: "Negotiation not found",
      });
    }

    const isBuyer = negotiation.buyer._id.toString() === req.user.id;

    const isFarmer = negotiation.farmer._id.toString() === req.user.id;

    if (!isBuyer && !isFarmer) {
      return res.status(403).json({
        message: "Access denied",
      });
    }

    const offers = await Offer.find({
      negotiation: negotiation._id,
    })
      .populate("sender", "name role")
      .sort({ createdAt: 1 });

    res.json({
      negotiation,
      offers,
    });
  } catch (error) {
    res.status(500).json({
      message: "Failed to load negotiation",
      error: error.message,
    });
  }
});

// Accept offer
router.put("/:id/accept", protect, async (req, res) => {
  try {
    const negotiation = await Negotiation.findById(req.params.id);

    if (!negotiation) {
      return res.status(404).json({
        message: "Negotiation not found",
      });
    }

    const isBuyer = negotiation.buyer.toString() === req.user.id;

    const isFarmer = negotiation.farmer.toString() === req.user.id;

    if (!isBuyer && !isFarmer) {
      return res.status(403).json({
        message: "Access denied",
      });
    }

    if (negotiation.status !== "active") {
      return res.status(400).json({
        message: "Negotiation is already closed",
      });
    }

    negotiation.status = "accepted";
    await negotiation.save();

    await Offer.updateMany(
      { negotiation: negotiation._id },
      { status: "accepted" },
    );

    const receiverId =
      req.user.id === negotiation.buyer.toString()
        ? negotiation.farmer
        : negotiation.buyer;

    await createNotification({
      io: req.app.get("io"),
      userId: receiverId,
      title: "Negotiation Accepted ✅",
      message: "Your negotiated deal has been accepted.",
      type: "negotiation",
      relatedId: negotiation._id,
    });

    res.json({
      message: "Offer accepted successfully",
      negotiation,
    });
  } catch (error) {
    res.status(500).json({
      message: "Failed to accept offer",
      error: error.message,
    });
  }
});

// Reject negotiation
router.put("/:id/reject", protect, async (req, res) => {
  try {
    const negotiation = await Negotiation.findById(req.params.id);

    if (!negotiation) {
      return res.status(404).json({
        message: "Negotiation not found",
      });
    }

    const isBuyer = negotiation.buyer.toString() === req.user.id;

    const isFarmer = negotiation.farmer.toString() === req.user.id;

    if (!isBuyer && !isFarmer) {
      return res.status(403).json({
        message: "Access denied",
      });
    }

    negotiation.status = "rejected";
    await negotiation.save();

    await Offer.updateMany(
      { negotiation: negotiation._id },
      { status: "rejected" },
    );

    res.json({
      message: "Negotiation rejected",
    });
  } catch (error) {
    res.status(500).json({
      message: "Failed to reject negotiation",
      error: error.message,
    });
  }
});

module.exports = router;
