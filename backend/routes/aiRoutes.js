const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();


// ==========================================
// AI FARMER ASSISTANT
// ==========================================

router.post(
  "/chat",
  authMiddleware,
  async (req, res) => {
    try {
      const { message } = req.body;

      if (!message || !message.trim()) {
        return res.status(400).json({
          message: "Please enter a question",
        });
      }

      const answer =
        generateFarmAssistantResponse(
          message
        );

      res.json({
        success: true,
        answer,
      });

    } catch (error) {
      console.error(error);

      res.status(500).json({
        message:
          "AI assistant failed",
      });
    }
  }
);


// ==========================================
// DEMO AI RESPONSE ENGINE
// ==========================================

function generateFarmAssistantResponse(
  message
) {
  const text =
    message.toLowerCase();

  if (
    text.includes("tomato") &&
    (
      text.includes("yellow") ||
      text.includes("leaf")
    )
  ) {
    return `
Yellow tomato leaves can have several causes,
including nutrient deficiency, overwatering,
underwatering, pests or disease.

Check the soil moisture first and inspect
the underside of the leaves for pests.

If the problem continues, take a clear photo
of the affected leaves for more accurate
crop diagnosis.
    `.trim();
  }


  if (
    text.includes("fertilizer") ||
    text.includes("fertiliser")
  ) {
    return `
Before applying fertilizer, check the crop
stage, soil condition and nutrient requirement.

Avoid applying excessive fertilizer because
it can damage plants and increase costs.

A soil test can help determine the nutrients
that are actually required.
    `.trim();
  }


  if (
    text.includes("sell") ||
    text.includes("selling") ||
    text.includes("market")
  ) {
    return `
Before selling your crop, compare available
market prices, check crop quality, calculate
your total production cost and consider
transportation expenses.

Farm Trading can also help you list your crop
and connect with buyers.
    `.trim();
  }


  if (
    text.includes("price") ||
    text.includes("profit")
  ) {
    return `
For better pricing decisions, consider:

1. Current market price
2. Crop quality
3. Quantity available
4. Transportation cost
5. Production cost
6. Buyer demand

Use these factors together rather than
depending on one price estimate.
    `.trim();
  }


  if (
    text.includes("pest") ||
    text.includes("insect") ||
    text.includes("bug")
  ) {
    return `
First identify the pest before choosing
a treatment.

Check the leaves, stems and fruits carefully.
Look for holes, discoloration, insects or
webbing.

Avoid using pesticides without identifying
the problem and following the product label.
    `.trim();
  }


  if (
    text.includes("crop") ||
    text.includes("plant")
  ) {
    return `
When choosing a crop, consider your soil,
water availability, season, local climate,
market demand and expected production cost.

A crop that performs well locally may be
more suitable than choosing only based on
market price.
    `.trim();
  }


  return `
I am your Farm Trading AI Assistant 🤖🌾.

You can ask me about:

• Crop management
• Crop problems
• Fertilizer basics
• Farm expenses
• Selling crops
• Market considerations
• Buyer preparation
• Farm Trading features

Ask your farming question in simple language.
  `.trim();
}


module.exports = router;
