const express = require("express");
const Groq = require("groq-sdk");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY || "",
  apiKey: process.env.GROQ_API_KEY,
});

// ==========================================
// FALLBACK RULE-BASED ASSISTANT
// ==========================================
// ======================================================
// CHECK GROQ
// ======================================================

function generateFarmAssistantFallback(message) {
  const text = (message || "").toLowerCase();
function checkGroqKey(res) {
  if (!process.env.GROQ_API_KEY) {
    res.status(500).json({
      success: false,
      message: "GROQ_API_KEY is not configured on the server",
    });

  if (text.includes("yellow") && text.includes("leaf")) {
    return "Yellow leaves can happen because of nutrient deficiency, excess water, poor drainage or disease. Check soil moisture and inspect the leaves for spots or insects.";
    return false;
  }

  if (text.includes("fertilizer") || text.includes("fertiliser")) {
    return "Use fertilizer according to your crop and soil requirements. Avoid excessive fertilizer because it can damage plants and soil.";
  }

  if (
    text.includes("sell") ||
    text.includes("selling") ||
    text.includes("market")
  ) {
    return "You can list your crop in the Farm Trading marketplace, compare prices and negotiate directly with buyers.";
  }

  if (text.includes("price") || text.includes("profit")) {
    return "Compare current market prices, production cost, transportation cost and buyer offers before deciding your selling price.";
  }

  if (
    text.includes("pest") ||
    text.includes("insect") ||
    text.includes("bug")
  ) {
    return "Inspect the affected leaves and stems first. Identify the pest before applying any treatment.";
  }

  if (text.includes("crop") || text.includes("plant")) {
    return "You can use the Weather & Crop Advisor to check suitable crops based on weather and soil conditions.";
  }

  return "I can help with crops, farming, market prices, crop selling, pests, fertilizer and Farm Trading features.";
  return true;
}

// ==========================================
// FARMER ASSISTANT API (Groq AI)
// ==========================================
// ======================================================
// AI FARMER ASSISTANT
// ======================================================

router.post("/chat", authMiddleware, async (req, res) => {
  try {
    const { message } = req.body;
    const { message, conversation = [] } = req.body;

    if (!message || !message.trim()) {
      return res.status(400).json({
        success: false,
        message: "Message is required",
      });
    }

    if (!process.env.GROQ_API_KEY) {
      console.warn("⚠️ GROQ_API_KEY not set. Using fallback assistant.");
      const fallbackReply = generateFarmAssistantFallback(message);
      return res.json({
        success: true,
        reply: fallbackReply,
        answer: fallbackReply,
      });
    if (!checkGroqKey(res)) return;

    const messages = [
      {
        role: "system",
        content: `
You are Farm Trading AI, an intelligent agricultural assistant.

Your main purpose is to help farmers and buyers using the Farm Trading platform.

You can help with:

1. Crop cultivation
2. Crop diseases
3. Pest management
4. Fertilizer guidance
5. Irrigation
6. Soil management
7. Crop harvesting
8. Crop storage
9. Crop selling
10. Marketplace usage
11. Negotiation guidance
12. Weather-related farming guidance
13. Crop quality
14. Sustainable agriculture

Rules:

- Give simple and practical answers.
- Prefer Indian farming context when appropriate.
- Use short sections and bullet points.
- Avoid unnecessary technical terminology.
- Do not claim certainty when information depends on local conditions.
- Do not provide dangerous chemical instructions.
- For pesticides, recommend following the product label and local agricultural guidance.
- If a question is unrelated to farming or Farm Trading, politely explain that you specialize in agriculture and Farm Trading.
- Never pretend that you physically inspected a crop unless an image was actually provided.
        `,
      },
    ];

    // Add previous conversation
    if (Array.isArray(conversation)) {
      for (const item of conversation.slice(-10)) {
        if (
          item &&
          ["user", "assistant"].includes(item.role) &&
          typeof item.content === "string"
        ) {
          messages.push({
            role: item.role,
            content: item.content,
          });
        }
      }
    }

    messages.push({
      role: "user",
      content: message.trim(),
    });

    const candidateModels = [
      process.env.GROQ_MODEL,
      process.env.GROQ_CHAT_MODEL,
      "llama-3.3-70b-versatile",
      "openai/gpt-oss-120b",
      "groq/compound-mini",
    ].filter(Boolean);

    let reply = null;
    let completion = null;
    let lastError = null;

    for (const model of candidateModels) {
      try {
        const completion = await groq.chat.completions.create({
          messages: [
            {
              role: "system",
              content:
                "You are a helpful AI agricultural assistant for the Farm Trading platform. Provide concise, practical, and farmer-friendly advice about crops, farming practices, pest management, market pricing, weather considerations, and sustainable agriculture.",
            },
            {
              role: "user",
              content: message,
            },
          ],
        completion = await groq.chat.completions.create({
          model,
          messages,
          temperature: 0.5,
          max_completion_tokens: 900,
        });

        reply = completion.choices[0]?.message?.content || null;
        if (reply) break;
        if (completion) break;
      } catch (err) {
        lastError = err;
        if (
          err.status === 404 ||
          (err.message && err.message.toLowerCase().includes("not found")) ||
          (err.message && err.message.toLowerCase().includes("does not exist"))
        ) {
          console.warn(`Groq model ${model} not available, trying next fallback...`);
          console.warn(`Chat model ${model} not available, trying next fallback...`);
          continue;
        }
        throw err;
      }
    }

    if (!reply && lastError) {
    if (!completion && lastError) {
      throw lastError;
    }

    reply = reply || "No response generated";
    const reply =
      completion.choices?.[0]?.message?.content?.trim() ||
      "Sorry, I could not generate a response.";

    res.json({
      success: true,
      reply,
      answer: reply,
      model: completion.model,
    });
  } catch (error) {
    console.error("Groq AI Error:", error);
    console.error("Groq Chat Error:", error);

    // Graceful fallback to avoid breaking UI experience
    try {
      const fallbackReply = generateFarmAssistantFallback(req.body.message || "");
      return res.json({
        success: true,
        reply: fallbackReply,
        answer: fallbackReply,
        note: "Response generated by fallback assistant due to AI service issue.",
      });
    } catch (fallbackErr) {
      res.status(500).json({
        success: false,
        message: "AI assistant failed to generate a response",
      });
    }
    res.status(500).json({
      success: false,
      message: "AI assistant is temporarily unavailable",
    });
  }
});

// ==========================================
// CROP QUALITY ANALYSIS
// ==========================================
// ======================================================
// AI CROP QUALITY DETECTION - GROQ VISION
// ======================================================

router.post("/crop-quality", authMiddleware, async (req, res) => {
  try {
    const { imageName, cropName } = req.body;
    const {
      imageBase64,
      imageUrl,
      cropName,
    } = req.body;

    if (!imageName) {
    if (!imageBase64 && !imageUrl) {
      return res.status(400).json({
        success: false,
        message: "Crop image is required",
      });
    }

    /*
        Prototype AI analysis.
    if (!checkGroqKey(res)) return;

        Later this function can be replaced
        with an actual computer vision model.
      */
    let imageSource;

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
    if (imageUrl) {
      imageSource = imageUrl;
    } else {
      // Flutter should send a complete data URL:
      // data:image/jpeg;base64,XXXX
      imageSource = imageBase64.startsWith("data:")
        ? imageBase64
        : `data:image/jpeg;base64,${imageBase64}`;
    }

    // Deterministic demo result
    const fileScore = imageName.length % 3;
    const candidateVisionModels = [
      process.env.GROQ_VISION_MODEL,
      "qwen/qwen3.8-27b",
    ].filter(Boolean);

    const result = qualityResults[fileScore];
    let completion = null;
    let lastError = null;

    for (const model of candidateVisionModels) {
      try {
        completion = await groq.chat.completions.create({
          model,
          messages: [
            {
              role: "system",
              content: `
You are an AI crop quality inspection assistant.

Analyze the provided crop image carefully.

Return ONLY valid JSON.

Required JSON structure:

{
  "quality": "Good | Medium | Poor | Unclear",
  "confidence": 0,
  "freshness": "High | Medium | Low | Unclear",
  "visibleIssues": [],
  "observations": [],
  "recommendation": "",
  "sellingAdvice": ""
}

Important:

- Do not invent diseases that cannot be visually supported.
- If the image is unclear, use "Unclear".
- Confidence must be a number from 0 to 100.
- Mention only visually observable issues.
- This is an image-based screening result, not a laboratory test.
- Keep recommendations practical.
              `,
            },
            {
              role: "user",
              content: [
                {
                  type: "text",
                  text: `
Analyze this crop image.

Crop name:
${cropName || "Unknown crop"}

Evaluate:
- visible quality
- freshness
- discoloration
- physical damage
- visible pest/disease symptoms
- possible storage problems
- selling readiness
                  `,
                },
                {
                  type: "image_url",
                  image_url: {
                    url: imageSource,
                  },
                },
              ],
            },
          ],

          temperature: 0.2,
          max_completion_tokens: 700,
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
          console.warn(`Vision model ${model} not available, trying next fallback...`);
          continue;
        }
        throw err;
      }
    }

    if (!completion && lastError) {
      throw lastError;
    }

    const raw =
      completion.choices?.[0]?.message?.content || "{}";

    let result;

    try {
      result = JSON.parse(raw);
    } catch (parseError) {
      console.error("Vision JSON parse error:", parseError);

      return res.status(500).json({
        success: false,
        message: "AI returned an invalid crop analysis",
      });
    }

    res.json({
      success: true,
      cropName: cropName || "Unknown Crop",
      quality: result.quality,
      confidence: result.confidence,
      freshness: result.freshness,
      recommendation: result.recommendation,
      quality: result.quality || "Unclear",
      confidence: Number(result.confidence) || 0,
      freshness: result.freshness || "Unclear",
      visibleIssues: Array.isArray(result.visibleIssues)
        ? result.visibleIssues
        : [],
      observations: Array.isArray(result.observations)
        ? result.observations
        : [],
      recommendation:
        result.recommendation ||
        "Please inspect the crop carefully before selling.",
      sellingAdvice:
        result.sellingAdvice ||
        "Consider additional quality inspection before selling.",
      analyzedAt: new Date(),
      model: completion.model,
    });
  } catch (error) {
    console.error("Crop quality error:", error);
    console.error("Groq Vision Error:", error);

    res.status(500).json({
      success: false,
      message: "Crop quality analysis failed",
    });
  }
});

module.exports = router;
