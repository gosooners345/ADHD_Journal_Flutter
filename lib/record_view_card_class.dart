import 'package:flutter/material.dart';
import 'records_data_class_db.dart';


class RecordCardViewWidget extends StatefulWidget{
  RecordCardViewWidget({Key? key, required this.record}) : super(key: key);
  final Records record;


  @override
  State<RecordCardViewWidget> createState() {
      return _RecordCardViewWidget();
  }
}
class _RecordCardViewWidget extends State<RecordCardViewWidget>{
  bool isExpanded = false;
  SizedBox space2 = const SizedBox(width: 8);
  @override
  Widget build(BuildContext context) {
    return
      Column(
        children: <Widget>[
          // Title Field
          Row(children: [Text(super.widget.record.title), Spacer(),
            Text('Rating: ' + super.widget.record.rating.toString()),],),
          // Content field
          Row(children: [ Expanded(child: Text(super.widget.record.content))]),
          //Feelings
          Row(children: [ Text('I felt ' + super.widget.record.emotions)]),
          //Sources Field
          Row(children: [
            Expanded(child: Text('My thoughts were: ' + super.widget.record.sources)),
          ]),
          // Symptom field
          Row(children: [
            Expanded(child: Text('Related ADHD Symptoms were: ' + super.widget.record.symptoms,maxLines: 2,style:
              TextStyle(fontStyle: FontStyle.italic,overflow: TextOverflow.ellipsis),)),
          ]),
          // Success state
          Row(children: [Text('This was a ' + super.widget.record.success.toLowerCase()+'.'),]),
          // This is for timestamp collection
          Row(children: [Expanded(child:Text('Time created: ' +
              super.widget.record.timeCreated,style: TextStyle(fontStyle: FontStyle.italic),))
          ,space2,Expanded(child:Text('Time updated: '
          + super.widget.record.timeUpdated,style: TextStyle(fontStyle: FontStyle.italic),)),],),
          /*Row(children: [
          ],),*/
        ],
      );
  }

}
