const express = require("express");
const Groq = require("groq-sdk");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

// ======================================================
// CHECK GROQ
// ======================================================

function checkGroqKey(res) {
  if (!process.env.GROQ_API_KEY) {
    res.status(500).json({
      success: false,
      message: "GROQ_API_KEY is not configured on the server",
    });

    return false;
  }

  return true;
}

// ======================================================
// AI FARMER ASSISTANT
// ======================================================

router.post("/chat", authMiddleware, async (req, res) => {
  try {
    const { message, conversation = [] } = req.body;

    if (!message || !message.trim()) {
      return res.status(400).json({
        success: false,
        message: "Message is required",
      });
    }

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
          messages,
          temperature: 0.5,
          max_completion_tokens: 900,
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
            `Chat model ${model} not available, trying next fallback...`,
          );
          continue;
        }
        throw err;
      }
    }

    if (!completion && lastError) {
      throw lastError;
    }

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
    console.error("Groq Chat Error:", error);

    res.status(500).json({
      success: false,
      message: "AI assistant is temporarily unavailable",
    });
  }
});

// ======================================================
// AI CROP QUALITY DETECTION - GROQ VISION
// ======================================================

router.post("/crop-quality", authMiddleware, async (req, res) => {
  try {
    const { imageBase64, imageUrl, cropName } = req.body;

    if (!imageBase64 && !imageUrl) {
      return res.status(400).json({
        success: false,
        message: "Crop image is required",
      });
    }

    if (!checkGroqKey(res)) return;

    let imageSource;

    if (imageUrl) {
      imageSource = imageUrl;
    } else {
      // Flutter should send a complete data URL:
      // data:image/jpeg;base64,XXXX
      imageSource = imageBase64.startsWith("data:")
        ? imageBase64
        : `data:image/jpeg;base64,${imageBase64}`;
    }

    const candidateVisionModels = [
      process.env.GROQ_VISION_MODEL,
      "qwen/qwen3.8-27b",
    ].filter(Boolean);

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
          console.warn(
            `Vision model ${model} not available, trying next fallback...`,
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
    console.error("Groq Vision Error:", error);

    res.status(500).json({
      success: false,
      message: "Crop quality analysis failed",
    });
  }
});

module.exports = router;
