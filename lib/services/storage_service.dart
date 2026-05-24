import 'package:hive_flutter/hive_flutter.dart';
import '../models/diary_entry.dart';

class StorageService {
  static const String boxName = "diary_entries";

  static Future init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static Future saveEntry(DiaryEntry entry) async {
    final box = Hive.box(boxName);

    await box.put(entry.date, entry.toMap());
  }

  static DiaryEntry? getEntry(String date) {
    final box = Hive.box(boxName);

    final data = box.get(date);

    if (data == null) return null;

    return DiaryEntry.fromMap(Map<String, dynamic>.from(data));
  }
}