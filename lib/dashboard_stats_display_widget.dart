
import 'package:flutter/material.dart';
import 'main.dart';
import 'records_data_class_db.dart';
import 'package:syncfusion_flutter_charts/charts.dart';



class DashboardViewWidget extends StatefulWidget{
  const DashboardViewWidget({Key? key}) : super(key: key);
  @override
  State<DashboardViewWidget> createState() => _DashboardViewWidget();
}



class _DashboardViewWidget extends State<DashboardViewWidget>{

  @override
  void initState() {
    super.initState();
  }
/// This is for the graphs
  static List<RecordDataStats> _recordRatingsData() {
    List<RecordDataStats> ratingsData = [];
    for (Records record in records) {
      ratingsData.add(RecordDataStats(record.timeCreated, record.rating));
    }
    return ratingsData;
  }
  static List<RecordDataStats> _recordSuccessData(){
    List<RecordDataStats> successData = [];
    successData.add(RecordDataStats('Success', 0.0));
    successData.add(RecordDataStats('Fail', 0.0));
    for(Records record in records){
      if (record.success == 'Success') {
        successData[0].value++;
      }
      else if (record.success == 'Fail') {
        successData[1].value++;
      }
    }
    return successData;


  }
static List<RecordDataStats> _recordEmotionData(){
    List<RecordDataStats> emotionData=[];
    List<String> emotionCounts=[];
    for(Records record in records){
      var words = record.emotions.split(',');
      for(String emotion in words){
        emotionCounts.add(emotion);
      }
      for(String word in emotionCounts)
        {
          RecordDataStats store = RecordDataStats(word, countWordsList(emotionCounts, word) );
          if(!emotionData.contains(store))
            {
              emotionData.add(store);
            }

        }
    }
emotionData.sort((a,b)=> a.compareTo(b));
    return emotionData;
}
static List<RecordDataStats> _recordSymptomData(){
  List<RecordDataStats> symptomData=[];
  List<String> symptomCounts=[];
  for(Records record in records){
    var words = record.symptoms.split(',');
    for(String symptom in words){
      symptomCounts.add(symptom);
    }
    for(String word in symptomCounts)
    {
      RecordDataStats store = RecordDataStats(word, countWordsList(symptomCounts, word) );
      if(!symptomData.contains(store))
      {
        symptomData.add(store);
      }

    }
  }
  symptomData.sort((a,b)=> a.compareTo(b));
  return symptomData;
}

//Method for collecting counts of Words in a list

 static double countWordsList(List<String> list, String element){
    if(list.isEmpty || list == null){
      return 0;
    }
    var wordCount = list.where((word) => word ==element);
    return wordCount.length.toDouble();
  }


  @override
  Widget build(BuildContext context) {

 return ListView(padding: const EdgeInsets.all(8.0),children: [
Card(child: SizedBox(child:SfCartesianChart(primaryXAxis: CategoryAxis(),primaryYAxis: NumericAxis(),
series: <LineSeries<RecordDataStats,String>>[LineSeries(dataSource: _recordRatingsData(),
    xValueMapper: (RecordDataStats recLbl,_)=>recLbl.key,
    yValueMapper: (RecordDataStats recLbl, _)=> recLbl.value,
dataLabelSettings: const DataLabelSettings(isVisible: true),
xAxisName: 'Entry Timestamps',yAxisName: 'Ratings',),],
  title: ChartTitle(text: 'Record ratings data from journal entries'),
) ,height: 300,),),
   Card(child: SizedBox(child:SfCircularChart(title: ChartTitle(text:'Success/Fail stats from Journal Entries'),
     legend: Legend(isVisible: true),
     series: <PieSeries<RecordDataStats,String>>[
       PieSeries<RecordDataStats,String>(
    explode: true,
    explodeIndex: 0,
    dataSource: _recordSuccessData(),
           xValueMapper: (RecordDataStats recs,_) => recs.key,
           yValueMapper: (RecordDataStats recs,_) => recs.value,
           dataLabelMapper: (RecordDataStats recs,_) => "${recs.key}: ${recs.value.toInt()}",
           dataLabelSettings: const DataLabelSettings(isVisible: true),
    ),
    ],
    ),
     height: 300,),),
   //Placeholder code for the rest of the charts. Emotions, Symptoms,
   // and a summary.
   Card(child: SizedBox(child: SfCartesianChart(primaryXAxis: CategoryAxis(),primaryYAxis: NumericAxis(),
   series: <BarSeries<RecordDataStats, String>>[
     BarSeries(dataSource: _recordEmotionData(),
         xValueMapper: (RecordDataStats rec,_) => rec.key,
         yValueMapper: (RecordDataStats rec,_) => rec.value,
    name: 'Emotion Data from Journal Entries',
    color: Colors.red,
    xAxisName: 'Emotions',
    yAxisName: 'Counts',),],
     title: ChartTitle(text: 'Emotion Data from Journal Entries'),),
     height: 300,),),
   Card(child: SizedBox(child: SfCartesianChart(
     primaryXAxis: CategoryAxis(),
     primaryYAxis: NumericAxis(),
    series:<BarSeries<RecordDataStats,String>>[
    BarSeries(dataSource: _recordSymptomData(),
    xValueMapper: (RecordDataStats rec,_) => rec.key,
    yValueMapper: (RecordDataStats rec,_) => rec.value,
    name: 'Symptom Data from Journal Entries',
    color: Colors.red,
    xAxisName: 'Symptoms',
    yAxisName: 'Counts',),],
    title: ChartTitle(text: 'Symptom Data from Journal Entries'),),
   height: 300,),),


 ],
 );
  }
}
// This allows for us to put the categories into their own lists so its easy to track and implement
class RecordDataStats {
  String key = '';
  double value = 0.0;

  RecordDataStats(this.key, this.value);

 /// This forces the list to organize itself based on count values
  int compareTo(RecordDataStats entryData) {
    if (value.compareTo(entryData.value) == 0) {
      return key.compareTo(entryData.key);
    }
    else {
      return value.compareTo(entryData.value);
    }
  }

}