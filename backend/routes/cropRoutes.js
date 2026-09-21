const express = require("express");

const Crop = require("../models/Crop");
const protect = require("../middleware/authMiddleware");

const router = express.Router();

// Add crop
router.post("/", protect, async (req, res) => {
  try {
    const {
      cropName,
      category,
      quantity,
      unit,
      price,
      location,
      latitude,
      longitude,
      description,
      image,
    } = req.body;

    if (!cropName || !category || !quantity || !price || !location) {
      return res.status(400).json({
        message: "Please fill all required fields",
      });
    }

    const crop = await Crop.create({
      farmer: req.user.id,
      cropName,
      category,
      quantity,
      unit: unit || "kg",
      price,
      location,
      latitude: latitude !== undefined && latitude !== "" && latitude !== null ? Number(latitude) : null,
      longitude: longitude !== undefined && longitude !== "" && longitude !== null ? Number(longitude) : null,
      description,
      image,
    });

    res.status(201).json({
      message: "Crop added successfully",
      crop,
    });
  } catch (error) {
    res.status(500).json({
      message: "Failed to add crop",
      error: error.message,
    });
  }
});

// Get all available crops
router.get("/", async (req, res) => {
  try {
    const crops = await Crop.find({
      status: "available",
    })
      .populate("farmer", "name location")
      .sort({ createdAt: -1 });

    res.json(crops);
  } catch (error) {
    res.status(500).json({
      message: "Failed to fetch crops",
      error: error.message,
    });
  }
});

// Get farmer's crops
router.get("/my-crops", protect, async (req, res) => {
  try {
    const crops = await Crop.find({
      farmer: req.user.id,
    }).sort({ createdAt: -1 });

    res.json(crops);
  } catch (error) {
    res.status(500).json({
      message: "Failed to fetch your crops",
      error: error.message,
    });
  }
});

// Search and filter crops
router.get("/search", async (req, res) => {
  try {
    const { search, category, location, minPrice, maxPrice } = req.query;

    const filter = {
      status: "available",
    };

    if (search) {
      filter.cropName = {
        $regex: search,
        $options: "i",
      };
    }

    if (category && category !== "All") {
      filter.category = category;
    }

    if (location) {
      filter.location = {
        $regex: location,
        $options: "i",
      };
    }

    if (minPrice || maxPrice) {
      filter.price = {};

      if (minPrice) {
        filter.price.$gte = Number(minPrice);
      }

      if (maxPrice) {
        filter.price.$lte = Number(maxPrice);
      }
    }

    const crops = await Crop.find(filter)
      .populate("farmer", "name location")
      .sort({ createdAt: -1 });

    res.json(crops);
  } catch (error) {
    res.status(500).json({
      message: "Search failed",
      error: error.message,
    });
  }
});

// Update crop
router.put("/:id", protect, async (req, res) => {
  try {
    const crop = await Crop.findById(req.params.id);

    if (!crop) {
      return res.status(404).json({
        message: "Crop not found",
      });
    }

    // Only the farmer who created it can edit it
    if (crop.farmer.toString() !== req.user.id) {
      return res.status(403).json({
        message: "You are not allowed to edit this crop",
      });
    }

    const updatedCrop = await Crop.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    res.json({
      message: "Crop updated successfully",
      crop: updatedCrop,
    });
  } catch (error) {
    res.status(500).json({
      message: "Failed to update crop",
      error: error.message,
    });
  }
});

// Delete crop
router.delete("/:id", protect, async (req, res) => {
  try {
    const crop = await Crop.findById(req.params.id);

    if (!crop) {
      return res.status(404).json({
        message: "Crop not found",
      });
    }

    if (crop.farmer.toString() !== req.user.id) {
      return res.status(403).json({
        message: "You are not allowed to delete this crop",
      });
    }

    await Crop.findByIdAndDelete(req.params.id);

    res.json({
      message: "Crop deleted successfully",
    });
  } catch (error) {
    res.status(500).json({
      message: "Failed to delete crop",
      error: error.message,
    });
  }
});

module.exports = router;
