function calculateSuggestedPrice({
  marketPrice,
  quality = "Medium",
  quantity = 0,
}) {
  if (!marketPrice || marketPrice <= 0) {
    return {
      suggestedPrice: 0,
      minimumPrice: 0,
      maximumPrice: 0,
    };
  }

  let adjustment = 0;

  // Quality adjustment
  if (quality === "Good") {
    adjustment += 0.05;
  }

  if (quality === "Poor") {
    adjustment -= 0.1;
  }

  // Bulk quantity adjustment
  if (quantity >= 1000) {
    adjustment -= 0.03;
  } else if (quantity >= 500) {
    adjustment -= 0.02;
  }

  const suggestedPrice = marketPrice * (1 + adjustment);

  const minimumPrice = marketPrice * 0.9;

  const maximumPrice = marketPrice * 1.1;

  return {
    suggestedPrice: Math.round(suggestedPrice),
    minimumPrice: Math.round(minimumPrice),
    maximumPrice: Math.round(maximumPrice),
  };
}

module.exports = {
  calculateSuggestedPrice,
};
