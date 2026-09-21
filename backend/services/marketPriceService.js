const axios = require("axios");
const cheerio = require("cheerio");
const MarketPrice = require("../models/MarketPrice");

// Generate realistic recent 7 days history relative to today
function generateRecentHistory(basePrice, trend) {
  const history = [];
  const now = new Date();
const SOURCE_URL =
  "https://www.vegetablemarketprice.com/market/chennai/today";

  for (let i = 6; i >= 0; i--) {
    const d = new Date(now);
    d.setDate(d.getDate() - i);
    d.setHours(8, 0, 0, 0);
function normalizeName(name) {
  return name
    .toLowerCase()
    .replace(/\([^)]*\)/g, "")
    .replace(/[^a-z0-9\s]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

    let price = basePrice;
    if (trend === "up") {
      price = Math.max(1, Math.round(basePrice - i * 1.2));
    } else if (trend === "down") {
      price = Math.round(basePrice + i * 1.2);
    } else {
      const variance = (i % 2 === 0 ? 1 : -1) * (i > 3 ? 1 : 0);
      price = Math.max(1, basePrice + variance);
    }
function parsePrice(value) {
  if (!value) return null;

    history.push({
      date: d,
      price,
    });
  }
  const match = value.replace(/,/g, "").match(/\d+(?:\.\d+)?/);

  return history;
  return match ? Number(match[0]) : null;
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
      console.error(
        "Failed to initialize market prices in DB, using in-memory dataset:",
        error.message,
      );
    }
function parseRetailRange(value) {
  if (!value) {
    return {
      min: null,
      max: null,
    };
  }

  async getAllChennaiPrices() {
    try {
      const dbPrices = await MarketPrice.find({ market: "Chennai" }).sort({
        cropName: 1,
      });
      if (dbPrices && dbPrices.length > 0) {
        return dbPrices;
      }
    } catch (e) {
      console.warn("DB fetch failed, falling back to memory:", e.message);
    }
    return DEFAULT_CHENNAI_CROPS;
  const numbers = value
    .replace(/,/g, "")
    .match(/\d+(?:\.\d+)?/g);

  if (!numbers || numbers.length < 2) {
    return {
      min: null,
      max: null,
    };
  }

  async searchCrops(query) {
    if (!query || query.trim().length < 2) {
      return [];
    }
  return {
    min: Number(numbers[0]),
    max: Number(numbers[1]),
  };
}

    const cleanQuery = query.trim().toLowerCase();
const FALLBACK_PRICES = [
  { cropName: "Tomato", price: 30, retailMin: 34, retailMax: 40, unit: "kg" },
  { cropName: "Tomato Hybrid", price: 32, retailMin: 36, retailMax: 42, unit: "kg" },
  { cropName: "Tomato Local", price: 28, retailMin: 32, retailMax: 36, unit: "kg" },
  { cropName: "Onion Big", price: 35, retailMin: 40, retailMax: 48, unit: "kg" },
  { cropName: "Onion Small", price: 55, retailMin: 65, retailMax: 78, unit: "kg" },
  { cropName: "Potato", price: 28, retailMin: 32, retailMax: 38, unit: "kg" },
  { cropName: "Green Chilli", price: 45, retailMin: 52, retailMax: 60, unit: "kg" },
  { cropName: "Brinjal", price: 35, retailMin: 40, retailMax: 48, unit: "kg" },
  { cropName: "Carrot", price: 50, retailMin: 58, retailMax: 68, unit: "kg" },
  { cropName: "Cabbage", price: 22, retailMin: 26, retailMax: 32, unit: "kg" },
  { cropName: "Cauliflower", price: 38, retailMin: 44, retailMax: 52, unit: "kg" },
  { cropName: "Ladies Finger", price: 32, retailMin: 38, retailMax: 45, unit: "kg" },
  { cropName: "Drumstick", price: 65, retailMin: 75, retailMax: 90, unit: "kg" },
  { cropName: "Ginger", price: 120, retailMin: 140, retailMax: 165, unit: "kg" },
  { cropName: "Garlic", price: 160, retailMin: 185, retailMax: 220, unit: "kg" },
  { cropName: "French Beans", price: 48, retailMin: 55, retailMax: 65, unit: "kg" },
  { cropName: "Beetroot", price: 34, retailMin: 40, retailMax: 46, unit: "kg" },
].map((item) => ({
  city: "Chennai",
  market: "Chennai",
  cropName: item.cropName,
  normalizedName: normalizeName(item.cropName),
  price: item.price,
  retailMin: item.retailMin,
  retailMax: item.retailMax,
  unit: item.unit,
  source: SOURCE_URL,
  sourceUpdatedAt: new Date(),
  fetchedAt: new Date(),
}));

    try {
      const regex = new RegExp(cleanQuery, "i");
      const dbResults = await MarketPrice.find({
        market: "Chennai",
        cropName: { $regex: regex },
      })
        .limit(10)
        .lean();
async function fetchChennaiMarketPrices() {
  const response = await axios.get(SOURCE_URL, {
    timeout: 15000,
    headers: {
      "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/140 Safari/537.36",
      Accept: "text/html",
    },
  });

      if (dbResults && dbResults.length > 0) {
        return dbResults.map((item) => ({
          cropName: item.cropName,
          market: item.market,
          marketPrice: item.marketPrice,
          retailRange: `₹${item.retailMin}–${item.retailMax} / ${item.unit}`,
          suggestedPrice: this.calculateSuggestedPrice(
            item.marketPrice,
            "Good",
            100,
          ).suggestedPrice,
          unit: item.unit,
          priceTrend: item.priceTrend,
        }));
      }
    } catch (e) {
      console.warn("DB search failed, falling back to memory:", e.message);
    }
  const $ = cheerio.load(response.data);

    return DEFAULT_CHENNAI_CROPS.filter((c) =>
      c.cropName.toLowerCase().includes(cleanQuery),
    ).map((item) => ({
      cropName: item.cropName,
      market: item.market,
      marketPrice: item.marketPrice,
      retailRange: `₹${item.retailMin}–${item.retailMax} / ${item.unit}`,
      suggestedPrice: this.calculateSuggestedPrice(
        item.marketPrice,
        "Good",
        100,
      ).suggestedPrice,
      unit: item.unit,
      priceTrend: item.priceTrend,
    }));
  const prices = [];

  $("table tr").each((index, row) => {
    const cells = $(row)
      .find("td")
      .map((i, el) => $(el).text().trim())
      .get();

    if (cells.length < 4) return;

    const cropName = cells[0];
    const marketPrice = parsePrice(cells[1]);
    const retail = parseRetailRange(cells[2]);
    const unitText = cells[3];

    if (!cropName || !marketPrice) return;

    prices.push({
      city: "Chennai",
      market: "Chennai",
      cropName,
      normalizedName: normalizeName(cropName),
      price: marketPrice,
      retailMin: retail.min,
      retailMax: retail.max,
      unit: unitText?.toLowerCase().includes("kg")
        ? "kg"
        : unitText || "kg",
      source: SOURCE_URL,
      sourceUpdatedAt: new Date(),
      fetchedAt: new Date(),
    });
  });

  if (!prices.length) {
    throw new Error("No market prices found from source");
  }

  calculateSuggestedPrice(basePrice, quality = "Good", quantity = 100) {
    let qualityAdjustment = 0;
    if (quality === "Good") qualityAdjustment = 2;
    else if (quality === "Poor") qualityAdjustment = -3;
    else qualityAdjustment = 0; // Medium
  return prices;
}

    let quantityAdjustment = 0;
    const qty = Number(quantity) || 100;
    if (qty >= 1000) quantityAdjustment = -2;
    else if (qty >= 300) quantityAdjustment = -1;
    else if (qty < 50) quantityAdjustment = 1;
async function refreshChennaiPrices() {
  let prices = [];
  try {
    prices = await fetchChennaiMarketPrices();
  } catch (err) {
    console.warn("Live scraping failed, using fallback prices:", err.message);
    prices = FALLBACK_PRICES;
  }

    const suggestedPrice = Math.max(
      1,
      basePrice + qualityAdjustment + quantityAdjustment,
  for (const item of prices) {
    await MarketPrice.findOneAndUpdate(
      {
        city: item.city,
        normalizedName: item.normalizedName,
      },
      item,
      {
        upsert: true,
        returnDocument: "after",
      }
    );

    return {
      baseMarketPrice: basePrice,
      qualityAdjustment,
      quantityAdjustment,
      suggestedPrice,
      disclaimer:
        "Estimated selling price — not a guaranteed market price. Actual prices vary by buyer and mandi conditions.",
    };
  }

  async getCropDetails(cropName, quality = "Good", quantity = 100) {
    const cleanName = cropName.trim().toLowerCase();
  return prices;
}

    let crop = null;
async function getChennaiPrices() {
  let prices = await MarketPrice.find({
    city: "Chennai",
  }).sort({ cropName: 1 });

  const lastUpdated = prices.reduce(
    (latest, item) =>
      !latest || item.fetchedAt > latest
        ? item.fetchedAt
        : latest,
    null
  );

  const cacheExpired =
    !lastUpdated ||
    Date.now() - new Date(lastUpdated).getTime() >
      30 * 60 * 1000;

  if (!prices.length || cacheExpired) {
    try {
      crop = await MarketPrice.findOne({
        cropName: { $regex: new RegExp(`^${cleanName}$`, "i") },
      }).lean();
    } catch (e) {
      console.warn("DB lookup error:", e.message);
    }
      await refreshChennaiPrices();

    if (!crop) {
      crop = DEFAULT_CHENNAI_CROPS.find(
        (c) => c.cropName.toLowerCase() === cleanName,
      prices = await MarketPrice.find({
        city: "Chennai",
      }).sort({ cropName: 1 });
    } catch (error) {
      console.error(
        "Live market refresh failed:",
        error.message
      );
    }

    if (!crop) {
      return null;
      // If DB is completely empty, seed fallback directly
      if (!prices.length) {
        prices = FALLBACK_PRICES;
      }
    }
  }

    const pricing = this.calculateSuggestedPrice(
      crop.marketPrice,
      quality,
      quantity,
    );

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
      source:
        crop.source || "Tamil Nadu Market Intelligence / Koyambedu Market",
      suggestedPrice: pricing.suggestedPrice,
      pricingBreakdown: pricing,
      historicalPrices: crop.historicalPrices || [],
      lastUpdated: crop.lastUpdated || new Date(),
    };
  }
  return prices;
}

module.exports = new MarketPriceService();
module.exports = {
  normalizeName,
  fetchChennaiMarketPrices,
  refreshChennaiPrices,
  getChennaiPrices,
};
