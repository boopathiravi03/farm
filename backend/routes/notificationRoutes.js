const express = require("express");
const Notification = require("../models/Notification");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// Get user's notifications
router.get("/", authMiddleware, async (req, res) => {
  try {
    const notifications = await Notification.find({
      user: req.user.id,
    })
      .sort({ createdAt: -1 })
      .limit(50);

    res.json(notifications);
  } catch (error) {
    res.status(500).json({
      message: "Failed to get notifications",
    });
  }
});

// Get unread notification count
router.get("/unread-count", authMiddleware, async (req, res) => {
  try {
    const count = await Notification.countDocuments({
      user: req.user.id,
      isRead: false,
    });

    res.json({ count });
  } catch (error) {
    res.status(500).json({
      message: "Failed to get unread count",
    });
  }
});

// Mark one notification as read
router.put("/:id/read", authMiddleware, async (req, res) => {
  try {
    const notification = await Notification.findOneAndUpdate(
      {
        _id: req.params.id,
        user: req.user.id,
      },
      {
        isRead: true,
      },
      {
        new: true,
      },
    );

    if (!notification) {
      return res.status(404).json({
        message: "Notification not found",
      });
    }

    res.json(notification);
  } catch (error) {
    res.status(500).json({
      message: "Failed to mark notification as read",
    });
  }
});

// Mark all notifications as read
router.put("/read-all", authMiddleware, async (req, res) => {
  try {
    await Notification.updateMany(
      {
        user: req.user.id,
        isRead: false,
      },
      {
        isRead: true,
      },
    );

    res.json({
      message: "All notifications marked as read",
    });
  } catch (error) {
    res.status(500).json({
      message: "Failed to update notifications",
    });
  }
});

module.exports = router;
