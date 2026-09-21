import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'bank_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String token;

  const ProfileScreen({super.key, required this.token});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String apiUrl = "https://farm-trading-backend.onrender.com/api";

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final farmNameController = TextEditingController();
  final farmSizeController = TextEditingController();
  final districtController = TextEditingController();
  final villageController = TextEditingController();
  final pincodeController = TextEditingController();

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    locationController.dispose();
    farmNameController.dispose();
    farmSizeController.dispose();
    districtController.dispose();
    villageController.dispose();
    pincodeController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/profile"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final user = data["user"] ?? {};
        final profile = data["profile"] ?? {};

        nameController.text = user["name"] ?? "";

        phoneController.text = user["phone"] ?? "";

        locationController.text = user["location"] ?? "";

        farmNameController.text = profile["farmName"] ?? "";

        farmSizeController.text = profile["farmSize"]?.toString() ?? "";

        districtController.text = profile["district"] ?? "";

        villageController.text = profile["village"] ?? "";

        pincodeController.text = profile["pincode"] ?? "";
      }
    } catch (error) {
      debugPrint(error.toString());
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> saveProfile() async {
    setState(() {
      saving = true;
    });

    try {
      final response = await http.put(
        Uri.parse("$apiUrl/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: jsonEncode({
          "name": nameController.text,
          "phone": phoneController.text,
          "location": locationController.text,
          "farmName": farmNameController.text,
          "farmSize": double.tryParse(farmSizeController.text),
          "district": districtController.text,
          "village": villageController.text,
          "pincode": pincodeController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Unable to update profile")));
    }

    if (mounted) {
      setState(() {
        saving = false;
      });
    }
  }

  Widget field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F3),
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: const Color(0xFF167D39),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.person, size: 55, color: Color(0xFF167D39)),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Personal Information",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          field("Full name", nameController),

          field("Phone", phoneController, keyboardType: TextInputType.phone),

          field("Location", locationController),

          const SizedBox(height: 10),

          const Text(
            "Farm Information",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          field("Farm name", farmNameController),

          field(
            "Farm size",
            farmSizeController,
            keyboardType: TextInputType.number,
          ),

          field("Village", villageController),

          field("District", districtController),

          field(
            "Pincode",
            pincodeController,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: saving ? null : saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF167D39),
                foregroundColor: Colors.white,
              ),
              child: saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Profile"),
            ),
          ),

          const SizedBox(height: 20),

          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            leading: const Icon(
              Icons.account_balance,
              color: Color(0xFF167D39),
            ),
            title: const Text(
              "Bank & Payment Details",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Manage your payment account"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BankDetailsScreen(token: widget.token),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
