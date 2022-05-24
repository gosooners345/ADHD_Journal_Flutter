



import 'package:adhd_journal_flutter/record_list_class.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adhd_journal_flutter/project_colors.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'main.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardViewWidget extends StatefulWidget {
  const DashboardViewWidget({Key? key}) : super(key: key);
  @override
  State<DashboardViewWidget> createState() => _DashboardViewWidget();
}

class _DashboardViewWidget extends State<DashboardViewWidget> {
  @override
  void initState() {
    super.initState();
  }

//Method for collecting counts of Words in a list
ZoomPanBehavior zoomPanBehavior = ZoomPanBehavior(
    enableDoubleTapZooming: true,
    enablePanning: true,
    zoomMode: ZoomMode.xy
);
  ZoomPanBehavior zoomPanBehavior2 = ZoomPanBehavior(
      enableDoubleTapZooming: true,
      enablePanning: true,
      zoomMode: ZoomMode.xy
  );
  ZoomPanBehavior zoomPanBehavior1 = ZoomPanBehavior(
      enableDoubleTapZooming: true,
      enablePanning: true,
      zoomMode: ZoomMode.xy
  );

  String summaryGen() {
    String summaryString = '';
    String successString = '';
    double avgRating = 0.0;

    // For the ratings
    List<double> sum = RecordList.ratingsList.map((e) => e.value).toList();
    double totalRtg = 0.0;
    for (double rating in sum) {
      totalRtg += rating;
    }
    avgRating = (totalRtg / recordsBloc.recordHolder.length.toDouble());
    // For the success/fail section
    if (RecordList.successList[0].value > RecordList.successList[1].value) {
      successString = "success";
    } else {
      successString = "fail";
    }

    //For the symptom and emotion section

    summaryString =
        "You have ${recordsBloc.recordHolder.length} entries in your journal.\r\n"
        "Your average rating is ${avgRating.roundToDouble()}.\r\n"
        "You're trending more  on $successString based on your Success/Fail ratings.\r\n"
        "Your most recently occurring symptoms are: ${recordsBloc.recordHolder.first.symptoms}.";

    return summaryString;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        Card(
    shape:  RoundedRectangleBorder(side: BorderSide(color: AppColors.mainAppColor,width: 1.0),borderRadius: BorderRadius.circular(10)),
          elevation: 2.0,
          child: SizedBox(
            child: Padding
              (padding:const EdgeInsets.all(5.0),child:Text(
                'Here\'s a summary of your statistics:\r\n ${summaryGen()}',
                style: const TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic)),
          ),              ),
        ),
        //Ratings Chart
        Card(
          elevation: 2.0,
            child:Column(children:[
            Padding(padding: EdgeInsets.all(16.0), child: SfCartesianChart(
              zoomPanBehavior: zoomPanBehavior,
              trackballBehavior:TrackballBehavior(activationMode: ActivationMode.doubleTap), //SparkChartTrackball(activationMode: SparkChartActivationMode.doubleTap),
              borderWidth: 2.0,
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(),
              series: <LineSeries<RecordRatingStats, String>>[
                LineSeries(
                  dataSource: RecordList.ratingsList,
                  width: 1.0,
                  xValueMapper: (RecordRatingStats recLbl, _) =>
                      DateFormat("MM/dd/yyyy hh:mm:ss aa").format(recLbl.date),
                  color: AppColors.mainAppColor,
                  yValueMapper: (RecordRatingStats recLbl, _) => recLbl.value,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  xAxisName: 'Entry Timestamps',
                  yAxisName: 'Ratings',
                ),
              ],
              title: ChartTitle(text: 'Ratings data from journal entries'),
            ),

          ),
             Row(mainAxisAlignment: MainAxisAlignment.end,children: [ Text('Reset Zoom'),IconButton(icon: Icon(Icons.refresh),onPressed:()=> zoomPanBehavior.reset(),)],),
            ],),
            shape:  RoundedRectangleBorder(side: BorderSide(color: AppColors.mainAppColor,width: 1.0),borderRadius: BorderRadius.circular(10)),
        ),
        // Success/Fail Chart
        Card(shape:  RoundedRectangleBorder(side: BorderSide(color: AppColors.mainAppColor,width: 1.0),borderRadius: BorderRadius.circular(10)),
          elevation: 2.0,

            child: Padding(padding: EdgeInsets.all(16.0), child: SfCircularChart(
              title: ChartTitle(text: 'Success/Fail Data from Journal Entries'),
              legend: Legend(isVisible: true),

              series: <PieSeries<RecordDataStats, String>>[
                PieSeries<RecordDataStats, String>(
                  explode: true,
                  explodeIndex: 0,

                  dataSource: RecordList.successList,
                  xValueMapper: (RecordDataStats recs, _) => recs.key,
                  yValueMapper: (RecordDataStats recs, _) => recs.value,
                  dataLabelMapper: (RecordDataStats recs, _) =>
                      "${recs.key}: ${(recs.value / recordsBloc.recordHolder.length.toDouble()) * 100.0} % ",
                  dataLabelSettings: const DataLabelSettings(isVisible: true,),
                ),
              ],
            ),
            ),
        ),
//Emotions Chart
        Card(shape:  RoundedRectangleBorder(side: BorderSide(color: AppColors.mainAppColor,width: 1.0),borderRadius: BorderRadius.circular(10)),
          elevation: 2.0,
            child:Column(children: [
            Padding(padding: EdgeInsets.all(16.0), child: SfCartesianChart(
              zoomPanBehavior:zoomPanBehavior1,
              trackballBehavior:TrackballBehavior(activationMode: ActivationMode.doubleTap),
              borderWidth: 2.0,
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(),
              series: <BarSeries<RecordDataStats, String>>[
                BarSeries(
                  dataSource: RecordList.emotionsList,
                  xValueMapper: (RecordDataStats rec, _) => rec.key,
                  yValueMapper: (RecordDataStats rec, _) => rec.value,
                  name: 'Emotion Data from Journal Entries',
                  color: AppColors.mainAppColor,
                  xAxisName: 'Emotions',
                  spacing: 1.5,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                  ),
                  yAxisName: 'Counts',
                ),
              ],
              title: ChartTitle(text: 'Emotion Data from Journal Entries'),
            ),
          ),
              Row(children: [Text('Reset Zoom'),IconButton(onPressed: ()=>zoomPanBehavior1.reset(), icon: Icon(Icons.refresh)),],mainAxisAlignment: MainAxisAlignment.end,),
            ],)
        ),
        //Symptoms Chart
        Card(
          shape:  RoundedRectangleBorder(side: BorderSide(color: AppColors.mainAppColor,width: 1.0),borderRadius: BorderRadius.circular(10)),
          elevation: 2.0,
          //child: //SizedBox(
            child:Column(children: [
            Padding(padding: EdgeInsets.all(16.0), child:SfCartesianChart(
              trackballBehavior:TrackballBehavior(activationMode: ActivationMode.doubleTap), //SparkChartTrackball(activationMode: SparkChartActivationMode.doubleTap),
              zoomPanBehavior: zoomPanBehavior2,
              borderWidth: 2.0,
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(),
              series: <BarSeries<RecordDataStats, String>>[
                BarSeries(
                    dataSource: RecordList.symptomList,
                    xValueMapper: (RecordDataStats rec, _) => rec.key,
                    yValueMapper: (RecordDataStats rec, _) => rec.value,
                    name: 'Symptom Data from Journal Entries',
                    color: AppColors.mainAppColor,
                    xAxisName: 'Symptoms',
                    yAxisName: 'Counts',
                    spacing: 1.5,
                    dataLabelSettings:
                        const DataLabelSettings(isVisible: true)),
              ],
              title: ChartTitle(text: 'Symptom Data from Journal Entries'),
            ),
          ),
             Row(mainAxisAlignment:MainAxisAlignment.end,children: [ Text('Reset Zoom'),IconButton(icon: Icon(Icons.refresh),onPressed:() =>zoomPanBehavior2.reset()),],),

            ],
            ),),
      ],
    );
  }
}

// This allows for us to put the categories into their own lists so its easy to track and implement
class RecordDataStats extends Comparable {
  String key = '';
  double value = 0.0;
  int altValue = 0;
  RecordDataStats(this.key, this.value);

  Map<String, Object> toMap() {
    return {"key": key, "value": value};
  }

  @override
  int compareTo(other) {
    final otherRecord = other as RecordDataStats;
    if (value.compareTo(otherRecord.value) == 0) {
      return key.toUpperCase().compareTo(otherRecord.key.toUpperCase());
    } else {
      return value.compareTo(otherRecord.value);
    }
  }
}
