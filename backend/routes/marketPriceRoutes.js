const express = require("express");
const marketPriceService = require("../services/marketPriceService");

const router = express.Router();

// ==========================================
// ALL CHENNAI MARKET PRICES
// ==========================================
router.get("/chennai", async (req, res) => {
  try {
    const prices = await marketPriceService.getAllChennaiPrices();

    res.json({
      success: true,
      market: "Chennai",
      count: prices.length,
      source: "Tamil Nadu Market Intelligence / Koyambedu Market",
      prices,
    });
  } catch (error) {
    console.error("Market prices error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch market prices",
    });
  }
});

// ==========================================
// SMART CROP SEARCH (Autocomplete >= 2 chars)
// ==========================================
router.get("/search", async (req, res) => {
  try {
    const { q } = req.query;

    if (!q || q.trim().length < 2) {
      return res.json({
        success: true,
        results: [],
        message: "Type at least 2 characters to search crops",
      });
    }

    const results = await marketPriceService.searchCrops(q);

    res.json({
      success: true,
      query: q.trim(),
      count: results.length,
      results,
    });
  } catch (error) {
    console.error("Crop search error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to search crops",
    });
  }
});

// ==========================================
// CROP DETAILS & PRICING CALCULATOR
// ==========================================
router.get("/:cropName", async (req, res) => {
  try {
    const { cropName } = req.params;
    const { quality = "Good", quantity = 100 } = req.query;

    const details = await marketPriceService.getCropDetails(cropName, quality, quantity);

    if (!details) {
      return res.status(404).json({
        success: false,
        message: `Market price data not found for ${cropName}`,
      });
    }

    res.json({
      success: true,
      data: details,
    });
  } catch (error) {
    console.error("Crop detail error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to retrieve crop pricing details",
    });
  }
});

module.exports = router;
