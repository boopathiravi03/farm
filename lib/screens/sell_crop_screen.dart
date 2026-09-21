import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SellCropScreen extends StatefulWidget {
  final String token;

  const SellCropScreen({super.key, required this.token});

  @override
  State<SellCropScreen> createState() => _SellCropScreenState();
}

class _SellCropScreenState extends State<SellCropScreen> {
  final TextEditingController cropController = TextEditingController();

  final TextEditingController quantityController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  Timer? searchTimer;

  List<dynamic> suggestions = [];

  Map<String, dynamic>? selectedCrop;

  bool searching = false;
  bool loading = false;

  String quality = "Not Tested";

  XFile? selectedImage;

  static const String apiUrl = "https://farm-trading-backend.onrender.com/api";

  @override
  void dispose() {
    searchTimer?.cancel();
    cropController.dispose();
    quantityController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // ===============================================
  // CROP SEARCH
  // ===============================================

  void onCropChanged(String value) {
    searchTimer?.cancel();

    if (value.trim().length < 2) {
      setState(() {
        suggestions = [];
      });
      return;
    }

    searchTimer = Timer(
      const Duration(milliseconds: 350),
      () => searchCrops(value),
    );
  }

  Future<void> searchCrops(String query) async {
    setState(() {
      searching = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          "$apiUrl/market-prices/search?q=${Uri.encodeComponent(query)}",
        ),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            suggestions = data["prices"] ?? [];
          });
        }
      }
    } catch (error) {
      debugPrint(error.toString());
    }

    if (mounted) {
      setState(() {
        searching = false;
      });
    }
  }

  // ===============================================
  // SELECT CROP
  // ===============================================

  void selectCrop(Map<String, dynamic> crop) {
    setState(() {
      selectedCrop = crop;
      cropController.text = crop["cropName"] ?? "";

      suggestions = [];

      priceController.text = calculateSuggestedPrice().toString();
    });
  }

  // ===============================================
  // PRICE
  // ===============================================

  int calculateSuggestedPrice() {
    if (selectedCrop == null) return 0;

    final marketPrice = double.tryParse(selectedCrop!["price"].toString()) ?? 0;

    double multiplier = 1;

    if (quality == "Good") {
      multiplier += 0.05;
    }

    if (quality == "Poor") {
      multiplier -= 0.10;
    }

    final quantity = double.tryParse(quantityController.text) ?? 0;

    if (quantity >= 1000) {
      multiplier -= 0.03;
    } else if (quantity >= 500) {
      multiplier -= 0.02;
    }

    return (marketPrice * multiplier).round();
  }

  void updatePrice() {
    if (selectedCrop != null) {
      setState(() {
        priceController.text = calculateSuggestedPrice().toString();
      });
    }
  }

  // ===============================================
  // IMAGE
  // ===============================================

  Future<void> pickImage() async {
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  // ===============================================
  // PUBLISH
  // ===============================================

  Future<void> publishCrop() async {
    if (selectedCrop == null) {
      showMessage("Please select a crop");
      return;
    }

    final quantity = double.tryParse(quantityController.text);

    final price = double.tryParse(priceController.text);

    if (quantity == null || quantity <= 0) {
      showMessage("Enter a valid quantity");
      return;
    }

    if (price == null || price <= 0) {
      showMessage("Enter a valid selling price");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$apiUrl/crops"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: jsonEncode({
          "cropName": selectedCrop!["cropName"],
          "category": "Vegetable",
          "quantity": quantity,
          "unit": "kg",
          "price": price,
          "marketPrice": selectedCrop!["price"],
          "suggestedPrice": calculateSuggestedPrice(),
          "marketSource": "Vegetable Market Price - Chennai",
          "location": "Chennai",
          "description": descriptionController.text,
          "quality": quality,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        showMessage("Crop listed successfully 🌱");

        Navigator.pop(context);
      } else {
        showMessage(data["message"] ?? "Failed to publish crop");
      }
    } catch (error) {
      if (!mounted) return;
      showMessage("Network error. Please try again.");
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final marketPrice = selectedCrop?["price"];

    final quantity = double.tryParse(quantityController.text) ?? 0;

    final price = double.tryParse(priceController.text) ?? 0;

    final total = quantity * price;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F3),
      appBar: AppBar(
        title: const Text("Sell Your Crop"),
        backgroundColor: const Color(0xFF1B7F3A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🌾 Sell directly to buyers",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Check the latest Chennai market reference before setting your price.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            const Text(
              "Crop name",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: cropController,
              onChanged: onCropChanged,
              decoration: InputDecoration(
                hintText: "Type at least 2 letters",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            if (suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(blurRadius: 10, color: Colors.black12),
                  ],
                ),
                child: Column(
                  children: suggestions
                      .map(
                        (crop) => ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE8F5E9),
                            child: Text("🌱"),
                          ),
                          title: Text(crop["cropName"] ?? ""),
                          subtitle: Text("Market ₹${crop["price"]}/kg"),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                          onTap: () =>
                              selectCrop(Map<String, dynamic>.from(crop)),
                        ),
                      )
                      .toList(),
                ),
              ),

            const SizedBox(height: 20),

            if (selectedCrop != null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF167D39), Color(0xFF35A854)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "CHENNAI MARKET",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "₹$marketPrice / kg",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Current market reference price",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Price can vary by market and location.",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            const Text(
              "Quantity",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              onChanged: (_) => updatePrice(),
              decoration: InputDecoration(
                hintText: "Example: 500",
                suffixText: "kg",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Crop quality",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: quality,
              items: const [
                DropdownMenuItem(
                  value: "Not Tested",
                  child: Text("Not Tested"),
                ),
                DropdownMenuItem(value: "Good", child: Text("Good")),
                DropdownMenuItem(value: "Medium", child: Text("Medium")),
                DropdownMenuItem(value: "Poor", child: Text("Poor")),
              ],
              onChanged: (value) {
                setState(() {
                  quality = value!;
                });

                updatePrice();
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Your selling price",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: "₹ ",
                suffixText: "/ kg",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            if (selectedCrop != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "💡 Suggested price: ₹${calculateSuggestedPrice()}/kg",
                  style: const TextStyle(
                    color: Color(0xFF167D39),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            if (quantity > 0 && price > 0)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6EC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Estimated listing value"),
                    Text(
                      "₹${total.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF167D39),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.camera_alt),
              label: Text(
                selectedImage == null ? "Add crop photo" : "Photo selected ✓",
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Describe your crop...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : publishCrop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF167D39),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Publish Crop Listing",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
