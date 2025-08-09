import 'package:adhd_journal_flutter/project_resources/project_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../app_start_package/splash_screendart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:collection/collection.dart';
import '../records_stream_package/records_bloc_class.dart';




class DashboardViewWidget extends StatefulWidget {
  const DashboardViewWidget({super.key});
  @override
  State<DashboardViewWidget> createState() => _DashboardViewWidget();
}
class _DashboardViewWidget extends State<DashboardViewWidget> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin{
 @override
 bool get wantKeepAlive => true;



  late IconButton nextButton,prevButton;
  PageController graphController = PageController(initialPage: 0);
late RecordsBloc recordsBloc;
  ZoomPanBehavior zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true, enablePanning: true, zoomMode: ZoomMode.x);
  ZoomPanBehavior zoomPanBehavior2 = ZoomPanBehavior(
      enableDoubleTapZooming: true, enablePanning: true, zoomMode: ZoomMode.x);
  ZoomPanBehavior zoomPanBehavior1 = ZoomPanBehavior(
      enableDoubleTapZooming: true, enablePanning: true, zoomMode: ZoomMode.x);
  double? currentPage=0;
  int pageCount = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
recordsBloc=Provider.of<RecordsBloc>(context, listen: false);
/// Page controller for Ratings Graph
    graphController.addListener(() {
     if(mounted){
       setState(() {
         currentPage = graphController.page;
       });
     }

    });
   ///Button Initialization
    nextButton = IconButton(
      tooltip: "Next",
      onPressed: () {
        graphController
            .nextPage(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInExpo)
            .whenComplete(() => setState(() {
          currentPage = graphController.page!;
        })
        );
      },
      icon: nextArrowIcon,
    );
    prevButton = IconButton(
      tooltip: "Previous",
      onPressed: () {
        graphController
            .previousPage(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInExpo)
            .whenComplete(() => setState(() {
          currentPage = graphController.page!;
        })
        );
      },
      icon: backArrowIcon,
    );
  }

 //Async Methods to better control flow of execution

  Future <List<RecordDataStats>> getSymptomList() async{
    final recordsBloc = Provider.of<RecordsBloc>(context, listen: false);

    List<RecordDataStats> symptomList= [];
    symptomList.addAll(recordsBloc.symptomList);
    return symptomList;
  }

  Future <List<List<RecordRatingStats>>> getPagedRatings() async{
    final recordsBloc = Provider.of<RecordsBloc>(context, listen: false);

var tempRatings = recordsBloc.ratingsList.reversed.slices(30).toList();
return tempRatings;


  }
 /// Summary Card Data
  String summaryGen() {
    final recordsBloc = Provider.of<RecordsBloc>(context, listen: false);

    String summaryString = '';
    String successString = '';
    double avgRating = 0.0;

    if(recordsBloc.ratingsList.isNotEmpty) {
      // For the ratings
      List<double> sum = recordsBloc.ratingsList.map((e) => e.value).toList();
      double totalRtg = 0.0;
      for (double rating in sum) {
        totalRtg += rating;
      }
      avgRating =
      (totalRtg / recordsBloc.currentRecordHolder.length.toDouble());
      // For the success/fail section
      if (recordsBloc.successList[0].value > recordsBloc.successList[1].value) {
        successString = "success";
      } else {
        successString = "fail";
      }
    } else{
      summaryString = "No journal entries found, go ahead and add one";
    }
    //For the symptom and emotion section


    summaryString =
        "You have ${recordsBloc.currentRecordHolder.length} entries in your journal.\r\n"
        "Your average rating is ${avgRating.roundToDouble()}.\r\n"
        "You're trending more  on $successString based on your Success/Fail ratings.\r\n"
        "Your most recently occurring symptoms are: ${recordsBloc.currentRecordHolder.last.symptoms}.";

    return summaryString;
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    final recordsBloc = Provider.of<RecordsBloc>(context, listen: false);
    return Consumer<ThemeSwap>(builder: (context, swapper, child) {
    return  CustomScrollView(slivers: [
        SliverList(delegate: SliverChildListDelegate([
          const Center(child: Text("Summary of statistics",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),)
        ])),
      SliverSafeArea(
          top: true,left: true,right: true,bottom: true,minimum: const EdgeInsets.all(10),
          sliver:
      SliverList(delegate: SliverChildListDelegate([

      ///Summary Card
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

        //Ratings Card
       FutureBuilder<List<List<RecordRatingStats>>>(
          future: getPagedRatings(),
          builder: (context, snapshot) {
            // If the data is still loading, show a loading indicator
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return uiCard(const SizedBox(height: 100,
                  child: Center(child: CircularProgressIndicator())), swapper);
            }
            // If there is an error, show an error message
            if (snapshot.hasError) {
              return uiCard(SizedBox(height: 400,
                  child: Center(child: Text("Error: ${snapshot.error}"))),
                  swapper);
            }
            final pagedData = snapshot.data;
            // If the data is empty, show a message
            if (pagedData == null || pagedData.isEmpty) {
              return uiCard(const SizedBox(height: 400,
                  child: Center(child: Text("No ratings data available."))),
                  swapper);
            }
            // If the data is available, show the chart
            int pageCount = pagedData.length;
            return uiCard(
                SizedBox(height: 400, width: double.infinity,
                    child:
                    Stack(
                      children: [
                        // Previous Page button
                        if(currentPage! > 0.0)
                          Align(

                              alignment: Alignment.centerLeft,
                              child:
                              InkWell(onTap: () {
                                if (kDebugMode) {
                                  print("Back Gesture Tapped");
                                }
                                setState(() {
                                  graphController
                                      .previousPage(
                                      duration: const Duration(
                                          milliseconds: 150),
                                      curve: Curves.easeInExpo)
                                      .whenComplete(() =>
                                      setState(() {
                                        currentPage = graphController.page!;
                                      }));
                                });
                              }, child:
                              //Icon(backArrowIcon,color: Color(swapper.isColorSeed),)
                              Container(
                                alignment: Alignment.center,
                                width: 40, height: double.infinity,
//padding: const EdgeInsets.fromLTRB(8.0,double.infinity,8.0,double.infinity),
                                child: backArrowIcon,
//prevButton,

                              )


                              )),
                        //Graph
                        Padding(
                            padding: const EdgeInsets.fromLTRB(25, 8, 25, 20),
                            child: // Ratings Graph
                            PageView.builder(controller: graphController,
                                itemCount: pageCount,
                                itemBuilder: (BuildContext context, index) {
                                  super.build(context);

                                  return Column(
                                      children: [
                                        SfCartesianChart(
                                          zoomPanBehavior: zoomPanBehavior,
                                          borderWidth: 8.0,
                                          primaryXAxis: CategoryAxis(
                                              name: "Dates",
                                              labelAlignment: LabelAlignment
                                                  .start,
                                              labelRotation: 285,
                                              labelPosition: ChartDataLabelPosition
                                                  .outside,
                                              title: AxisTitle(text: "Dates")),
                                          primaryYAxis: NumericAxis(
                                              name: "Ratings",
                                              labelAlignment: LabelAlignment
                                                  .center,
                                              title: AxisTitle(text: "Ratings"),
                                              rangePadding: ChartRangePadding
                                                  .auto),

                                          series: <LineSeries<
                                              RecordRatingStats,
                                              String>>[
                                            LineSeries(
                                              dataSource: pagedData[index],
                                              width: 1.0,

                                              xValueMapper: (
                                                  RecordRatingStats recLbl,
                                                  _) =>
                                                  DateFormat("MM/dd/yyyy")
                                                      .format(recLbl.date),
                                              color: Color(swapper.isColorSeed),
                                              yValueMapper: (
                                                  RecordRatingStats recLbl,
                                                  _) =>
                                              recLbl.value,
                                              markerSettings: MarkerSettings(
                                                  isVisible: true,
                                                  height: 3,
                                                  width: 3
                                              ),
                                              dataLabelSettings:
                                              const DataLabelSettings(
                                                isVisible: true,
                                                showZeroValue: true,
                                                showCumulativeValues: true,
                                              ),
                                              xAxisName: 'Dates',
                                              yAxisName: 'Ratings',
                                            ),
                                          ],
                                          title: ChartTitle(
                                              text: 'Journal entry ratings'),
                                          margin: const EdgeInsets.all(8.0),
                                        )
                                      ]

                                  );
                                }
                            )),
                        //Next Page Button
                        if (currentPage! < pageCount - 1)
                          Align(alignment: Alignment.centerRight,
                              child: InkWell(onTap: () {
                                if (kDebugMode) {
                                  print("Next Gesture Tapped");
                                }
                                setState(() {
                                  graphController
                                      .nextPage(
                                      duration: const Duration(
                                          milliseconds: 100),
                                      curve: Curves.easeInExpo)
                                      .whenComplete(() =>
                                      setState(() {
                                        currentPage = graphController.page!;
                                      }));
                                });
                              },
                                  // Allows for the touch zone to reach the end of the widget
                                  child:
                                  Container(height: double.infinity, width: 40,
                                    child: Align(child: nextArrowIcon,
                                      alignment: Alignment.center,),
                                  ))),
                        // Page indicator
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: AnimatedSmoothIndicator( //SmoothPageIndicator(
                                  activeIndex: currentPage?.round() ?? 0,
                                  count: pageCount,
                                  effect: SlideEffect(
                                    dotHeight: 8,
                                    dotWidth: 8,
                                    activeDotColor: Color(swapper.isColorSeed),
                                    dotColor: Colors.grey.shade400,
                                  ),
                                  onDotClicked: (value) {
                                    graphController.animateToPage(value,
                                        duration: const Duration(
                                            milliseconds: 100),
                                        curve: Curves.linear);
                                  },)))
                      ],
                    )
                ), swapper);
          }
        ),
        // Success/Fail Card
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
                    dataSource: recordsBloc.successList,
                    xValueMapper: (RecordDataStats recs, _) => recs.key,
                    yValueMapper: (RecordDataStats recs, _) => recs.value,
                    dataLabelMapper: (RecordDataStats recs, _) =>
                    "${recs.key}: ${((recs.value / recordsBloc.currentRecordHolder.length.toDouble()) * 100.0).toStringAsFixed(2)} % ",
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                    ),
                  ),
                ],
              ),
            ),
            )),
        // Emotion Card
        Card(borderOnForeground: true,
          elevation: 2.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Color(swapper.isColorSeed).withOpacity(1.0))),
          margin: const EdgeInsets.all(5),
          child: GridTile(child: Column(children: [
            SizedBox(
              height: 650,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SfCartesianChart(
                  zoomPanBehavior: zoomPanBehavior1,
                  trackballBehavior: TrackballBehavior(
                      activationMode: ActivationMode.doubleTap),
                  borderWidth: 2.0,
                  primaryXAxis: CategoryAxis(name: "Emotions",labelAlignment: LabelAlignment.center,
                    labelPosition: ChartDataLabelPosition.outside,title: AxisTitle(text: "Emotions"),),
                  primaryYAxis: NumericAxis(name: "Counts",
                      labelAlignment: LabelAlignment.center,title: AxisTitle(text: "Quantity"),rangePadding: ChartRangePadding.auto
                  ),
                  series: <BarSeries<RecordDataStats, String>>[
                    BarSeries(
                      dataSource: recordsBloc.emotionsList,
                      xValueMapper: (RecordDataStats rec, _) =>
                      rec.key,
                      yValueMapper: (RecordDataStats rec, _) =>
                      rec.value,
                      name: 'Emotion Data from Journal Entries',
                      color: Color(swapper.isColorSeed),
                      xAxisName: 'Emotions',
                      spacing: 0.015,
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
      // Symptom Card
        uiCard(
      GridTile(child:
      Column(
      children: [
      SizedBox(
      height: 950,
      child: Padding(
      padding: const EdgeInsets.all(8.0),
      child:
      SfCartesianChart(
          trackballBehavior: TrackballBehavior(
              activationMode: ActivationMode.longPress),
          zoomPanBehavior: zoomPanBehavior2,
          borderWidth: 2.0,
          primaryXAxis: CategoryAxis(name: "Symptoms",labelAlignment: LabelAlignment.center,
            title: AxisTitle(text: "Symptoms"),
            labelPosition: ChartDataLabelPosition.outside,),
          primaryYAxis: NumericAxis(name: "Counts",
              labelAlignment: LabelAlignment.center,title: AxisTitle(text: "Quantity"),rangePadding: ChartRangePadding.auto
          ),
          series: <BarSeries<RecordDataStats, String>>[
            BarSeries(
                dataSource: recordsBloc.symptomList,//snapshot.data,
                xValueMapper: (RecordDataStats rec, _) =>
                rec.key,
                yValueMapper: (RecordDataStats rec, _) =>
                rec.value,
                name: 'Symptom Data from Journal Entries',
                color: Color(swapper.isColorSeed),
                xAxisName: 'Symptoms',
                yAxisName: 'Counts',
                spacing: .25,
                dataLabelSettings:
                const DataLabelSettings(isVisible: true)),
          ],
          title: ChartTitle(
              text: 'Symptom Data from Journal Entries'),
        )
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
        ) ,),swapper)
      ]),),

      )
      ],);

    });
  }
}
