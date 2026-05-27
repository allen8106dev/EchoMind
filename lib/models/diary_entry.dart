import '../services/ai_response.dart';

class DiaryEntry {

  final String date;

  final List<Map<String, dynamic>> entries;

  final Map<String, dynamic>? aiReflection;

  final bool aiNeedsRefresh;

  DiaryEntry({

    required this.date,

    required this.entries,

    this.aiReflection,

    this.aiNeedsRefresh = false,
  });

  Map<String, dynamic> toMap() {

    return {

      'date': date,

      'entries': entries,

      'aiReflection': aiReflection,

      'aiNeedsRefresh': aiNeedsRefresh,
    };
  }

  factory DiaryEntry.fromMap(
      Map<String, dynamic> map) {

    return DiaryEntry(

      date: map['date'] ?? '',

      entries:
      (map['entries'] as List? ?? [])

          .map(
            (e) => Map<String, dynamic>.from(
          e as Map,
        ),
      )

          .toList(),

      aiReflection:
      map['aiReflection'] != null

          ? Map<String, dynamic>.from(
        map['aiReflection'],
      )

          : null,

      aiNeedsRefresh:
      map['aiNeedsRefresh'] ?? false,
    );
  }
}