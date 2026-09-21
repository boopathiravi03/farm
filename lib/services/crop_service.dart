import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crop.dart';
import 'offline_service.dart';

class CropService {
  static const String cropsKey = 'farm_trading_crops';

  static Future<List<Crop>> getCrops() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(cropsKey) ?? [];

    return data.map((item) => Crop.fromJson(jsonDecode(item))).toList();
  }

  static Future<void> addCrop(Crop crop) async {
    final prefs = await SharedPreferences.getInstance();

    final crops = await getCrops();

    crops.add(crop);

    final data = crops.map((crop) => jsonEncode(crop.toJson())).toList();

    await prefs.setStringList(cropsKey, data);

    await OfflineService.addToSyncQueue(
      type: 'crop_create',
      data: crop.toJson(),
    );
  }

  static Future<void> deleteCrop(String id) async {
    final prefs = await SharedPreferences.getInstance();

    final crops = await getCrops();

    crops.removeWhere((crop) => crop.id == id);

    final data = crops.map((crop) => jsonEncode(crop.toJson())).toList();

    await prefs.setStringList(cropsKey, data);
  }
}
