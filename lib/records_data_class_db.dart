

class Records{
   int id;
   String title;
   String content;
   String emotions;
   String sources;
  String symptoms;
   String tags;
 double rating;
String success;
String timeCreated;
String timeUpdated;

  Records({required this.id, required this.title,required this.content ,required this.emotions,
    required this.sources,
    required this.symptoms,
required this.tags,
required this.rating,
required this.success,
  required this.timeCreated,
  required this.timeUpdated});





  Records.fromMap(Map<String,dynamic> record):
      id = record['id'],
  title=record['title'],
  content=record['content'],
  emotions=record['emotions'],
  sources=record['sources'],
  symptoms = record['symptoms'],
  tags = record['tags'],
  rating = record['rating'],
  success = record['success'],
   timeCreated = record['timeCreated'],
   timeUpdated = record['timeUpdated'];


@override
  String toString(){
    return'Title: $title \r\nDetails: $content \r\nEmotions: $emotions\r\nSources: $sources'
        '\r\nSymptoms: $symptoms\r\nRating: $rating\r\nTime Created: $timeCreated\r\n'
        'Time Updated: $timeUpdated';
  }

  Map<String, Object>toMapForDB(){
  return {'id':id,'title':title,'content':content,'emotions':emotions, 'symptoms':symptoms,
  'sources':sources,'tags':tags,'rating':rating,'success':success ,
    'timeCreated':timeCreated,'timeUpdated':timeUpdated
  };
}

static Comparable comparableIDs(int a,int b){
  return a.compareTo(b);
}


}