import 'package:adhd_journal_flutter/project_resources/project_utils.dart';
import 'package:adhd_journal_flutter/record_data_package/record_list_class.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../app_start_package/splash_screendart.dart';
import '../main.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:collection/collection.dart';




class DashboardViewWidget extends StatefulWidget {
  const DashboardViewWidget({super.key});
  @override
  State<DashboardViewWidget> createState() => _DashboardViewWidget();
}
class _DashboardViewWidget extends State<DashboardViewWidget> {
  late IconButton nextButton,prevButton;
  PageController graphController = PageController(initialPage: 0);
//Method for collecting counts of Words in a list
  ZoomPanBehavior zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true, enablePanning: true, zoomMode: ZoomMode.x);
  ZoomPanBehavior zoomPanBehavior2 = ZoomPanBehavior(
      enableDoubleTapZooming: true, enablePanning: true, zoomMode: ZoomMode.x);
  ZoomPanBehavior zoomPanBehavior1 = ZoomPanBehavior(
      enableDoubleTapZooming: true, enablePanning: true, zoomMode: ZoomMode.x);
  double? currentPage=0;
 // int capacity = RecordList.ratingsList.length~/5;
  @override
  void initState() {
    super.initState();


    superList.addAll(RecordList.ratingsList.slices(30));
var templist = superList.reversed;
superList = templist.toList();

    graphController.addListener(() {
      setState(() {
        currentPage = graphController.page;
      });
    });
    nextButton = IconButton(
      tooltip: "Next",
      onPressed: () {
        graphController
            .nextPage(
            duration: const Duration(milliseconds: 150),
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
List<double> ratingList=[];
List<String> dateList=[];
var superList =[];
  @override
  Widget build(BuildContext context) {
    int pageCount =superList.length;
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
        // Create paged values, use sets of 100



uiCard(
SizedBox(width: 300,height: 400,child:

    Stack(children: [
      currentPage! == 0
          ? const Text("")
          : Align(
          alignment: AlignmentDirectional.centerStart,
          child: prevButton),
      Padding(
      padding: const EdgeInsets.fromLTRB(25, 8, 25, 15),
      child:
      PageView.builder(controller: graphController,
          itemCount: superList.length,
          itemBuilder: (BuildContext context,index){

return  GridTile(
    child:
    Column(children: [
       SfCartesianChart(
              zoomPanBehavior: zoomPanBehavior,
              borderWidth: 2.0,
              primaryXAxis: CategoryAxis(name: "Dates",labelAlignment: LabelAlignment.center,labelRotation: 285,
                labelPosition: ChartDataLabelPosition.outside,title: AxisTitle(text: "Dates"),),
              primaryYAxis: NumericAxis(name: "Ratings",
                  labelAlignment: LabelAlignment.center,title: AxisTitle(text: "Ratings"),rangePadding: ChartRangePadding.auto),

         series: <LineSeries<RecordRatingStats, String>>[
                LineSeries(
                  dataSource: superList[index],
                  width: 1.0,
                  xValueMapper: (RecordRatingStats recLbl, _) =>
                      DateFormat("MM/dd/yyyy")
                          .format(recLbl.date),
                  color: Color(swapper.isColorSeed),
                  yValueMapper: (RecordRatingStats recLbl, _) =>
                  recLbl.value,
                  dataLabelSettings:
                  const DataLabelSettings(isVisible: true,),
                  xAxisName: 'Dates',

                  yAxisName: 'Ratings',
                ),
              ],
              title: ChartTitle(
                  text: 'Journal entry ratings'),
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
    ]));
          },
      onPageChanged:(page){
        graphController.animateToPage(page,
            duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
      } ,
      )
      ),

      currentPage! == pageCount - 1
          ? const Text("")
          : Align(
          alignment: AlignmentDirectional.centerEnd,
          child: nextButton),

     Padding(padding: EdgeInsets.all(8.0),child:

      Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
            height: 8,
            child: SmoothPageIndicator(
              controller: graphController,
              count: pageCount,
              effect: WormEffect(
                dotHeight: 12,
                dotWidth: 12,
                dotColor: Color(swapper.isColorSeed),
              ),
              onDotClicked: (value) {
                setState(() {
                  currentPage = value.toDouble();
                  graphController.jumpToPage(value);
                });
              },
            )),
      ),),

    ],),


   ),swapper),
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
                  primaryXAxis: CategoryAxis(name: "Emotions",labelAlignment: LabelAlignment.center,
                    labelPosition: ChartDataLabelPosition.outside,title: AxisTitle(text: "Emotions"),),
                  primaryYAxis: NumericAxis(name: "Counts",
                      labelAlignment: LabelAlignment.center,title: AxisTitle(text: "Quantity"),rangePadding: ChartRangePadding.auto
                  ),
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
                padding: const EdgeInsets.all(8.0),
                child: SfCartesianChart(
                  trackballBehavior: TrackballBehavior(
                      activationMode: ActivationMode.doubleTap),
                  zoomPanBehavior: zoomPanBehavior2,
                  borderWidth: 2.0,
                  primaryXAxis: CategoryAxis(name: "Symptoms",labelAlignment: LabelAlignment.center,title: AxisTitle(text: "Symptoms"),
                    labelPosition: ChartDataLabelPosition.outside,),
                  primaryYAxis: NumericAxis(name: "Counts",
                      labelAlignment: LabelAlignment.center,title: AxisTitle(text: "Quantity"),rangePadding: ChartRangePadding.auto
                  ),
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
