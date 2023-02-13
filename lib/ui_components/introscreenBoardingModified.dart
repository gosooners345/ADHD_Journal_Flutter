import 'package:adhd_journal_flutter/app_start_package/splash_screendart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intro_screen_onboarding_flutter/circle_progress_bar.dart';
import 'package:provider/provider.dart';

import '../project_resources/project_colors.dart';
import 'introduction_modified.dart';

/// A IntroScreen Class.
//Modified by Brandon Guerin, credit to daturit on github

class IntroScreenOnboarding extends StatefulWidget {
  final List<Introduction>? introductionList;
  final Color? backgroudColor;
  final Color? foregroundColor;
  final TextStyle? skipTextStyle;

  /// Callback on Skip Button Pressed
  final Function()? onTapSkipButton;
  IntroScreenOnboarding({
    Key? key,
    this.introductionList,
    this.onTapSkipButton,
    this.backgroudColor,
    this.foregroundColor,
    this.skipTextStyle = const TextStyle(fontSize: 20),
  }) : super(key: key);

  @override
  _IntroScreenOnboardingState createState() => _IntroScreenOnboardingState();
}

class _IntroScreenOnboardingState extends State<IntroScreenOnboarding> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  double progressPercent = 0;
String nextString = "Next";
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(builder: (context, swapper, child) {
    return Material(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          color: widget.backgroudColor ?? Theme.of(context).backgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              /*  Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: widget.onTapSkipButton,
                        child: Text('Skip', style: widget.skipTextStyle),
                      ),
                    ),
                  ],
                ),*/
                Expanded(
                  child: Container(
                    height: 550.0,
                    child: PageView(
                      physics: ClampingScrollPhysics(),
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: widget.introductionList!,
                    ),
                  ),
                ),

              //  _customProgress(swapper),


              ],
            ),
          ),
        ),
      ),
    );
  });
  }


  Widget _customProgress(ThemeSwap swapper) {
    return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                child: CircleProgressBar(
                  backgroundColor: Colors.white,
                  foregroundColor:
                  Color(swapper.isColorSeed),
                  value: ((_currentPage + 1) * 1.0 / widget.introductionList!.length),
                ),
              ),
             /* Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Colors.white)
                      .withOpacity(0.5),
                ),*/
               /* child: TextButton(
                  onPressed: () {

                    _currentPage != widget.introductionList!.length - 1
                        ? _pageController.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease,
                    )
                        : {


                      setState((){nextString = "Save";}),
                    };
                  },
                  child:Text(nextString)
                ),*/
              //),
            ],
          );

  }
}