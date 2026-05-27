class AIResponse {

  final String title;
  final String mood;
  final String summary;
  final List<dynamic> keywords;
  final List<dynamic> highlights;
  final String suggestion;

  AIResponse({

    required this.title,

    required this.mood,

    required this.summary,

    required this.keywords,

    required this.highlights,

    required this.suggestion,
  });

  factory AIResponse.fromJson(
      Map<String, dynamic> json) {

    return AIResponse(

      title:
      json['title'] ?? '',

      mood:
      json['mood'] ?? '',

      summary:
      json['summary'] ?? '',

      keywords:
      json['keywords'] ?? [],

      highlights:
      json['highlights'] ?? [],

      suggestion:
      json['suggestion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {

    return {

      "title": title,

      "mood": mood,

      "summary": summary,

      "keywords": keywords,

      "highlights": highlights,

      "suggestion": suggestion,
    };
  }
}