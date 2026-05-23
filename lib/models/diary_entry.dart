class DiaryEntry {
  final String text;
  final DateTime createdAt;

  DiaryEntry({
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DiaryEntry.fromMap(Map map) {
    return DiaryEntry(
      text: map['text'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}