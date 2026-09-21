const express = require("express");
const User = require("../models/User");
const FarmerProfile = require("../models/FarmerProfile");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// ==========================================
// GET CURRENT PROFILE
// ==========================================
// GET PROFILE

router.get("/", authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.id || req.user._id).select(
      "-password",
    const user = await User.findById(req.user.id).select(
      "-password"
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User profile not found",
      });
    }
    const profile = await FarmerProfile.findOne({
      user: req.user.id,
    });

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
      user,
      profile,
    });
  } catch (error) {
    console.error("Get profile error:", error);
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to retrieve profile",
      message: "Unable to load profile",
    });
  }
});

// ==========================================
// UPDATE CURRENT PROFILE
// ==========================================
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
      farmSize,
      farmSizeUnit,
      profilePhoto,
      pincode,
      about,
    } = req.body;

    const user = await User.findById(req.user.id || req.user._id);
    const user = await User.findByIdAndUpdate(
      req.user.id,
      {
        ...(name !== undefined && { name }),
        ...(phone !== undefined && { phone }),
        ...(location !== undefined && { location }),
      },
      {
        new: true,
      }
    ).select("-password");

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }
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
      }
    );

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
      message: "Profile updated",
      user,
      profile,
    });
  } catch (error) {
    console.error("Update profile error:", error);
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to update profile",
      message: "Profile update failed",
    });
  }
});

module.exports = router;
