import 'package:adhd_journal_flutter/project_resources/project_utils.dart';
import 'package:adhd_journal_flutter/record_data_package/record_list_class.dart';
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


class NewDashboardStatsWidget extends StatefulWidget{
  const NewDashboardStatsWidget({Key? key}) : super(key: key);
  @override
  State<NewDashboardStatsWidget> createState() => _NewDashboardStatsWidget();
}


///Rebuilding the Dashboard Stats Widget
class _NewDashboardStatsWidget extends State<NewDashboardStatsWidget>{
  late IconButton nextButton,prevButton;
  late var tempList,dateList,ratingList;

  PageController graphController = PageController(initialPage: 0);
double? currentPage=0;
  @override
  void initState() {
    super.initState();
   /// Add a Listener to the page controller variable to allow for page tracking
    graphController.addListener(() {
      setState(() {
        currentPage = graphController.page;
      });
    });
    /// Move forward and backwards between pages
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

    ///Placeholder for temp list or not.
tempList = [];
dateList = [];
ratingList = [];
  }

Future<String> getSummaryGen() async{
    String successSummary = "";
    String overallSummary = "";
    String ratingSummary = "";
    double avgRating = 0.0;
   ///Combined Rating
    double totalRating = 0.0;
    ///Cumulative
    List<double> sum =  RecordList.ratingsList.map((e) => e.value).toList();
    for (double rating in sum) {
      totalRating += rating;
    }
    avgRating = totalRating / sum.length;
    if (RecordList.successList[0].value > RecordList.successList[1].value) {
      successSummary = "success";
    } else {
      successSummary = "fail";
    }

    overallSummary = ""
        "You have ${recordsBloc.recordHolder.length} entries in your journal.\r\n"
        "Your average rating is ${avgRating.roundToDouble()}.\r\n"
        "You're trending more on $successSummary lately. \r\n"
        "Your most recent occurring symptoms are: ${recordsBloc.recordHolder.last.symptoms}.";
    return overallSummary;
}





@override
  Widget build(BuildContext context) {

    return Consumer<ThemeSwap>(builder: (context, theme, child) {
    return SafeArea(minimum: EdgeInsets.all(5),
        child:
       CustomScrollView(

       ));

    });

  }
}