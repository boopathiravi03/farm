import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/sync_item.dart';

class OfflineService {
  static const String syncKey = 'farm_trading_sync_queue';

  static const String offlineKey = 'farm_trading_offline_mode';

  static Future<void> addToSyncQueue({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final items = await getSyncQueue();

    final item = SyncItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      data: jsonEncode(data),
      createdAt: DateTime.now().toIso8601String(),
    );

    items.add(item);

    final encoded = items.map((item) => jsonEncode(item.toJson())).toList();

    await prefs.setStringList(syncKey, encoded);
  }

  static Future<List<SyncItem>> getSyncQueue() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(syncKey) ?? [];

    return data.map((item) => SyncItem.fromJson(jsonDecode(item))).toList();
  }

  static Future<int> getPendingCount() async {
    final items = await getSyncQueue();

    return items.length;
  }

  static Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(syncKey);
  }

  static Future<void> setOfflineMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(offlineKey, value);
  }

  static Future<bool> isOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(offlineKey) ?? false;
  }
}
