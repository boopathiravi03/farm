const mongoose = require("mongoose");

const bankDetailsSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true,
    },

    accountHolderName: {
      type: String,
      required: true,
    },

    bankName: {
      type: String,
      required: true,
    },

    accountNumber: {
      type: String,
      required: true,
      select: false,
    },

    ifsc: {
      type: String,
      required: true,
      uppercase: true,
    },

    upiId: {
      type: String,
      default: "",
    },

    isVerified: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  },
);

module.exports = mongoose.model("BankDetails", bankDetailsSchema);
