const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");

const {
  getChennaiPrices,
  refreshChennaiPrices,
  normalizeName,
} = require("../services/marketPriceService");

const router = express.Router();

// =====================================================
// ALL CHENNAI PRICES
// =====================================================

router.get("/chennai", authMiddleware, async (req, res) => {
  try {
    const prices = await getChennaiPrices();

    res.json({
      success: true,
      city: "Chennai",
      count: prices.length,
      lastUpdated:
        prices.length > 0
          ? prices.reduce(
              (latest, item) =>
                !latest || item.fetchedAt > latest ? item.fetchedAt : latest,
              null,
            )
          : null,
      prices,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Unable to load market prices",
    });
  }
});

// =====================================================
// SEARCH CROP
// Minimum 2 characters
// =====================================================

router.get("/search", authMiddleware, async (req, res) => {
  try {
    const query = String(req.query.q || "")
      .trim()
      .toLowerCase();

    if (query.length < 2) {
      return res.json({
        success: true,
        prices: [],
      });
    }

    const prices = await getChennaiPrices();

    const results = prices
      .filter((item) => item.normalizedName.includes(query))
      .slice(0, 10);

    res.json({
      success: true,
      query,
      count: results.length,
      prices: results,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Crop search failed",
    });
  }
});

// =====================================================
// GET ONE CROP
// =====================================================

router.get("/:cropName", authMiddleware, async (req, res) => {
  try {
    const cropName = normalizeName(decodeURIComponent(req.params.cropName));

    const prices = await getChennaiPrices();

    const result = prices.find(
      (item) =>
        item.normalizedName === cropName ||
        item.normalizedName.includes(cropName),
    );

    if (!result) {
      return res.status(404).json({
        success: false,
        message: "Market price not found",
      });
    }

    res.json({
      success: true,
      price: result,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Unable to find crop price",
    });
  }
});

// =====================================================
// FORCE REFRESH
// =====================================================

router.post("/refresh", authMiddleware, async (req, res) => {
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
});

module.exports = router;
