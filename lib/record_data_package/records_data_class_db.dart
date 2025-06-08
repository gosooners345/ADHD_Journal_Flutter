

import 'dart:typed_data';

///Adding ability to insert pictures, audio or video.
///See if compatible with SQLite before starting
/// Media variable added to store blob for media data.

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
Uint8List media = Uint8List(0);
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
        required this.media,
      required this.timeCreated,
      required this.timeUpdated,}
  );



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
      'media': media,
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
  Uint8List convertBytestoList(dynamic bytedata){
    if(bytedata!=null){
      Uint8List list = Uint8List.fromList(bytedata);
      return list;} else {
      return Uint8List(0);
    }
  }




}
