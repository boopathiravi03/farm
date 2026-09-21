const express = require("express");
const User = require("../models/User");
const FarmerProfile = require("../models/FarmerProfile");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// GET PROFILE

router.get("/", authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("-password");

    const profile = await FarmerProfile.findOne({
      user: req.user.id,
    });

    res.json({
      success: true,
      user,
      profile,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Unable to load profile",
    });
  }
});

// UPDATE PROFILE

router.put("/", authMiddleware, async (req, res) => {
  try {
    const {
      name,
      phone,
      location,
      profileImage,
      farmName,
      farmSize,
      farmSizeUnit,
      address,
      village,
      district,
      state,
      pincode,
      about,
    } = req.body;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      {
        ...(name !== undefined && { name }),
        ...(phone !== undefined && { phone }),
        ...(location !== undefined && { location }),
      },
      {
        new: true,
      },
    ).select("-password");

    const profile = await FarmerProfile.findOneAndUpdate(
      { user: req.user.id },
      {
        user: req.user.id,
        profileImage,
        farmName,
        farmSize,
        farmSizeUnit,
        address,
        village,
        district,
        state,
        pincode,
        about,
      },
      {
        new: true,
        upsert: true,
      },
    );

    res.json({
      success: true,
      message: "Profile updated",
      user,
      profile,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Profile update failed",
    });
  }
});

module.exports = router;
