


class Records {
  final int id;
  final String title;
  final String content;
  /*final String sources;
  final String emotions;
  final String symptoms;
  final String tags;
  final double rating;
  final bool success;
  final DateTime timeCreated;
  final DateTime timeUpdated;*/

  const Records({
    required this.id,
    required this.title,
    required this.content,
    /*required this.sources,
    required this.emotions,
    required this.symptoms,
    required this.tags,
    required this.rating,
    required this.success,
    required this.timeCreated,
    required this.timeUpdated*/
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      /*'sources': sources,
      'emotions': emotions,
      'symptoms': symptoms,
      'tags': tags,
      'rating': rating,
      'success': success,
      'timeCreated': timeCreated,
      'timeUpdated': timeUpdated*/
    };
  }

  @override
  String toString() {
    return 'Records{ id: $id, title: $title, content: $content}';
  }
}