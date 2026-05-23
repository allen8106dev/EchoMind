import 'package:hive_flutter/hive_flutter.dart';
import '../models/diary_entry.dart';

class StorageService {
  static const String boxName = "diary_entries";

  static Future init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static Future addEntry(DiaryEntry entry) async {
    final box = Hive.box(boxName);

    await box.add(entry.toMap());
  }

  static List<DiaryEntry> getEntries() {
    final box = Hive.box(boxName);

    return box.values
        .map((e) => DiaryEntry.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }
}