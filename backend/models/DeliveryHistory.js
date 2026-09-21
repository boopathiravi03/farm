const mongoose = require("mongoose");

const deliveryHistorySchema = new mongoose.Schema(
  {
    delivery: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Delivery",
      required: true,
    },

    status: {
      type: String,
      required: true,
    },

    message: {
      type: String,
      required: true,
    },

    updatedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    timestamp: {
      type: Date,
      default: Date.now,
    },
  }
);

module.exports = mongoose.model(
  "DeliveryHistory",
  deliveryHistorySchema
);
