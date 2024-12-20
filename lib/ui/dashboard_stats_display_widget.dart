import 'package:adhd_journal_flutter/record_data_package/record_list_class.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardViewWidget extends StatefulWidget {
  const DashboardViewWidget({super.key});
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
      enablePinching: true, enablePanning: true, zoomMode: ZoomMode.x);
  ZoomPanBehavior zoomPanBehavior2 = ZoomPanBehavior(
      enableDoubleTapZooming: true, enablePanning: true, zoomMode: ZoomMode.x);
  ZoomPanBehavior zoomPanBehavior1 = ZoomPanBehavior(
      enableDoubleTapZooming: true, enablePanning: true, zoomMode: ZoomMode.x);

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
        "Your most recently occurring symptoms are: ${recordsBloc.recordHolder.last.symptoms}.";

    return summaryString;
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(builder: (context, swapper, child) {
    return  CustomScrollView(slivers: [
        SliverList(delegate: SliverChildListDelegate([
          const Center(child: Text("Summary of statistics"),)
        ])),
      SliverSafeArea(
          top: true,left: true,right: true,bottom: true,minimum: const EdgeInsets.all(10),
          sliver:
      SliverList(delegate: SliverChildListDelegate([
        Card(
          borderOnForeground: true,
          elevation: 2.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Color(swapper.isColorSeed).withOpacity(1.0))),
          margin: const EdgeInsets.all(5),
          child:
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 5),
            child: Text(
                'Here\'s a summary of your statistics:\r\n${summaryGen()}',
                style: const TextStyle(
                    fontSize: 16.0, fontStyle: FontStyle.italic)),

          ),),
   /*     Card(
          borderOnForeground: true,
          elevation: 2.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Color(swapper.isColorSeed).withOpacity(1.0))),

          child:
          GridTile(child:
          Column(children: [

            SfCartesianChart(
              zoomPanBehavior: zoomPanBehavior,
              borderWidth: 2.0,
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(),
              series: <LineSeries<RecordRatingStats, String>>[
                LineSeries(
                  dataSource: RecordList.ratingsList,
                  width: 1.0,
                  xValueMapper: (RecordRatingStats recLbl, _) =>
                      DateFormat("MM/dd/yyyy hh:mm:ss aa")
                          .format(recLbl.date),
                  color: Color(swapper.isColorSeed),
                  yValueMapper: (RecordRatingStats recLbl, _) =>
                  recLbl.value,
                  dataLabelSettings:
                  const DataLabelSettings(isVisible: true),
                  xAxisName: 'Entry Timestamps',
                  yAxisName: 'Ratings',
                ),
              ],
              title: ChartTitle(
                  text: 'Ratings data from journal entries'),
              margin: const EdgeInsets.all(8.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 15,
                ),
                const Text('Reset Zoom'),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => zoomPanBehavior.reset(),
                )

              ],)



          ])),
        ),*/
        Card(
            borderOnForeground: true,
            elevation: 2.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Color(swapper.isColorSeed).withOpacity(1.0))),
            margin: const EdgeInsets.all(5),
            child:GridTile(child:
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SfCircularChart(
                title: ChartTitle(
                    text: 'Success/Fail Data from Journal Entries'),
                legend: Legend(isVisible: true),
                series: <PieSeries<RecordDataStats, String>>[
                  PieSeries<RecordDataStats, String>(
                    explode: true,
                    explodeIndex: 0,
                    dataSource: RecordList.successList,
                    xValueMapper: (RecordDataStats recs, _) => recs.key,
                    yValueMapper: (RecordDataStats recs, _) => recs.value,
                    dataLabelMapper: (RecordDataStats recs, _) =>
                    "${recs.key}: ${((recs.value / recordsBloc.recordHolder.length.toDouble()) * 100.0).toStringAsFixed(2)} % ",
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                    ),
                  ),
                ],
              ),
            ),
            )),
        Card(borderOnForeground: true,
          elevation: 2.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Color(swapper.isColorSeed).withOpacity(1.0))),
          margin: const EdgeInsets.all(5),
          child: GridTile(child: Column(children: [
            SizedBox(
              height: 400,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SfCartesianChart(
                  zoomPanBehavior: zoomPanBehavior1,
                  trackballBehavior: TrackballBehavior(
                      activationMode: ActivationMode.doubleTap),
                  borderWidth: 2.0,
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(),
                  series: <BarSeries<RecordDataStats, String>>[
                    BarSeries(
                      dataSource: RecordList.emotionsList,
                      xValueMapper: (RecordDataStats rec, _) =>
                      rec.key,
                      yValueMapper: (RecordDataStats rec, _) =>
                      rec.value,
                      name: 'Emotion Data from Journal Entries',
                      color: Color(swapper.isColorSeed),
                      xAxisName: 'Emotions',
                      spacing: 0,
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                      ),
                      yAxisName: 'Counts',
                    ),
                  ],
                  title: ChartTitle(
                      text: 'Emotion Data from Journal Entries'),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 15,
                ),
                const Text('Reset Zoom'),
                IconButton(
                    onPressed: () => zoomPanBehavior1.reset(),
                    icon: const Icon(Icons.refresh)),
              ],
            ),
          ],),),
        ),
        Card(
          borderOnForeground: true,
          elevation: 2.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Color(swapper.isColorSeed).withOpacity(1.0))),
          margin: const EdgeInsets.all(5),

          child: GridTile(child: Column(
          children: [
            SizedBox(
              height: 850,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SfCartesianChart(
                  trackballBehavior: TrackballBehavior(
                      activationMode: ActivationMode.doubleTap),
                  zoomPanBehavior: zoomPanBehavior2,
                  borderWidth: 2.0,
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(),
                  series: <BarSeries<RecordDataStats, String>>[
                    BarSeries(
                        dataSource: RecordList.symptomList,
                        xValueMapper: (RecordDataStats rec, _) =>
                        rec.key,
                        yValueMapper: (RecordDataStats rec, _) =>
                        rec.value,
                        name: 'Symptom Data from Journal Entries',
                        color: Color(swapper.isColorSeed),
                        xAxisName: 'Symptoms',
                        yAxisName: 'Counts',
                        spacing: 0.5,
                        dataLabelSettings:
                        const DataLabelSettings(isVisible: true)),
                  ],
                  title: ChartTitle(
                      text: 'Symptom Data from Journal Entries'),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 15,
                ),
                const Text('Reset Zoom'),
                IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => zoomPanBehavior2.reset()),
              ],
            ),
          ],
        ) ,),)
      ]),),





      )
      ],);

    });
  }
}
