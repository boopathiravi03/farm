const express = require("express");
const mongoose = require("mongoose");

const CropPassport = require("../models/CropPassport");
const Crop = require("../models/Crop");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// ==========================================
// CREATE CROP PASSPORT
// ==========================================

router.post("/", authMiddleware, async (req, res) => {
  try {
    const { cropId, quality, harvestDate } = req.body;

    if (!cropId) {
      return res.status(400).json({
        success: false,
        message: "Crop ID is required",
      });
    }

    const crop = await Crop.findById(cropId);

    if (!crop) {
      return res.status(404).json({
        success: false,
        message: "Crop not found",
      });
    }

    // Only crop owner can create passport
    if (crop.farmer.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: "You can only create passports for your crops",
      });
    }

    // Check existing passport
    const existing = await CropPassport.findOne({
      crop: cropId,
    });

    if (existing) {
      return res.json({
        success: true,
        message: "Passport already exists",
        passport: existing,
      });
    }

    const passportId =
      "FTP-" +
      Date.now().toString(36).toUpperCase() +
      "-" +
      Math.random().toString(36).substring(2, 7).toUpperCase();

    const passport = await CropPassport.create({
      crop: cropId,
      farmer: req.user.id,
      passportId,
      quality: quality || "Not Tested",
      harvestDate: harvestDate || null,
    });

    res.status(201).json({
      success: true,
      message: "Crop passport created",
      passport,
    });
  } catch (error) {
    console.error("Passport creation error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to create crop passport",
    });
  }
});

// ==========================================
// GET MY PASSPORTS
// ==========================================

router.get("/my", authMiddleware, async (req, res) => {
  try {
    const passports = await CropPassport.find({
      farmer: req.user.id,
    })
      .populate("crop")
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      passports,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to load passports",
    });
  }
});

// ==========================================
// PUBLIC PASSPORT
// ==========================================

router.get("/:passportId", async (req, res) => {
  try {
    const passport = await CropPassport.findOne({
      passportId: req.params.passportId,
    })
      .populate(
        "crop",
        "cropName category quantity unit price location description status latitude longitude",
      )
      .populate("farmer", "name location");

    if (!passport) {
      return res.status(404).json({
        success: false,
        message: "Passport not found",
      });
    }

    res.json({
      success: true,
      passport,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to load passport",
    });
  }
});

module.exports = router;
