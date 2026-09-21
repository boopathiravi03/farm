const mongoose = require("mongoose");

const marketPriceSchema = new mongoose.Schema(
  {
    city: {
      type: String,
      required: true,
      default: "Chennai",
      index: true,
    },

    market: {
      type: String,
      default: "Chennai",
    },

    cropName: {
      type: String,
      required: true,
      index: true,
    },

    normalizedName: {
      type: String,
      required: true,
      index: true,
    },

    price: {
      type: Number,
      required: true,
    },

    retailMin: {
      type: Number,
      default: null,
    },

    retailMax: {
      type: Number,
      default: null,
    },

    unit: {
      type: String,
      default: "kg",
    },

    source: {
      type: String,
      default: "https://www.vegetablemarketprice.com/market/chennai/today",
    },

    sourceUpdatedAt: {
      type: Date,
      default: null,
    },

    fetchedAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  },
);

marketPriceSchema.index({
  normalizedName: 1,
  city: 1,
});

module.exports = mongoose.model("MarketPrice", marketPriceSchema);
