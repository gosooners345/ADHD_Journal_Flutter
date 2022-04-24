
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'records_data_class_db.dart';
import 'recordsdatabase_handler.dart';
import 'compose_records_screen.dart';
import 'package:charts_flutter/flutter.dart' as charts;



class DashboardViewWidget extends StatefulWidget{
  const DashboardViewWidget({Key? key}) : super(key: key);
  @override
  State<DashboardViewWidget> createState() => _DashboardViewWidget();
}



class _DashboardViewWidget extends State<DashboardViewWidget>{




   List<charts.Series<Records, DateTime>> seriesList= _getRatingsData();
   List<charts.Series<RecordSuccessCount,Object>> successSeries = _getSuccessData();

  @override
  void initState() {
    super.initState();
    

    
  }
/// This is for
static List<charts.Series<Records,DateTime>> _getRatingsData()
   {     return [
        charts.Series(id: 'Ratings', data: records,  domainFn: (Records record,_) => DateFormat('MM/dd/yyyy hh:mm:ss:aa').parse(record.timeCreated),
            measureFn: (Records record,_) =>record.rating)
     ];
}
static List<charts.Series<RecordSuccessCount,Object>> _getSuccessData() {
  List<RecordSuccessCount> recordCounts = List.empty(growable: true);
  recordCounts.add(RecordSuccessCount('Success', 0.0));
  recordCounts.add(RecordSuccessCount('Fail', 0.0));

  for (Records record in records) {
    if (record.success == 'Success') {
      recordCounts[0].count++;
    }
    else if (record.success == 'Fail') {
      recordCounts[1].count++;
    }

  }
  return [
    charts.Series(id: 'Success',
      data: recordCounts,
      domainFn: (RecordSuccessCount success, _) => success.words,
      measureFn: (RecordSuccessCount counts, _) => counts.count,
    )
  ];
}
  @override
  Widget build(BuildContext context) {
 return Scaffold(
   appBar: AppBar(title: const Text("Statistics"),),
   body: ListView(padding: EdgeInsets.all(8.0),children: [
     //Text('Statistics Data from your journal',textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0),),
     Card(child:SizedBox(height: 300,child:charts.TimeSeriesChart(seriesList,behaviors: [
     charts.ChartTitle('Record Ratings from Journal Entries',behaviorPosition: charts.BehaviorPosition.top),
     charts.ChartTitle('Rating Values',behaviorPosition: charts.BehaviorPosition.start),
     charts.ChartTitle('Date',behaviorPosition: charts.BehaviorPosition.bottom),

   ],
   ),
   )
   ),
     Card(child: SizedBox(height:300 ,child:charts.PieChart(successSeries,animate: false,),),)

   ],),

 );
  }
}


class RecordSuccessCount{
  String words ='';
  double count = 0.0;
  RecordSuccessCount(this.words,this.count);
}