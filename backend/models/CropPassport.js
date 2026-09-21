const mongoose = require("mongoose");

const cropPassportSchema = new mongoose.Schema(
  {
    crop: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Crop",
      required: true,
      unique: true,
    },

    farmer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    passportId: {
      type: String,
      required: true,
      unique: true,
    },

    quality: {
      type: String,
      enum: ["Good", "Medium", "Poor", "Not Tested"],
      default: "Not Tested",
    },

    certification: {
      type: String,
      default: "Farm Trading Verified",
    },

    harvestDate: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  },
);

module.exports = mongoose.model("CropPassport", cropPassportSchema);
