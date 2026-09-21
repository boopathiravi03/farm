import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/crop_passport.dart';

class CropPassportService {
  static const String passportKey = 'farm_trading_passports';

  static Future<List<CropPassport>> getPassports() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(passportKey) ?? [];

    return data.map((item) => CropPassport.fromJson(jsonDecode(item))).toList();
  }

  static Future<void> savePassport(CropPassport passport) async {
    final prefs = await SharedPreferences.getInstance();

    final passports = await getPassports();

    passports.add(passport);

    final data = passports.map((item) => jsonEncode(item.toJson())).toList();

    await prefs.setStringList(passportKey, data);
  }

  static Future<CropPassport?> findPassport(String passportId) async {
    final passports = await getPassports();

    try {
      return passports.firstWhere(
        (passport) => passport.passportId == passportId,
      );
    } catch (_) {
      return null;
    }
  }
}
