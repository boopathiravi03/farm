const express = require("express");
const BankDetails = require("../models/BankDetails");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// ==========================================
// GET BANK DETAILS (Securely Masked)
// ==========================================
// GET BANK DETAILS

router.get("/", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id || req.user._id;
    const bank = await BankDetails.findOne({ user: userId });
    const bank = await BankDetails.findOne({
      user: req.user.id,
    }).select("+accountNumber");

    if (!bank) {
      return res.json({
        success: true,
        exists: false,
        bankDetails: null,
        message: "No bank details registered yet",
        bank: null,
      });
    }

    const rawAccount = bank.accountNumber || "";
    const maskedAccount =
      rawAccount.length >= 4
        ? "••••••••" + rawAccount.slice(-4)
        : "••••••••";

    res.json({
      success: true,
      exists: true,
      bankDetails: bank.toSafeObject(),
      bank: {
        id: bank._id,
        accountHolderName: bank.accountHolderName,
        bankName: bank.bankName,
        accountNumber: maskedAccount,
        ifsc: bank.ifsc,
        upiId: bank.upiId,
        isVerified: bank.isVerified,
      },
    });
  } catch (error) {
    console.error("Get bank details error:", error);
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to retrieve bank details",
      message: "Unable to load bank details",
    });
  }
});

// ==========================================
// SAVE / CREATE BANK DETAILS
// ==========================================
// SAVE / UPDATE

router.post("/", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id || req.user._id;
    const { accountHolderName, bankName, accountNumber, ifscCode, upiId } =
      req.body;
    const {
      accountHolderName,
      bankName,
      accountNumber,
      ifsc,
      upiId,
    } = req.body;

    if (!accountHolderName || !bankName || !accountNumber || !ifscCode) {
    if (
      !accountHolderName ||
      !bankName ||
      !accountNumber ||
      !ifsc
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Account holder name, bank name, account number, and IFSC code are required",
          "Account holder, bank, account number and IFSC are required",
      });
    }

    // Clean and validate IFSC pattern: 4 letters, 0, 6 alphanumeric
    const cleanIfsc = ifscCode.trim().toUpperCase();
    if (!/^[A-Z]{4}0[A-Z0-9]{6}$/.test(cleanIfsc)) {
    const cleanAccountNumber =
      String(accountNumber).replace(/\s/g, "");

    if (!/^\d{9,18}$/.test(cleanAccountNumber)) {
      return res.status(400).json({
        success: false,
        message: "Invalid IFSC code format (e.g. SBIN0001234)",
        message: "Invalid bank account number",
      });
    }

    let bank = await BankDetails.findOne({ user: userId });
    const cleanIfsc = String(ifsc)
      .trim()
      .toUpperCase();

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
    if (!/^[A-Z]{4}0[A-Z0-9]{6}$/.test(cleanIfsc)) {
      return res.status(400).json({
        success: false,
        message: "Invalid IFSC code",
      });
    }

    const bank = await BankDetails.findOneAndUpdate(
      { user: req.user.id },
      {
        user: req.user.id,
        accountHolderName,
        bankName,
        accountNumber: cleanAccountNumber,
        ifsc: cleanIfsc,
        upiId: upiId || "",
      },
      {
        new: true,
        upsert: true,
      }
    );

    res.json({
      success: true,
      message: "Bank details saved securely",
      bankDetails: bank.toSafeObject(),
      message: "Payment details saved securely",
      bank: {
        id: bank._id,
        accountHolderName: bank.accountHolderName,
        bankName: bank.bankName,
        accountNumber:
          "••••••••" +
          cleanAccountNumber.slice(-4),
        ifsc: bank.ifsc,
        upiId: bank.upiId,
      },
    });
  } catch (error) {
    console.error("Save bank details error:", error);
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to save bank details",
      message: "Unable to save payment details",
    });
  }
});

// ==========================================
// UPDATE BANK DETAILS
// ==========================================
router.put("/", authMiddleware, async (req, res) => {
// DELETE

router.delete("/", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id || req.user._id;
    const { accountHolderName, bankName, accountNumber, ifscCode, upiId } =
      req.body;
    await BankDetails.findOneAndDelete({
      user: req.user.id,
    });

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
      message: "Payment details removed",
    });
  } catch (error) {
    console.error("Update bank details error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to update bank details",
      message: "Unable to remove payment details",
    });
  }
});

module.exports = router;
