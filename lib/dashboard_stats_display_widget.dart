
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
    // The following is for later if needed
    //DateFormat('MM/dd/yyyy hh:mm:ss:aa').parse(record.timeCreated)
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

  // measurePercentages(successData[0].value, successData[1].value);

    return successData;
  }
static List<RecordDataStatsInt> _recordEmotionData(){
    List<RecordDataStatsInt> emotionData=[];
    List<String> emotionCounts=[];
    for(Records record in records){
      var words = record.emotions.split(',');
      for(String emotion in words){
        emotionCounts.add(emotion);
      }
      for(String word in emotionCounts)
        {
          RecordDataStatsInt store = RecordDataStatsInt(word, countWordsList(emotionCounts, word).toInt() );
          if(!emotionData.contains(store))
            {
              emotionData.add(store);
            }

        }
    }
emotionData.sort((a,b)=> a.compareTo(b));
    emotionData= emotionData.reversed.toList();
    return emotionData;
}
static List<RecordDataStatsInt> _recordSymptomData(){
  List<RecordDataStatsInt> symptomData=[];
  List<String> symptomCounts=[];
  for(Records record in records){
    var words = record.symptoms.split(',');
    for(String symptom in words){
      symptomCounts.add(symptom);
    }
    for(String word in symptomCounts){
      RecordDataStatsInt store = RecordDataStatsInt(word, countWordsList(symptomCounts, word).toInt());
      if(!symptomData.contains(store)){
        symptomData.add(store);
      }
    }
  }
  symptomData.sort((a,b)=> a.compareTo(b));
  symptomData=symptomData.reversed.toList();
  return symptomData;
}

//Method for collecting counts of Words in a list
 static double countWordsList(List<String> list, String element){
    if(list.isEmpty){
      return 0;
    }
    var wordCount = list.where((word) => word ==element);
    return wordCount.length.toDouble();
  }

  static String summaryGen(){
    String summaryString ='';
    String successString ='';
    double avgRating = 0.0;
    // For the ratings
    List<double> sum = _recordRatingsData().map((e) => e.value).toList();
    double totalRtg = 0.0;
    for(double rating in sum){
      totalRtg +=rating;
    }
    avgRating = (totalRtg/records.length.toDouble());
    // For the success/fail section
    if(_recordSuccessData()[0].value > _recordSuccessData()[1].value){
      successString = "Success";
    }
    else{
      successString = "Fail";
    }

    //For the symptom and emotion section

    summaryString = "You have ${records.length} entries in your journal.\r\n"
        "Your average rating is $avgRating.\r\n"
        "You're trending more  on $successString based on your Success/Fail ratings.\r\n"
        "Your most recently occurring symptoms are: ${records.last.symptoms}.";

    return  summaryString;
  }

  @override
  Widget build(BuildContext context) {

 return ListView(padding: const EdgeInsets.all(8.0),children: [
   Card(child:SizedBox(
     child: Text('Here\'s a summary of your statistics:\r\n ${summaryGen()}',style: TextStyle(fontSize:16.0,fontStyle: FontStyle.italic)),),),
   //Ratings Chart
Card(elevation: 2.0,child: SizedBox(child:SfCartesianChart(
  zoomPanBehavior: ZoomPanBehavior(enablePinching: true,enableDoubleTapZooming: false,
enablePanning: true,zoomMode: ZoomMode.xy),borderWidth: 2.0,
  primaryXAxis: CategoryAxis(),primaryYAxis: NumericAxis(),
series: <LineSeries<RecordDataStats,String>>[LineSeries(dataSource: _recordRatingsData(),
    xValueMapper: (RecordDataStats recLbl,_)=>recLbl.key,
    color: Colors.brown,
    yValueMapper: (RecordDataStats recLbl, _)=> recLbl.value,
dataLabelSettings: const DataLabelSettings(isVisible: true),
xAxisName: 'Entry Timestamps',yAxisName: 'Ratings',),],
  title: ChartTitle(text: 'Ratings data from journal entries'),
) ,height: 300,),),
   // Success/Fail Chart
   Card(elevation: 2.0,child: SizedBox(child:SfCircularChart(title: ChartTitle(text:'Success/Fail Data from Journal Entries'),
     legend: Legend(isVisible: true),
     series: <PieSeries<RecordDataStats,String>>[
       PieSeries<RecordDataStats,String>(
    explode: true,
    explodeIndex: 0,
    dataSource: _recordSuccessData(),
           xValueMapper: (RecordDataStats recs,_) => recs.key,
           yValueMapper: (RecordDataStats recs,_) => recs.value,
           dataLabelMapper: (RecordDataStats recs,_)=> "${recs.key}: ${(recs.value/records.length.toDouble()) * 100.0 } % ",
           dataLabelSettings: const DataLabelSettings(isVisible: true),
    ),
    ],
    ),
     height: 300,),),
//Emotions Chart
   Card(elevation: 2.0,child: SizedBox(child: SfCartesianChart(
     zoomPanBehavior: ZoomPanBehavior(enablePinching: true,enableDoubleTapZooming: false,
         enablePanning: true,zoomMode: ZoomMode.xy),borderWidth: 2.0,
     primaryXAxis: CategoryAxis(),primaryYAxis: NumericAxis(),
   series: <ColumnSeries<RecordDataStatsInt, String>>[
     ColumnSeries(dataSource: _recordEmotionData(),
         xValueMapper: (RecordDataStatsInt rec,_) => rec.key,
         yValueMapper: (RecordDataStatsInt rec,_) => rec.value,
    name: 'Emotion Data from Journal Entries',
    color: Colors.brown,
    xAxisName: 'Emotions',
    yAxisName: 'Counts',),],
     title: ChartTitle(text: 'Emotion Data from Journal Entries'),),
     height: 300,),),
   //Symptoms Chart
   Card(elevation:2.0,child: SizedBox(child: SfCartesianChart(
     zoomPanBehavior: ZoomPanBehavior(enablePinching: true,enableDoubleTapZooming: false,
         enablePanning: true,zoomMode: ZoomMode.xy),borderWidth: 2.0,
     primaryXAxis: CategoryAxis(),
     primaryYAxis: NumericAxis(),
    series:<BarSeries<RecordDataStatsInt,String>>[
    BarSeries(dataSource: _recordSymptomData(),
    xValueMapper: (RecordDataStatsInt rec,_) => rec.key,
    yValueMapper: (RecordDataStatsInt rec,_) => rec.value,
    name: 'Symptom Data from Journal Entries',
    color: Colors.brown,
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
      return key.toUpperCase().compareTo(entryData.key.toUpperCase());
    }
    else {
      return value.compareTo(entryData.value);
    }
  }

}
class RecordDataStatsInt {
  String key = '';
  int value = 0;

  RecordDataStatsInt(this.key, this.value);

  /// This forces the list to organize itself based on count values
  int compareTo(RecordDataStatsInt entryData) {
    if (value.compareTo(entryData.value) == 0) {
      return key.toUpperCase().compareTo(entryData.key.toUpperCase());
    }
    else {
      return value.compareTo(entryData.value);
    }
  }

}