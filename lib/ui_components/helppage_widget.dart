import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../project_resources/project_colors.dart';


class HelpPageWidget extends StatefulWidget{
  const HelpPageWidget({
    super.key,
    required this.title,
    required this.helpPageInfo
});
  //Required Variables, more may come in future.
  final List<String> helpPageInfo;
  final String title;


  @override
  State<StatefulWidget> createState() => HelpPageWidgetState();
}
class HelpPageWidgetState extends State<HelpPageWidget> {

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(builder: (context, swapper, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(super.widget.title),
        ),
        body: ListView.separated( itemCount: super.widget.helpPageInfo.length,
          itemBuilder: (BuildContext context, int index)=> ListTile(
            title:Text(super.widget.helpPageInfo[index])
        ),separatorBuilder: (BuildContext context, int index)=>  Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
            ),
        ),
      );
    });
  }
}
