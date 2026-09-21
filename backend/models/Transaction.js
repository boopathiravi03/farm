const mongoose = require("mongoose");

const transactionSchema = new mongoose.Schema(
  {
    payment: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Payment",
      required: true,
    },

    order: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Order",
      required: true,
    },

    buyer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    farmer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    amount: {
      type: Number,
      required: true,
    },

    type: {
      type: String,
      enum: ["purchase", "refund"],
      default: "purchase",
    },

    status: {
      type: String,
      enum: ["completed", "pending", "failed"],
      default: "completed",
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model(
  "Transaction",
  transactionSchema
);
