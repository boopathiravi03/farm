import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FarmMapScreen extends StatefulWidget {
  const FarmMapScreen({super.key});

  @override
  State<FarmMapScreen> createState() => _FarmMapScreenState();
}

class _FarmMapScreenState extends State<FarmMapScreen> {
  final MapController mapController = MapController();

  // Default map location
  // You can replace these with user's GPS location later.
  final LatLng defaultLocation = const LatLng(
    11.775,
    79.552,
  );

  final List<FarmerLocation> locations = [
    FarmerLocation(
      name: "Farm Trading Farmer",
      crop: "Tomato",
      quantity: "500 Kg",
      location: "Panruti",
      latitude: 11.776,
      longitude: 79.551,
      isFarmer: true,
    ),
    FarmerLocation(
      name: "Arun Traders",
      crop: "Tomato",
      quantity: "500 Kg",
      location: "Panruti",
      latitude: 11.780,
      longitude: 79.558,
      isFarmer: false,
    ),
    FarmerLocation(
      name: "Kumar Agro Foods",
      crop: "Vegetables",
      quantity: "300 Kg",
      location: "Panruti",
      latitude: 11.769,
      longitude: 79.545,
      isFarmer: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F29A),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Farm Trading Map",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),

      body: Stack(
        children: [

          // ============================
          // REAL MAP
          // ============================
          FlutterMap(
            mapController: mapController,

            options: MapOptions(
              initialCenter: defaultLocation,
              initialZoom: 13.5,
              minZoom: 5,
              maxZoom: 18,
            ),

            children: [

              // OpenStreetMap FREE MAP
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                userAgentPackageName:
                    'com.farmtrading.app',

                maxZoom: 19,
              ),

              // FARMER / BUYER MARKERS
              MarkerLayer(
                markers: locations.map((item) {
                  return Marker(
                    point: LatLng(
                      item.latitude,
                      item.longitude,
                    ),

                    width: 100,
                    height: 100,

                    child: GestureDetector(
                      onTap: () {
                        _showLocationDetails(item);
                      },

                      child: Column(
                        children: [

                          Container(
                            width: 48,
                            height: 48,

                            decoration: BoxDecoration(
                              color: item.isFarmer
                                  ? Colors.green
                                  : Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                ),
                              ],
                            ),

                            child: Icon(
                              item.isFarmer
                                  ? Icons.agriculture
                                  : Icons.store,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(6),

                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 3,
                                ),
                              ],
                            ),

                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // ============================
          // TOP INFORMATION CARD
          // ============================
          Positioned(
            top: 15,
            left: 20,
            right: 20,

            child: Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),

                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),

              child: Row(
                children: [

                  Container(
                    width: 45,
                    height: 45,

                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      "Farmers and buyers near your trading area",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ============================
          // ZOOM BUTTONS
          // ============================
          Positioned(
            right: 15,
            bottom: 210,

            child: Column(
              children: [

                _mapButton(
                  Icons.add,
                  () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom + 1,
                    );
                  },
                ),

                const SizedBox(height: 8),

                _mapButton(
                  Icons.remove,
                  () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom - 1,
                    );
                  },
                ),

                const SizedBox(height: 8),

                _mapButton(
                  Icons.my_location,
                  () {
                    mapController.move(
                      defaultLocation,
                      14,
                    );
                  },
                ),
              ],
            ),
          ),

          // ============================
          // BOTTOM FARMER / BUYER LIST
          // ============================
          Positioned(
            left: 15,
            right: 15,
            bottom: 15,

            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 300,
              ),

              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),

                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),

              child: ListView.builder(
                shrinkWrap: true,
                itemCount: locations.length,

                itemBuilder: (context, index) {
                  final item = locations[index];

                  return ListTile(
                    onTap: () {
                      mapController.move(
                        LatLng(
                          item.latitude,
                          item.longitude,
                        ),
                        16,
                      );

                      _showLocationDetails(item);
                    },

                    leading: Container(
                      width: 50,
                      height: 50,

                      decoration: BoxDecoration(
                        color: item.isFarmer
                            ? Colors.green.shade100
                            : Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),

                      child: Icon(
                        item.isFarmer
                            ? Icons.agriculture
                            : Icons.store,
                        color: item.isFarmer
                            ? Colors.green
                            : Colors.blue,
                      ),
                    ),

                    title: Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    subtitle: Text(
                      "${item.location} • ${item.crop} • ${item.quantity}",
                    ),

                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                  );
                },
              ),
            ),
          ),

          // ============================
          // OSM ATTRIBUTION
          // ============================
          Positioned(
            right: 5,
            bottom: 5,

            child: Container(
              color: Colors.white70,
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),

              child: const Text(
                "© OpenStreetMap contributors",
                style: TextStyle(
                  fontSize: 9,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================
  // MAP BUTTON
  // ============================

  Widget _mapButton(
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(12),

      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,

        child: Container(
          width: 48,
          height: 48,

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(
            icon,
            color: Colors.green.shade700,
          ),
        ),
      ),
    );
  }

  // ============================
  // LOCATION DETAILS
  // ============================

  void _showLocationDetails(
    FarmerLocation item,
  ) {
    showModalBottomSheet(
      context: context,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),

      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Row(
                children: [

                  CircleAvatar(
                    radius: 28,
                    backgroundColor: item.isFarmer
                        ? Colors.green.shade100
                        : Colors.blue.shade100,

                    child: Icon(
                      item.isFarmer
                          ? Icons.agriculture
                          : Icons.store,
                      color: item.isFarmer
                          ? Colors.green
                          : Colors.blue,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _detailRow(
                Icons.location_on,
                item.location,
              ),

              _detailRow(
                Icons.eco,
                item.crop,
              ),

              _detailRow(
                Icons.inventory_2,
                item.quantity,
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(
                    Icons.shopping_cart,
                  ),

                  label: const Text(
                    "View Trading Details",
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green,
                    foregroundColor:
                        Colors.white,

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),

      child: Row(
        children: [

          Icon(
            icon,
            color: Colors.green,
          ),

          const SizedBox(width: 12),

          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// Type alias so MapScreen and FarmMapScreen can both be used
typedef MapScreen = FarmMapScreen;

// ========================================
// LOCATION MODEL
// ========================================

class FarmerLocation {
  final String name;
  final String crop;
  final String quantity;
  final String location;

  final double latitude;
  final double longitude;

  final bool isFarmer;

  FarmerLocation({
    required this.name,
    required this.crop,
    required this.quantity,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.isFarmer,
  });
}
