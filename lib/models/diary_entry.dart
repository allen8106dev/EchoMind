class DiaryEntry {
  final String date;
  final String content;

  DiaryEntry({
    required this.date,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'content': content,
    };
  }

  factory DiaryEntry.fromMap(Map map) {
    return DiaryEntry(
      date: map['date'],
      content: map['content'],
    );
  }
}