const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// Demo weather data
router.get("/", authMiddleware, async (req, res) => {
  try {
    const weather = {
      location: "Chennai",
      temperature: 30,
      humidity: 72,
      rainfall: 8,
      windSpeed: 14,
      condition: "Partly Cloudy",
    };

    res.json({
      success: true,
      weather,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch weather",
    });
  }
});

// Crop recommendation
router.post("/recommend", authMiddleware, async (req, res) => {
  try {
    const {
      temperature,
      humidity,
      rainfall,
      soilType,
    } = req.body;

    const recommendations = [];

    // Rice
    if (
      temperature >= 20 &&
      temperature <= 35 &&
      humidity >= 60 &&
      rainfall >= 5
    ) {
      recommendations.push({
        crop: "Rice",
        suitability: "High",
        reason: "Suitable temperature, humidity and rainfall conditions.",
      });
    }

    // Tomato
    if (
      temperature >= 18 &&
      temperature <= 32 &&
      humidity >= 50 &&
      rainfall <= 15
    ) {
      recommendations.push({
        crop: "Tomato",
        suitability: "High",
        reason: "Moderate temperature and controlled rainfall are suitable.",
      });
    }

    // Groundnut
    if (
      temperature >= 24 &&
      temperature <= 35 &&
      rainfall >= 5 &&
      rainfall <= 20
    ) {
      recommendations.push({
        crop: "Groundnut",
        suitability: "High",
        reason: "Warm weather with moderate rainfall is favourable.",
      });
    }

    // Cotton
    if (
      temperature >= 21 &&
      temperature <= 35 &&
      rainfall >= 5 &&
      rainfall <= 25
    ) {
      recommendations.push({
        crop: "Cotton",
        suitability: "Medium",
        reason: "Warm temperature and moderate rainfall support growth.",
      });
    }

    // Maize
    if (
      temperature >= 18 &&
      temperature <= 32 &&
      rainfall >= 5 &&
      rainfall <= 20
    ) {
      recommendations.push({
        crop: "Maize",
        suitability: "High",
        reason: "Suitable temperature and moderate moisture conditions.",
      });
    }

    // Banana
    if (
      temperature >= 20 &&
      temperature <= 35 &&
      humidity >= 60
    ) {
      recommendations.push({
        crop: "Banana",
        suitability: "Medium",
        reason: "Warm and humid conditions support banana cultivation.",
      });
    }

    // Soil-based recommendation
    if (soilType === "Red Soil") {
      recommendations.push({
        crop: "Groundnut",
        suitability: "High",
        reason: "Groundnut can perform well in well-drained red soil.",
      });
    }

    if (soilType === "Clay Soil") {
      recommendations.push({
        crop: "Rice",
        suitability: "High",
        reason: "Clay soil can retain water effectively for rice cultivation.",
      });
    }

    if (soilType === "Sandy Soil") {
      recommendations.push({
        crop: "Groundnut",
        suitability: "High",
        reason: "Sandy and well-drained soil can support groundnut.",
      });
    }

    // Remove duplicates
    const uniqueRecommendations = recommendations.filter(
      (item, index, self) =>
        index ===
        self.findIndex(
          (crop) => crop.crop === item.crop
        )
    );

    res.json({
      success: true,
      recommendations: uniqueRecommendations,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to generate recommendations",
    });
  }
});

module.exports = router;
