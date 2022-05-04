import 'package:onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen_file.dart';
import 'splash_screendart.dart';
import 'project_strings_file.dart';


class OnBoardingWidget extends StatefulWidget{
  const OnBoardingWidget({Key? key}) : super(key: key);
  @override
  State<OnBoardingWidget>  createState() => _OnBoardingWidgetState();
}
class  _OnBoardingWidgetState extends State<OnBoardingWidget>{
  var pageTitleStyle = TextStyle(
    fontSize: 23.0,
    wordSpacing: 1,
    letterSpacing: 1.2,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  var pageInfoStyle = TextStyle(
    color: Colors.black,
    letterSpacing: 0.7,
    height: 1.5,
  );

late Material materialButton;
  late int index;
Color background = Colors.white;

  @override
  void initState() {
    super.initState();

    index = 0;
  }

// Onboarding pages location
  Material _skipButton({void Function(int)? setIndex}) {
    return Material(
      borderRadius: defaultSkipButtonBorderRadius,
      color: defaultSkipButtonColor,
      child: InkWell(
        borderRadius: defaultSkipButtonBorderRadius,
        onTap: () {
          if (setIndex != null) {
            index = 5;
            setIndex(5);
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
    return Scaffold(body: Onboarding( pages: <PageModel>[
      //Introduction page
      PageModel(widget: DecoratedBox(
        decoration: BoxDecoration(
          color: background,border: Border.all(
          width: 0.0,color: background,),),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: [ Padding(padding: const EdgeInsets.symmetric(
              horizontal: 45.0, vertical: 90.0,),
              child: Image.asset('images/appicon-76x76.png',
                  ),
            ),
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welcome to the ADHD Journal!',
                    style: pageTitleStyle,
                    textAlign: TextAlign.left,
                  ),),),Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    first_intro_paragraph_string,
                    style: pageInfoStyle,
                    textAlign: TextAlign.left,
                  ),),),],),),),
      ),
     //Security page
      PageModel(widget: DecoratedBox(
        decoration: BoxDecoration(
          color: background,border: Border.all(
          width: 0.0,color: background,),),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: [ Padding(padding: EdgeInsets.symmetric(
              horizontal: 45.0, vertical: 90.0,),
              child: Icon(Icons.security_sharp,color: Colors.black,size: 60.0,),
            ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 45.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Security',
                    style: pageTitleStyle,
                    textAlign: TextAlign.left,
                  ),),),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 45.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    security_paragraph_intro_string,
                    style: pageInfoStyle,
                    textAlign: TextAlign.left,
                  ),),),

            ],),),)
      ),
      // Record Entry page
      PageModel(widget: DecoratedBox(
        decoration: BoxDecoration(
          color: background,border: Border.all(
          width: 0.0,color: background,),),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children:  [ Padding(padding: EdgeInsets.symmetric(
              horizontal: 45.0, vertical: 90.0,),
              child: Icon(Icons.edit, color: Colors.black,size: 60.0,),
            ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 45.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Create Records',
                    style: pageTitleStyle,
                    textAlign: TextAlign.left,
                  ),),),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
            child: Align(alignment: Alignment.centerLeft,
            child: Text(records_intro_paragraph_string,style: pageInfoStyle,
            textAlign: TextAlign.left,),

            ),)

            ],),),)
      ),
      // Dashboard
      PageModel(widget: DecoratedBox(
        decoration: BoxDecoration(
          color: background,border: Border.all(
          width: 0.0,color: background,),),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children:  [ Padding(padding: EdgeInsets.symmetric(
              horizontal: 45.0, vertical: 90.0,),
              child: Icon(Icons.dashboard,color: Colors.black,size: 60.0,),),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 45.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Dashboard',
                    style: pageTitleStyle,
                    textAlign: TextAlign.left,
                  ),),),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
            child: Align(alignment: Alignment.centerLeft,child: Text(dashboard_paragraph_intro_string,
            style: pageInfoStyle,textAlign: TextAlign.left,),),
            )


            ],),),)
      ),
      // Settings Page
      PageModel(widget: DecoratedBox(
        decoration: BoxDecoration(
          color: background,border: Border.all(
          width: 0.0,color: background,),),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children:  [ Padding(padding: EdgeInsets.symmetric(
              horizontal: 45.0, vertical: 90.0,),
              child: Icon(Icons.settings,color: Colors.black,size: 60.0,),),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 45.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Settings',
                    style: pageTitleStyle,
                    textAlign: TextAlign.left,
                  ),),),
              Padding(padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
              child: Align(alignment: Alignment.centerLeft,child: Text(settings_paragraph_intro_string,
              style: pageInfoStyle,textAlign: TextAlign.left,),),


              )
              ,],),),)),
      //Last page
      PageModel(widget: DecoratedBox(
        decoration: BoxDecoration(
          color: background,border: Border.all(
          width: 0.0,color: background,),),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: [ const Padding(padding: EdgeInsets.symmetric(
              horizontal: 45.0, vertical: 90.0,),
              child: Icon(Icons.settings,color: Colors.black,size: 60.0,),),
               Padding(
                padding: EdgeInsets.symmetric(horizontal: 45.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    sixth_paragraph_intro_string,
                    style: pageTitleStyle,
                    textAlign: TextAlign.left,
                  ),),),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),child:TextField( decoration: const InputDecoration(
                  border: OutlineInputBorder(),hintStyle: TextStyle(color: Colors.black),
                  labelText: 'New Password for diary',labelStyle: TextStyle(color: Colors.black),
                  hintText: 'Enter a secure Password'),
                onChanged: (text){
                  savedPasswordValue = text;
                },
              ),),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),child:
              TextField( decoration: const InputDecoration(
                  border: OutlineInputBorder(),helperStyle: TextStyle(color: Colors.black),
                  labelText: 'Enter your name here',labelStyle: TextStyle(color: Colors.black),
                  hintText: 'Enter your name here'),

                onChanged: (text){
                  greetingValueSaved = text;
                },

              ),),
              ElevatedButton(onPressed: (){
                if(savedPasswordValue !=''){
                  prefs.setString('loginPassword', savedPasswordValue);
                  prefs.setString('dbPassword', savedPasswordValue);
                  prefs.setBool('passwordEnabled', true);
                  prefs.setString('greeting', greetingValueSaved);
                  prefs.setBool('firstVisit',  false);
                  Navigator.pushReplacementNamed(context, '/login');
                }
                else{
                  savedPasswordValue = '1234';
                  prefs.setString('loginPassword', savedPasswordValue);
                  prefs.setString('dbPassword', savedPasswordValue);
                  prefs.setBool('passwordEnabled', true);
                  prefs.setString('greeting', greetingValueSaved);
                  prefs.setBool('firstVisit',  false);
                  Navigator.pushReplacementNamed(context, '/login');
                }
              }, child: Text('Save'),style:  ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),)
            ],),),)),
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
    index == pagesLength - 1
    ? _skipButton(setIndex: setIndex)
        : _skipButton(setIndex: setIndex),
    ],
    ),
    ),
    ),);},
    ),);
  }

}
String savedPasswordValue = '';
String greetingValueSaved = '';