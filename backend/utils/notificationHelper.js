const Notification = require("../models/Notification");

async function createNotification({
  io,
  userId,
  title,
  message,
  type,
  relatedId = null,
}) {
  try {
    const notification = await Notification.create({
      user: userId,
      title,
      message,
      type,
      relatedId,
    });

    // Send notification instantly
    if (io) {
      io.to(`user_${userId}`).emit(
        "newNotification",
        notification
      );
    }

    return notification;
  } catch (error) {
    console.error(
      "Notification creation failed:",
      error.message
    );
  }
}

module.exports = createNotification;
