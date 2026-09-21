const MarketPrice = require("../models/MarketPrice");

// Generate realistic recent 7 days history relative to today
function generateRecentHistory(basePrice, trend) {
  const history = [];
  const now = new Date();

  for (let i = 6; i >= 0; i--) {
    const d = new Date(now);
    d.setDate(d.getDate() - i);
    d.setHours(8, 0, 0, 0);

    let price = basePrice;
    if (trend === "up") {
      price = Math.max(1, Math.round(basePrice - (i * 1.2)));
    } else if (trend === "down") {
      price = Math.round(basePrice + (i * 1.2));
    } else {
      const variance = (i % 2 === 0 ? 1 : -1) * (i > 3 ? 1 : 0);
      price = Math.max(1, basePrice + variance);
    }

    history.push({
      date: d,
      price,
    });
  }

  return history;
}

const DEFAULT_CHENNAI_CROPS = [
  {
    cropName: "Tomato",
    category: "Vegetables",
    market: "Chennai",
    marketPrice: 30,
    retailMin: 34,
    retailMax: 40,
    unit: "kg",
    priceTrend: "stable",
    historicalPrices: generateRecentHistory(30, "stable"),
  },
  {
    cropName: "Tomato Hybrid",
    category: "Vegetables",
    market: "Chennai",
    marketPrice: 32,
    retailMin: 36,
    retailMax: 42,
    unit: "kg",
    priceTrend: "up",
    historicalPrices: generateRecentHistory(32, "up"),
  },
  {
    cropName: "Tomato Local",
    category: "Vegetables",
    market: "Chennai",
    marketPrice: 28,
    retailMin: 32,
    retailMax: 36,
    unit: "kg",
    priceTrend: "down",
    historicalPrices: generateRecentHistory(28, "down"),
  },
  {
    cropName: "Onion Big",
    category: "Vegetables",
    market: "Chennai",
    marketPrice: 35,
    retailMin: 40,
    retailMax: 48,
    unit: "kg",
    priceTrend: "up",
    historicalPrices: generateRecentHistory(35, "up"),
  },
  {
    cropName: "Onion Small (Shallot)",
    category: "Vegetables",
    market: "Chennai",
    marketPrice: 55,
    retailMin: 65,
    retailMax: 78,
    unit: "kg",
    priceTrend: "stable",
    historicalPrices: generateRecentHistory(55, "stable"),
  },
  {
    cropName: "Potato",
    category: "Vegetables",
    market: "Chennai",
    marketPrice: 28,
    retailMin: 32,
    retailMax: 38,
    unit: "kg",
    priceTrend: "stable",
    historicalPrices: generateRecentHistory(28, "stable"),
  },
  {
    cropName: "Green Chilli",
    category: "Vegetables",
    market: "Chennai",
    marketPrice: 45,
    retailMin: 52,
    retailMax: 60,
    unit: "kg",
    priceTrend: "up",
    historicalPrices: generateRecentHistory(45, "up"),
  },
  {
    cropName: "Brinjal (Eggplant)",
    category: "Vegetables",
    market: "Chennai",
    marketPrice: 35,
    retailMin: 40,
    retailMax: 48,
    unit: "kg",
    priceTrend: "down",
    historicalPrices: generateRecentHistory(35, "down"),
  },
  {
    cropName: "Carrot",
    category: "Vegetables",
    market: "Chennai",
    marketPrice: 50,
    retailMin: 58,
    retailMax: 68,
    unit: "kg",
    priceTrend: "stable",
    historicalPrices: generateRecentHistory(50, "stable"),
  },
  {
    cropName: "Cabbage",
    category: "Vegetables",
    market: "Chennai",
    marketPrice: 22,
    retailMin: 26,
    retailMax: 32,
    unit: "kg",
    priceTrend: "stable",
    historicalPrices: generateRecentHistory(22, "stable"),
  },
  {
    cropName: "Cauliflower",
    category: "Vegetables",
    market: "Chennai",
    marketPrice: 38,
    retailMin: 44,
    retailMax: 52,
    unit: "kg",
    priceTrend: "up",
    historicalPrices: generateRecentHistory(38, "up"),
  },
  {
    cropName: "Lady's Finger (Okra)",
    category: "Vegetables",
    market: "Chennai",
    marketPrice: 32,
    retailMin: 38,
    retailMax: 45,
    unit: "kg",
    priceTrend: "stable",
    historicalPrices: generateRecentHistory(32, "stable"),
  },
  {
    cropName: "Drumstick",
    category: "Vegetables",
    market: "Chennai",
    marketPrice: 65,
    retailMin: 75,
    retailMax: 90,
    unit: "kg",
    priceTrend: "down",
    historicalPrices: generateRecentHistory(65, "down"),
  },
  {
    cropName: "Ginger",
    category: "Vegetables",
    market: "Chennai",
    marketPrice: 120,
    retailMin: 140,
    retailMax: 165,
    unit: "kg",
    priceTrend: "up",
    historicalPrices: generateRecentHistory(120, "up"),
  },
  {
    cropName: "Garlic",
    category: "Vegetables",
    market: "Chennai",
    marketPrice: 160,
    retailMin: 185,
    retailMax: 220,
    unit: "kg",
    priceTrend: "up",
    historicalPrices: generateRecentHistory(160, "up"),
  },
  {
    cropName: "Banana Raw",
    category: "Vegetables",
    market: "Chennai",
    marketPrice: 25,
    retailMin: 30,
    retailMax: 36,
    unit: "kg",
    priceTrend: "stable",
    historicalPrices: generateRecentHistory(25, "stable"),
  },
  {
    cropName: "Coconut",
    category: "Produce",
    market: "Chennai",
    marketPrice: 32,
    retailMin: 36,
    retailMax: 42,
    unit: "piece",
    priceTrend: "stable",
    historicalPrices: generateRecentHistory(32, "stable"),
  },
];

