const mongoose = require("mongoose");

const historicalPriceSchema = new mongoose.Schema(
const marketPriceSchema = new mongoose.Schema(
  {
    date: {
      type: Date,
    city: {
      type: String,
      required: true,
      default: "Chennai",
      index: true,
    },
    price: {
      type: Number,
      required: true,

    market: {
      type: String,
      default: "Chennai",
    },
  },
  { _id: false },
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
    normalizedName: {
      type: String,
      default: "Vegetables",
      required: true,
      index: true,
    },

    market: {
      type: String,
      default: "Chennai",
    },

    marketPrice: {
    price: {
      type: Number,
      required: true,
    },

    retailMin: {
      type: Number,
      required: true,
      default: null,
    },

    retailMax: {
      type: Number,
      required: true,
      default: null,
    },

    unit: {
      type: String,
      default: "kg",
    },

    priceTrend: {
    source: {
      type: String,
      enum: ["up", "down", "stable"],
      default: "stable",
      default:
        "https://www.vegetablemarketprice.com/market/chennai/today",
    },

    source: {
      type: String,
      default: "Tamil Nadu Market Intelligence / Koyambedu Market",
    sourceUpdatedAt: {
      type: Date,
      default: null,
    },

    historicalPrices: [historicalPriceSchema],

    lastUpdated: {
    fetchedAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  },
  }
);

marketPriceSchema.index({
  normalizedName: 1,
  city: 1,
});

module.exports = mongoose.model("MarketPrice", marketPriceSchema);
