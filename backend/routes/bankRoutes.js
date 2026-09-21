const express = require("express");
const BankDetails = require("../models/BankDetails");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// GET BANK DETAILS

router.get("/", authMiddleware, async (req, res) => {
  try {
    const bank = await BankDetails.findOne({
      user: req.user.id,
    }).select("+accountNumber");

    if (!bank) {
      return res.json({
        success: true,
        bank: null,
      });
    }

    const rawAccount = bank.accountNumber || "";
    const maskedAccount =
      rawAccount.length >= 4 ? "••••••••" + rawAccount.slice(-4) : "••••••••";

    res.json({
      success: true,
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
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Unable to load bank details",
    });
  }
});

// SAVE / UPDATE

router.post("/", authMiddleware, async (req, res) => {
  try {
    const { accountHolderName, bankName, accountNumber, ifsc, upiId } =
      req.body;

    if (!accountHolderName || !bankName || !accountNumber || !ifsc) {
      return res.status(400).json({
        success: false,
        message: "Account holder, bank, account number and IFSC are required",
      });
    }

    const cleanAccountNumber = String(accountNumber).replace(/\s/g, "");

    if (!/^\d{9,18}$/.test(cleanAccountNumber)) {
      return res.status(400).json({
        success: false,
        message: "Invalid bank account number",
      });
    }

    const cleanIfsc = String(ifsc).trim().toUpperCase();

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
      },
    );

    res.json({
      success: true,
      message: "Payment details saved securely",
      bank: {
        id: bank._id,
        accountHolderName: bank.accountHolderName,
        bankName: bank.bankName,
        accountNumber: "••••••••" + cleanAccountNumber.slice(-4),
        ifsc: bank.ifsc,
        upiId: bank.upiId,
      },
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Unable to save payment details",
    });
  }
});

// DELETE

router.delete("/", authMiddleware, async (req, res) => {
  try {
    await BankDetails.findOneAndDelete({
      user: req.user.id,
    });

    res.json({
      success: true,
      message: "Payment details removed",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Unable to remove payment details",
    });
  }
});

module.exports = router;
