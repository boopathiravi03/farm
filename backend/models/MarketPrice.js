const mongoose = require("mongoose");

const historicalPriceSchema = new mongoose.Schema(
  {
    date: {
      type: Date,
      required: true,
    },
    price: {
      type: Number,
      required: true,
    },
  },
  { _id: false }
);

const marketPriceSchema = new mongoose.Schema(
  {
    cropName: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true,
    },

    category: {
      type: String,
      default: "Vegetables",
    },

    market: {
      type: String,
      default: "Chennai",
    },

    marketPrice: {
      type: Number,
      required: true,
    },

    retailMin: {
      type: Number,
      required: true,
    },

    retailMax: {
      type: Number,
      required: true,
    },

    unit: {
      type: String,
      default: "kg",
    },

    priceTrend: {
      type: String,
      enum: ["up", "down", "stable"],
      default: "stable",
    },

    source: {
      type: String,
      default: "Tamil Nadu Market Intelligence / Koyambedu Market",
    },

    historicalPrices: [historicalPriceSchema],

    lastUpdated: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("MarketPrice", marketPriceSchema);
