const express = require("express");
const Groq = require("groq-sdk");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

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
    console.error("Weather error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch weather",
    });
  }
});

// ======================================================
// GROQ AI CROP RECOMMENDATION
// ======================================================

router.post("/recommend", authMiddleware, async (req, res) => {
  try {
    const { temperature, humidity, rainfall, soilType, location, season } =
      req.body;

    if (!process.env.GROQ_API_KEY) {
      return res.status(500).json({
        success: false,
        message: "GROQ_API_KEY is not configured",
      });
    }

    const prompt = `
Generate agricultural crop recommendations using the following conditions.

Location:
${location || "Not provided"}

Temperature:
${temperature ?? "Not provided"} °C

Humidity:
${humidity ?? "Not provided"} %

Rainfall:
${rainfall ?? "Not provided"} mm

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
              content: "You are an agricultural crop recommendation AI.",
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
          console.warn(
            `Crop advisor model ${model} not available, trying next fallback...`,
          );
          continue;
        }
        throw err;
      }
    }

    if (!completion && lastError) {
      throw lastError;
    }

    const raw = completion.choices?.[0]?.message?.content || "{}";

    const result = JSON.parse(raw);

    res.json({
      success: true,
      recommendations: Array.isArray(result.recommendations)
        ? result.recommendations
        : [],
      generalAdvice: result.generalAdvice || "",
      warning: result.warning || "",
      model: completion.model,
    });
  } catch (error) {
    console.error("Groq Recommendation Error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to generate AI crop recommendations",
    });
  }
});

module.exports = router;
