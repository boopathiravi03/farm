import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BankDetailsScreen extends StatefulWidget {
  final String token;

  const BankDetailsScreen({
    super.key,
    required this.token,
  });

  @override
  State<BankDetailsScreen> createState() =>
      _BankDetailsScreenState();
}

class _BankDetailsScreenState
    extends State<BankDetailsScreen> {
  static const String apiUrl =
      "https://farm-trading-backend.onrender.com/api";

  final holderController =
      TextEditingController();

  final bankController =
      TextEditingController();

  final accountController =
      TextEditingController();

  final ifscController =
      TextEditingController();

  final upiController =
      TextEditingController();

  bool saving = false;
  bool obscureAccount = true;

  @override
  void dispose() {
    holderController.dispose();
    bankController.dispose();
    accountController.dispose();
    ifscController.dispose();
    upiController.dispose();
    super.dispose();
  }

  Future<void> saveBank() async {
    if (holderController.text.isEmpty ||
        bankController.text.isEmpty ||
        accountController.text.isEmpty ||
        ifscController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Please fill all required fields"),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$apiUrl/bank"),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer ${widget.token}",
        },
        body: jsonEncode({
          "accountHolderName":
              holderController.text.trim(),
          "bankName":
              bankController.text.trim(),
          "accountNumber":
              accountController.text.trim(),
          "ifsc":
              ifscController.text.trim(),
          "upiId":
              upiController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ??
                  "Payment details saved",
            ),
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ??
                  "Unable to save details",
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Network error"),
        ),
      );
    }

    if (mounted) {
      setState(() {
        saving = false;
      });
    }
  }

  Widget input(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    Widget? suffix,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F8F3),
      appBar: AppBar(
        title: const Text(
          "Payment Details",
        ),
        backgroundColor:
            const Color(0xFF167D39),
        foregroundColor:
            Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding:
                const EdgeInsets.all(18),
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFE8F5E9),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.lock,
                  color:
                      Color(0xFF167D39),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Your account number is protected and will be masked after saving.",
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          input(
            "Account holder name",
            holderController,
          ),

          input(
            "Bank name",
            bankController,
          ),

          input(
            "Account number",
            accountController,
            obscure:
                obscureAccount,
            suffix: IconButton(
              icon: Icon(
                obscureAccount
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  obscureAccount =
                      !obscureAccount;
                });
              },
            ),
          ),

          input(
            "IFSC code",
            ifscController,
          ),

          input(
            "UPI ID (optional)",
            upiController,
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed:
                  saving
                      ? null
                      : saveBank,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF167D39,
                ),
                foregroundColor:
                    Colors.white,
              ),
              child: saving
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      "Save Payment Details",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

