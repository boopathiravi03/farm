const express = require("express");
const marketPriceService = require("../services/marketPriceService");
const authMiddleware = require("../middleware/authMiddleware");

const {
  getChennaiPrices,
  refreshChennaiPrices,
  normalizeName,
} = require("../services/marketPriceService");

const router = express.Router();

// ==========================================
// ALL CHENNAI MARKET PRICES
// ==========================================
router.get("/chennai", async (req, res) => {
// =====================================================
// ALL CHENNAI PRICES
// =====================================================

router.get("/chennai", authMiddleware, async (req, res) => {
  try {
    const prices = await marketPriceService.getAllChennaiPrices();
    const prices = await getChennaiPrices();

    res.json({
      success: true,
      market: "Chennai",
      city: "Chennai",
      count: prices.length,
      source: "Tamil Nadu Market Intelligence / Koyambedu Market",
      lastUpdated:
        prices.length > 0
          ? prices.reduce(
              (latest, item) =>
                !latest ||
                item.fetchedAt > latest
                  ? item.fetchedAt
                  : latest,
              null
            )
          : null,
      prices,
    });
  } catch (error) {
    console.error("Market prices error:", error);
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch market prices",
      message: "Unable to load market prices",
    });
  }
});

// ==========================================
// SMART CROP SEARCH (Autocomplete >= 2 chars)
// ==========================================
router.get("/search", async (req, res) => {
// =====================================================
// SEARCH CROP
// Minimum 2 characters
// =====================================================

router.get("/search", authMiddleware, async (req, res) => {
  try {
    const { q } = req.query;
    const query = String(req.query.q || "")
      .trim()
      .toLowerCase();

    if (!q || q.trim().length < 2) {
    if (query.length < 2) {
      return res.json({
        success: true,
        results: [],
        message: "Type at least 2 characters to search crops",
        prices: [],
      });
    }

    const results = await marketPriceService.searchCrops(q);
    const prices = await getChennaiPrices();

    const results = prices
      .filter((item) =>
        item.normalizedName.includes(query)
      )
      .slice(0, 10);

    res.json({
      success: true,
      query: q.trim(),
      query,
      count: results.length,
      results,
      prices: results,
    });
  } catch (error) {
    console.error("Crop search error:", error);
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to search crops",
      message: "Crop search failed",
    });
  }
});

// ==========================================
// CROP DETAILS & PRICING CALCULATOR
// ==========================================
router.get("/:cropName", async (req, res) => {
// =====================================================
// GET ONE CROP
// =====================================================

router.get("/:cropName", authMiddleware, async (req, res) => {
  try {
    const { cropName } = req.params;
    const { quality = "Good", quantity = 100 } = req.query;
    const cropName = normalizeName(
      decodeURIComponent(req.params.cropName)
    );

    const details = await marketPriceService.getCropDetails(
      cropName,
      quality,
      quantity,
    const prices = await getChennaiPrices();

    const result = prices.find(
      (item) =>
        item.normalizedName === cropName ||
        item.normalizedName.includes(cropName)
    );

    if (!details) {
    if (!result) {
      return res.status(404).json({
        success: false,
        message: `Market price data not found for ${cropName}`,
        message: "Market price not found",
      });
    }

    res.json({
      success: true,
      data: details,
      price: result,
    });
  } catch (error) {
    console.error("Crop detail error:", error);
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to retrieve crop pricing details",
      message: "Unable to find crop price",
    });
  }
});

// =====================================================
// FORCE REFRESH
// =====================================================

router.post(
  "/refresh",
  authMiddleware,
  async (req, res) => {
    try {
      const prices = await refreshChennaiPrices();

      res.json({
        success: true,
        message: "Market prices refreshed",
        count: prices.length,
      });
    } catch (error) {
      console.error(error);

      res.status(500).json({
        success: false,
        message: "Market price refresh failed",
      });
    }
  }
);

module.exports = router;