class MarketPriceService {
  async initialize() {
    try {
      const count = await MarketPrice.countDocuments();
      if (count === 0) {
        console.log("🌱 Seeding initial Chennai market prices...");
        await MarketPrice.insertMany(DEFAULT_CHENNAI_CROPS);
        console.log("✅ Chennai market prices seeded successfully");
      }
    } catch (error) {
      console.error("Failed to initialize market prices in DB, using in-memory dataset:", error.message);
    }
  }

  async getAllChennaiPrices() {
    try {
      const dbPrices = await MarketPrice.find({ market: "Chennai" }).sort({ cropName: 1 });
      if (dbPrices && dbPrices.length > 0) {
        return dbPrices;
      }
    } catch (e) {
      console.warn("DB fetch failed, falling back to memory:", e.message);
    }
    return DEFAULT_CHENNAI_CROPS;
  }

  async searchCrops(query) {
    if (!query || query.trim().length < 2) {
      return [];
    }

    const cleanQuery = query.trim().toLowerCase();

    try {
      const regex = new RegExp(cleanQuery, "i");
      const dbResults = await MarketPrice.find({
        market: "Chennai",
        cropName: { $regex: regex },
      })
        .limit(10)
        .lean();

      if (dbResults && dbResults.length > 0) {
        return dbResults.map((item) => ({
          cropName: item.cropName,
          market: item.market,
          marketPrice: item.marketPrice,
          retailRange: `₹${item.retailMin}–${item.retailMax} / ${item.unit}`,
          suggestedPrice: this.calculateSuggestedPrice(item.marketPrice, "Good", 100).suggestedPrice,
          unit: item.unit,
          priceTrend: item.priceTrend,
        }));
      }
    } catch (e) {
      console.warn("DB search failed, falling back to memory:", e.message);
    }

    return DEFAULT_CHENNAI_CROPS.filter((c) =>
      c.cropName.toLowerCase().includes(cleanQuery)
    ).map((item) => ({
      cropName: item.cropName,
      market: item.market,
      marketPrice: item.marketPrice,
      retailRange: `₹${item.retailMin}–${item.retailMax} / ${item.unit}`,
      suggestedPrice: this.calculateSuggestedPrice(item.marketPrice, "Good", 100).suggestedPrice,
      unit: item.unit,
      priceTrend: item.priceTrend,
    }));
  }

  calculateSuggestedPrice(basePrice, quality = "Good", quantity = 100) {
    let qualityAdjustment = 0;
    if (quality === "Good") qualityAdjustment = 2;
    else if (quality === "Poor") qualityAdjustment = -3;
    else qualityAdjustment = 0; // Medium

    let quantityAdjustment = 0;
    const qty = Number(quantity) || 100;
    if (qty >= 1000) quantityAdjustment = -2;
    else if (qty >= 300) quantityAdjustment = -1;
    else if (qty < 50) quantityAdjustment = 1;

    const suggestedPrice = Math.max(1, basePrice + qualityAdjustment + quantityAdjustment);

    return {
      baseMarketPrice: basePrice,
      qualityAdjustment,
      quantityAdjustment,
      suggestedPrice,
      disclaimer: "Estimated selling price — not a guaranteed market price. Actual prices vary by buyer and mandi conditions.",
    };
  }

  async getCropDetails(cropName, quality = "Good", quantity = 100) {
    const cleanName = cropName.trim().toLowerCase();

    let crop = null;
    try {
      crop = await MarketPrice.findOne({
        cropName: { $regex: new RegExp(`^${cleanName}$`, "i") },
      }).lean();
    } catch (e) {
      console.warn("DB lookup error:", e.message);
    }

    if (!crop) {
      crop = DEFAULT_CHENNAI_CROPS.find(
        (c) => c.cropName.toLowerCase() === cleanName
      );
    }

    if (!crop) {
      return null;
    }

    const pricing = this.calculateSuggestedPrice(crop.marketPrice, quality, quantity);

    return {
      cropName: crop.cropName,
      category: crop.category,
      market: crop.market || "Chennai",
      marketPrice: crop.marketPrice,
      retailMin: crop.retailMin,
      retailMax: crop.retailMax,
      retailRange: `₹${crop.retailMin}–${crop.retailMax} / ${crop.unit}`,
      unit: crop.unit,
      priceTrend: crop.priceTrend,
      source: crop.source || "Tamil Nadu Market Intelligence / Koyambedu Market",
      suggestedPrice: pricing.suggestedPrice,
      pricingBreakdown: pricing,
      historicalPrices: crop.historicalPrices || [],
      lastUpdated: crop.lastUpdated || new Date(),
    };
  }
}

module.exports = new MarketPriceService();
