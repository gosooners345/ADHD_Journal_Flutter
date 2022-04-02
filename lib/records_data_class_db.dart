


class Records{
  final int id;
  final String title;
  final String content;
 /* final String sources;
  final String emotions;
  final String symptoms;
  final String tags;
  final double rating;
  final bool success;*/

  Records({required this.id, required this.title,required this.content ,/*required this.emotions,required this.sources,
    required this.symptoms,
required this.tags,required this.rating,required this.success*/});

  Records.fromMap(Map<String,dynamic> record):
      id = record['id'],
  title=record['title'],
  content=record['content'];
/*  emotions=record['emotions'],
  sources=record['sources'],
  symptoms = record['symptoms'],
  tags = record['tags'],
  rating = record['rating'],
  success = record['success']*/


  Map<String, Object>toMapForDB(){
  return {'id':id,'title':title,'content':content,/*'emotions':emotions,
  'sources':sources,'tags':tags,'rating':rating,'success':success*/};
}

}