

import 'dart:typed_data';

///Adding ability to insert pictures, audio or video.
///See if compatible with SQLite before starting


class Records implements Comparable {
  int id;
  String title;
  String content;
  String emotions;
  String sources;
  String symptoms;
  String tags;
  double rating;
  bool success;
  DateTime timeCreated;
  DateTime timeUpdated;
ByteData image = ByteData(0);
  Records(
      {required this.id,
      required this.title,
      required this.content,
      required this.emotions,
      required this.sources,
      required this.symptoms,
      required this.tags,
      required this.rating,
      required this.success,
      required this.timeCreated,
      required this.timeUpdated,}
  );

  Records.fromMap(Map<String, dynamic> record)
      : id = record['id'],
        title = record['title'],
        content = record['content'],
        emotions = record['emotions'],
        sources = record['sources'],
        symptoms = record['symptoms'],
        tags = record['tags'],
        rating = record['rating'],
        success = record['success'],

        timeCreated = record['time_created'],
        timeUpdated = record['time_updated'];


  @override
  String toString() {
    return 'Title: $title \r\nDetails: $content \r\nEmotions: $emotions\r\nSources: $sources'
        '\r\nSymptoms: $symptoms\r\nRating: $rating\r\nTime Created: $timeCreated\r\n'
        'Time Updated: $timeUpdated';
  }

  Map<String, Object> toMapForDB() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'emotions': emotions,
      'symptoms': symptoms,
      'sources': sources,
      'tags': tags,
      'rating': rating,
      'success': success ? 1 : 0,
      'time_created': timeCreated.millisecondsSinceEpoch,
      'time_updated': timeUpdated.millisecondsSinceEpoch
    };
  }

  int comparableIDs(int a, int b) {
    return a.compareTo(b);
  }

  static Comparable compareTimes(Records a, Records b) {
    return a.compareTimesUpdated(b.timeUpdated);
  }

  @override
  int compareTo(other) {
    return compareTimesUpdated(other.timeUpdated);
  }

  int compareTitles(String title) {
    return title
        .trimLeft()
        .toUpperCase()
        .compareTo(title.trimLeft().toUpperCase());
  }

  int compareTags(String tags) {
    return tags.toUpperCase().compareTo(tags.toUpperCase());
  }

  int compareTimesUpdated(DateTime other) {
    if (timeUpdated.isBefore(other)) {
      return 1;
    } else if (timeUpdated.isAfter(other)) {
      return -1;
    } else {
      return 0;
    }
  }

  int compareTimesCreated(DateTime other) {
    return timeCreated.compareTo(other);
  }

  int compareRatings(double other) {
    return rating.compareTo(other);
  }


  void addImage(ByteData data){
   image = data;
  }


}
