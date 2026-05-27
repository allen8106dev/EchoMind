class DiaryEntry {

  final String date;

  final List<Map<String, dynamic>> entries;

  DiaryEntry({
    required this.date,
    required this.entries,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'entries': entries,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      date: map['date'] ?? '',

        entries: (map['entries'] as List? ?? [])
            .map(
              (e) => Map<String, dynamic>.from(e as Map),
        )
            .toList(),
    );
  }
}