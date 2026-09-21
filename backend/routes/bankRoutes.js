const express = require("express");
const BankDetails = require("../models/BankDetails");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// ==========================================
// GET BANK DETAILS (Securely Masked)
// ==========================================
router.get("/", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id || req.user._id;
    const bank = await BankDetails.findOne({ user: userId });

    if (!bank) {
      return res.json({
        success: true,
        exists: false,
        bankDetails: null,
        message: "No bank details registered yet",
      });
    }

    res.json({
      success: true,
      exists: true,
      bankDetails: bank.toSafeObject(),
    });
  } catch (error) {
    console.error("Get bank details error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to retrieve bank details",
    });
  }
});

// ==========================================
// SAVE / CREATE BANK DETAILS
// ==========================================
router.post("/", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id || req.user._id;
    const { accountHolderName, bankName, accountNumber, ifscCode, upiId } = req.body;

    if (!accountHolderName || !bankName || !accountNumber || !ifscCode) {
      return res.status(400).json({
        success: false,
        message: "Account holder name, bank name, account number, and IFSC code are required",
      });
    }

    // Clean and validate IFSC pattern: 4 letters, 0, 6 alphanumeric
    const cleanIfsc = ifscCode.trim().toUpperCase();
    if (!/^[A-Z]{4}0[A-Z0-9]{6}$/.test(cleanIfsc)) {
      return res.status(400).json({
        success: false,
        message: "Invalid IFSC code format (e.g. SBIN0001234)",
      });
    }

    let bank = await BankDetails.findOne({ user: userId });

    if (bank) {
      bank.accountHolderName = accountHolderName.trim();
      bank.bankName = bankName.trim();
      bank.accountNumber = accountNumber.trim();
      bank.ifscCode = cleanIfsc;
      if (upiId !== undefined) bank.upiId = upiId.trim().toLowerCase();
      await bank.save();
    } else {
      bank = await BankDetails.create({
        user: userId,
        accountHolderName: accountHolderName.trim(),
        bankName: bankName.trim(),
        accountNumber: accountNumber.trim(),
        ifscCode: cleanIfsc,
        upiId: upiId ? upiId.trim().toLowerCase() : "",
      });
    }

    res.json({
      success: true,
      message: "Bank details saved securely",
      bankDetails: bank.toSafeObject(),
    });
  } catch (error) {
    console.error("Save bank details error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to save bank details",
    });
  }
});

// ==========================================
// UPDATE BANK DETAILS
// ==========================================
router.put("/", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id || req.user._id;
    const { accountHolderName, bankName, accountNumber, ifscCode, upiId } = req.body;

    const bank = await BankDetails.findOne({ user: userId });
    if (!bank) {
      return res.status(404).json({
        success: false,
        message: "Bank details not found. Please create them first.",
      });
    }

    if (accountHolderName) bank.accountHolderName = accountHolderName.trim();
    if (bankName) bankName.trim();
    if (accountNumber) bank.accountNumber = accountNumber.trim();
    if (ifscCode) {
      const cleanIfsc = ifscCode.trim().toUpperCase();
      if (!/^[A-Z]{4}0[A-Z0-9]{6}$/.test(cleanIfsc)) {
        return res.status(400).json({
          success: false,
          message: "Invalid IFSC code format (e.g. SBIN0001234)",
        });
      }
      bank.ifscCode = cleanIfsc;
    }
    if (upiId !== undefined) bank.upiId = upiId.trim().toLowerCase();

    await bank.save();

    res.json({
      success: true,
      message: "Bank details updated securely",
      bankDetails: bank.toSafeObject(),
    });
  } catch (error) {
    console.error("Update bank details error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to update bank details",
    });
  }
});

module.exports = router;
