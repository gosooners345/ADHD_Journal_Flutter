import 'package:flutter/material.dart';

// BIG THANKS TO DATURIT FOR PROVIDING THE BASE CODE FOR THIS MOD

class Introduction extends StatefulWidget {

  final Widget childWidget;
  final TextStyle titleTextStyle;
  final TextStyle subTitleTextStyle;

  Introduction({
   required this.childWidget,

    this.titleTextStyle = const TextStyle(fontSize: 30),
    this.subTitleTextStyle = const TextStyle(fontSize: 20),

  });

  @override
  State<StatefulWidget> createState() {
    return new IntroductionState();
  }
}

class IntroductionState extends State<Introduction> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           widget.childWidget
          ],
        ),
      ),
    );
  }
}