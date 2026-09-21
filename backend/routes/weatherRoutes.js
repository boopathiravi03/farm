const express = require("express");
const Groq = require("groq-sdk");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// Demo weather data
const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

// ======================================================
// WEATHER DATA
// ======================================================

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
    console.error("Weather error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch weather",
    });
  }
});

// Crop recommendation
// ======================================================
// GROQ AI CROP RECOMMENDATION
// ======================================================

router.post("/recommend", authMiddleware, async (req, res) => {
  try {
    const { temperature, humidity, rainfall, soilType } = req.body;
    const {
      temperature,
      humidity,
      rainfall,
      soilType,
      location,
      season,
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
    if (!process.env.GROQ_API_KEY) {
      return res.status(500).json({
        success: false,
        message: "GROQ_API_KEY is not configured",
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
    const prompt = `
Generate agricultural crop recommendations using the following conditions.

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
Location:
${location || "Not provided"}

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
Temperature:
${temperature ?? "Not provided"} °C

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
Humidity:
${humidity ?? "Not provided"} %

    // Banana
    if (temperature >= 20 && temperature <= 35 && humidity >= 60) {
      recommendations.push({
        crop: "Banana",
        suitability: "Medium",
        reason: "Warm and humid conditions support banana cultivation.",
      });
    }
Rainfall:
${rainfall ?? "Not provided"} mm

    // Soil-based recommendation
    if (soilType === "Red Soil") {
      recommendations.push({
        crop: "Groundnut",
        suitability: "High",
        reason: "Groundnut can perform well in well-drained red soil.",
      });
Soil type:
${soilType || "Not provided"}

Season:
${season || "Not provided"}

Return ONLY valid JSON in this format:

{
  "recommendations": [
    {
      "crop": "Crop name",
      "suitability": "High | Medium | Low",
      "reason": "Short explanation",
      "careTip": "Practical farming tip"
    }
  ],
  "generalAdvice": "Short overall farming advice",
  "warning": "Important limitation or warning"
}

    if (soilType === "Clay Soil") {
      recommendations.push({
        crop: "Rice",
        suitability: "High",
        reason: "Clay soil can retain water effectively for rice cultivation.",
      });
Rules:

- Recommend crops based on the supplied conditions.
- Do not pretend these recommendations guarantee successful cultivation.
- Consider temperature, humidity, rainfall, soil and season together.
- Give 3 to 5 reasonable crop options.
- Use Indian agricultural context where appropriate.
- Keep the answer practical.
`;

    const candidateModels = [
      process.env.GROQ_CHAT_MODEL,
      "llama-3.3-70b-versatile",
      "openai/gpt-oss-120b",
      "groq/compound-mini",
    ].filter(Boolean);

    let completion = null;
    let lastError = null;

    for (const model of candidateModels) {
      try {
        completion = await groq.chat.completions.create({
          model,
          messages: [
            {
              role: "system",
              content:
                "You are an agricultural crop recommendation AI.",
            },
            {
              role: "user",
              content: prompt,
            },
          ],
          temperature: 0.3,
          max_completion_tokens: 900,
          response_format: {
            type: "json_object",
          },
        });
        if (completion) break;
      } catch (err) {
        lastError = err;
        if (
          err.status === 404 ||
          (err.message && err.message.toLowerCase().includes("not found")) ||
          (err.message && err.message.toLowerCase().includes("does not exist"))
        ) {
          console.warn(`Crop advisor model ${model} not available, trying next fallback...`);
          continue;
        }
        throw err;
      }
    }

    if (soilType === "Sandy Soil") {
      recommendations.push({
        crop: "Groundnut",
        suitability: "High",
        reason: "Sandy and well-drained soil can support groundnut.",
      });
    if (!completion && lastError) {
      throw lastError;
    }

    // Remove duplicates
    const uniqueRecommendations = recommendations.filter(
      (item, index, self) =>
        index === self.findIndex((crop) => crop.crop === item.crop),
    );
    const raw =
      completion.choices?.[0]?.message?.content || "{}";

    const result = JSON.parse(raw);

    res.json({
      success: true,
      recommendations: uniqueRecommendations,
      recommendations: Array.isArray(result.recommendations)
        ? result.recommendations
        : [],
      generalAdvice: result.generalAdvice || "",
      warning: result.warning || "",
      model: completion.model,
    });
  } catch (error) {
    console.error(error);
    console.error("Groq Recommendation Error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to generate recommendations",
      message: "Failed to generate AI crop recommendations",
    });
  }
});

module.exports = router;
