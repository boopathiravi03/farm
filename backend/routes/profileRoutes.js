const express = require("express");
const User = require("../models/User");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// ==========================================
// GET CURRENT PROFILE
// ==========================================
router.get("/", authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.id || req.user._id).select("-password");

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User profile not found",
      });
    }

    res.json({
      success: true,
      profile: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        phone: user.phone || "",
        location: user.location || "",
        district: user.district || "",
        state: user.state || "Tamil Nadu",
        farmSize: user.farmSize || null,
        farmSizeUnit: user.farmSizeUnit || "acres",
        profilePhoto: user.profilePhoto || "",
        createdAt: user.createdAt,
      },
    });
  } catch (error) {
    console.error("Get profile error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to retrieve profile",
    });
  }
});

// ==========================================
// UPDATE CURRENT PROFILE
// ==========================================
router.put("/", authMiddleware, async (req, res) => {
  try {
    const {
      name,
      phone,
      location,
      district,
      state,
      farmSize,
      farmSizeUnit,
      profilePhoto,
    } = req.body;

    const user = await User.findById(req.user.id || req.user._id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    if (name) user.name = name.trim();
    if (phone !== undefined) user.phone = phone.trim();
    if (location !== undefined) user.location = location.trim();
    if (district !== undefined) user.district = district.trim();
    if (state !== undefined) user.state = state.trim();
    if (farmSize !== undefined) user.farmSize = Number(farmSize) || null;
    if (farmSizeUnit !== undefined) user.farmSizeUnit = farmSizeUnit.trim();
    if (profilePhoto !== undefined) user.profilePhoto = profilePhoto;

    await user.save();

    res.json({
      success: true,
      message: "Profile updated successfully",
      profile: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        phone: user.phone || "",
        location: user.location || "",
        district: user.district || "",
        state: user.state || "Tamil Nadu",
        farmSize: user.farmSize || null,
        farmSizeUnit: user.farmSizeUnit || "acres",
        profilePhoto: user.profilePhoto || "",
      },
    });
  } catch (error) {
    console.error("Update profile error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to update profile",
    });
  }
});

module.exports = router;
