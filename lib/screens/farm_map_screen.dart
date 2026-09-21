import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../models/farm_location.dart';

class FarmMapScreen extends StatefulWidget {
  const FarmMapScreen({super.key});

  @override
  State<FarmMapScreen> createState() => _FarmMapScreenState();
}

class _FarmMapScreenState extends State<FarmMapScreen> {
  MapLibreMapController? mapController;

  final List<FarmLocation> locations = [
    FarmLocation(
      id: 'F001',
      name: 'Farm Trading Farmer',
      type: 'Farmer',
      location: 'Panruti',
      latitude: 11.7767,
      longitude: 79.5520,
      crop: 'Tomato',
      quantity: 500,
    ),
    FarmLocation(
      id: 'B001',
      name: 'Arun Traders',
      type: 'Buyer',
      location: 'Panruti',
      latitude: 11.7720,
      longitude: 79.5580,
      crop: 'Tomato',
      quantity: 500,
    ),
    FarmLocation(
      id: 'B002',
      name: 'Kumar Agro Foods',
      type: 'Buyer',
      location: 'Cuddalore',
      latitude: 11.7480,
      longitude: 79.7714,
      crop: 'Tomato',
      quantity: 1000,
    ),
    FarmLocation(
      id: 'B003',
      name: 'Green Basket Wholesale',
      type: 'Buyer',
      location: 'Villupuram',
      latitude: 11.9401,
      longitude: 79.4861,
      crop: 'Onion',
      quantity: 750,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farm Trading Map'), centerTitle: true),
      body: Stack(
        children: [
          MapLibreMap(
            styleString: 'https://demotiles.maplibre.org/style.json',
            initialCameraPosition: const CameraPosition(
              target: LatLng(11.7767, 79.5520),
              zoom: 10.5,
            ),
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoaded,
            myLocationEnabled: false,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: false,
          ),

          Positioned(left: 16, right: 16, top: 16, child: _buildMapInfo()),

          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _buildLocationList(),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
  }

  Future<void> _onStyleLoaded() async {
    if (mapController == null) return;

    for (final location in locations) {
      await mapController!.addSymbol(
        SymbolOptions(
          geometry: LatLng(location.latitude, location.longitude),
          iconImage: 'marker-15',
          iconSize: 1.5,
          textField: '${location.name}\n${location.crop}',
          textSize: 11,
          textOffset: const Offset(0, 1.8),
        ),
      );
    }
  }

  Widget _buildMapInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.location_on, color: Colors.green),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Farmers and buyers near your trading area',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 190),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final item = locations[index];

          return ListTile(
            dense: true,
            leading: CircleAvatar(
              backgroundColor: item.type == 'Farmer'
                  ? Colors.green.shade100
                  : Colors.blue.shade100,
              child: Icon(
                item.type == 'Farmer' ? Icons.agriculture : Icons.storefront,
                color: item.type == 'Farmer' ? Colors.green : Colors.blue,
              ),
            ),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${item.location} • ${item.crop} • ${item.quantity.toStringAsFixed(0)} Kg',
            ),
            onTap: () {
              mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(item.latitude, item.longitude),
                  13,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
