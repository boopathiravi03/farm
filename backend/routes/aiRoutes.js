const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();


// ==========================================
// AI FARMER ASSISTANT
// ==========================================

function generateFarmAssistantResponse(message) {
  const text = message.toLowerCase();

  if (
    text.includes("yellow") &&
    text.includes("leaf")
  ) {
    return "Yellow leaves can happen because of nutrient deficiency, excess water, poor drainage or disease. Check soil moisture and inspect the leaves for spots or insects.";
  }

  if (
    text.includes("fertilizer") ||
    text.includes("fertiliser")
  ) {
    return "Use fertilizer according to your crop and soil requirements. Avoid excessive fertilizer because it can damage plants and soil.";
  }

  if (
    text.includes("sell") ||
    text.includes("selling") ||
    text.includes("market")
  ) {
    return "You can list your crop in the Farm Trading marketplace, compare prices and negotiate directly with buyers.";
  }

  if (
    text.includes("price") ||
    text.includes("profit")
  ) {
    return "Compare current market prices, production cost, transportation cost and buyer offers before deciding your selling price.";
  }

  if (
    text.includes("pest") ||
    text.includes("insect") ||
    text.includes("bug")
  ) {
    return "Inspect the affected leaves and stems first. Identify the pest before applying any treatment.";
  }

  if (
    text.includes("crop") ||
    text.includes("plant")
  ) {
    return "You can use the Weather & Crop Advisor to check suitable crops based on weather and soil conditions.";
  }

  return "I can help with crops, farming, market prices, crop selling, pests, fertilizer and Farm Trading features.";
}


// ==========================================
// FARMER ASSISTANT API
// ==========================================

router.post(
  "/chat",
  authMiddleware,
  async (req, res) => {
    try {
      const { message } = req.body;

      if (!message) {
        return res.status(400).json({
          success: false,
          message: "Message is required",
        });
      }

      const answer =
        generateFarmAssistantResponse(message);

      res.json({
        success: true,
        answer,
      });
    } catch (error) {
      console.error(error);

      res.status(500).json({
        success: false,
        message: "AI assistant failed",
      });
    }
  }
);


// ==========================================
// CROP QUALITY ANALYSIS
// ==========================================

router.post(
  "/crop-quality",
  authMiddleware,
  async (req, res) => {
    try {
      const {
        imageName,
        cropName,
      } = req.body;

      if (!imageName) {
        return res.status(400).json({
          success: false,
          message: "Crop image is required",
        });
      }

      /*
        Prototype AI analysis.

        Later this function can be replaced
        with an actual computer vision model.
      */

      const qualityResults = [
        {
          quality: "Good",
          confidence: 92,
          freshness: "High",
          recommendation:
            "Crop appears suitable for selling. Store it properly and avoid excessive moisture.",
        },
        {
          quality: "Medium",
          confidence: 78,
          freshness: "Medium",
          recommendation:
            "Crop appears usable but should be sold soon. Check for minor damage or discoloration.",
        },
        {
          quality: "Poor",
          confidence: 65,
          freshness: "Low",
          recommendation:
            "Crop may have visible quality issues. Inspect carefully before selling.",
        },
      ];

      // Deterministic demo result
      const fileScore =
        imageName.length % 3;

      const result =
        qualityResults[fileScore];

      res.json({
        success: true,
        cropName: cropName || "Unknown Crop",
        quality: result.quality,
        confidence: result.confidence,
        freshness: result.freshness,
        recommendation: result.recommendation,
        analyzedAt: new Date(),
      });

    } catch (error) {
      console.error(
        "Crop quality error:",
        error
      );

      res.status(500).json({
        success: false,
        message:
          "Crop quality analysis failed",
      });
    }
  }
);


module.exports = router;
