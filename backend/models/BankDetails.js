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
      trim: true,
    },

    bankName: {
      type: String,
      required: true,
      trim: true,
    },

    accountNumber: {
      type: String,
      required: true,
      trim: true,
      select: false,
    },

    ifscCode: {
    ifsc: {
      type: String,
      required: true,
      trim: true,
      uppercase: true,
    },

    upiId: {
      type: String,
      trim: true,
      lowercase: true,
      default: "",
    },

    isVerified: {
      type: Boolean,
      default: true,
      default: false,
    },
  },
  {
    timestamps: true,
  },
  }
);

// Helper to mask account number for secure responses
bankDetailsSchema.methods.toSafeObject = function () {
  const rawAcc = this.accountNumber || "";
  const lastFour = rawAcc.slice(-4);
  const maskedAcc =
    rawAcc.length > 4
      ? "•".repeat(Math.max(4, rawAcc.length - 4)) + lastFour
      : rawAcc;

  return {
    id: this._id,
    accountHolderName: this.accountHolderName,
    bankName: this.bankName,
    maskedAccountNumber: maskedAcc,
    lastFourDigits: lastFour,
    ifscCode: this.ifscCode,
    upiId: this.upiId || "",
    isVerified: this.isVerified,
    updatedAt: this.updatedAt,
  };
};

module.exports = mongoose.model("BankDetails", bankDetailsSchema);
module.exports = mongoose.model(
  "BankDetails",
  bankDetailsSchema
);
