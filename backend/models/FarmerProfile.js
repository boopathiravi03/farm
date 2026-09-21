const mongoose = require("mongoose");

const farmerProfileSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true,
    },

    profileImage: {
      type: String,
      default: "",
    },

    farmName: {
      type: String,
      default: "",
    },

    farmSize: {
      type: Number,
      default: null,
    },

    farmSizeUnit: {
      type: String,
      default: "acre",
    },

    address: {
      type: String,
      default: "",
    },

    village: {
      type: String,
      default: "",
    },

    district: {
      type: String,
      default: "",
    },

    state: {
      type: String,
      default: "Tamil Nadu",
    },

    pincode: {
      type: String,
      default: "",
    },

    about: {
      type: String,
      default: "",
    },
  },
  {
    timestamps: true,
  },
);

module.exports = mongoose.model("FarmerProfile", farmerProfileSchema);
