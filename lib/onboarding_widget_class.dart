import 'package:onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen_file.dart';
import 'splash_screendart.dart';


class OnBoardingWidget extends StatefulWidget{
  const OnBoardingWidget({Key? key}) : super(key: key);
  @override
  State<OnBoardingWidget>  createState() => _OnBoardingWidgetState();
}
class  _OnBoardingWidgetState extends State<OnBoardingWidget>{



  late int index;


  @override
  void initState() {
    super.initState();

    index = 0;
  }

  Material _skipButton({void Function(int)? setIndex}) {
    return Material(
      borderRadius: defaultSkipButtonBorderRadius,
      color: defaultSkipButtonColor,
      child: InkWell(
        borderRadius: defaultSkipButtonBorderRadius,
        onTap: () {
          if (setIndex != null) {
            index = 2;
            setIndex(2);
          }
        },
        child: const Padding(
          padding: defaultSkipButtonPadding,
          child: Text(
            'Skip',
            style: defaultSkipButtonTextStyle,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(body:Onboarding( pages: <PageModel>[

    PageModel(widget: DecoratedBox(
    decoration: BoxDecoration(
        color: Colors.white,),
          child: Column(children: <Widget>[
            Icon(Icons.lock_open),
            SizedBox(height: 60,),
            Text('Welcome, Please enter a password below and enter a name so I can greet you when you log in.',style: TextStyle(fontSize: 20.0,),
              textAlign: TextAlign.center,),
            SizedBox(height: 30,),
            TextField( decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'New Password for diary',
                hintText: 'Enter a secure Password'),
              onChanged: (text){
              savedPasswordValue = text;
            },
            ),
            SizedBox(height: 30,),
            SizedBox(height: 10,),
              TextField( decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your  name here',
                  hintText: 'Enter your name here'),

              onChanged: (text){
              greetingValueSaved = text;
            },

            ),
            ElevatedButton(onPressed: (){
              prefs.setString('loginPassword', savedPasswordValue);
              prefs.setString('dbPassword', savedPasswordValue);
              prefs.setBool('passwordEnabled', true);
              prefs.setString('greeting', greetingValueSaved);
              prefs.setBool('firstVisit',  false);
              Navigator.pushReplacementNamed(context, '/login');
            }, child: Text('Save'))
          ],
          ),
        ))
    ],
      onPageChange: (int pageIndex){
      index = pageIndex;
      },
      startPageIndex: 0,
      footerBuilder: (context, dragDistance, pagesLength, setIndex) {
    return DecoratedBox(
    decoration: BoxDecoration(
    color: background,
    border: Border.all(
    width: 0.0,
    color: background,
    ),
    ),
    child: ColoredBox(
    color: background,
    child: Padding(
    padding: const EdgeInsets.all(45.0),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    CustomIndicator(
    netDragPercent: dragDistance,
    pagesLength: pagesLength,
    indicator: Indicator(
    indicatorDesign: IndicatorDesign.line(
    lineDesign: LineDesign(
    lineType: DesignType.line_uniform,
    ),
    ),
    ),
    ),
    /*index == pagesLength - 1
    ?
         _skipButton(setIndex: setIndex),*/
    ],
    ),
    ),
    ),);},
    ),);
  }

}
String savedPasswordValue = '';
String greetingValueSaved = '';