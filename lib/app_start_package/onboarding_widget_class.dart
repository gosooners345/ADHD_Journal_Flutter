import 'package:adhd_journal_flutter/app_start_package/login_screen_file.dart';
import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhd_journal_flutter/project_resources/project_utils.dart';
import '../app_start_package/splash_screendart.dart';

import '../drive_api_backup_general/google_drive_backup_class.dart';
import '../project_resources/project_strings_file.dart';

class OnBoardingWidget extends StatefulWidget {
  const OnBoardingWidget({Key? key}) : super(key: key);
  @override
  State<OnBoardingWidget> createState() => _OnBoardingWidgetState();
}

// Variables to store inside the DB
String savedPasswordValue = '';
String greetingValueSaved = '';
String passwordHintValueSaved = '';
bool callingCard = false;

class _OnBoardingWidgetState extends State<OnBoardingWidget> {
  bool isSaved = false;
  GoogleDrive googleDrive = GoogleDrive();
  late ElevatedButton driveButton;
  var pageTitleStyle = const TextStyle(
    fontSize: 23.0,
    wordSpacing: 1,
    letterSpacing: 1.2,
    fontWeight: FontWeight.bold,
  );
  var pageInfoStyle = const TextStyle(
    letterSpacing: 0.7,
    height: 1.5,
  );

  late Material materialButton;
  late int index;

  @override
  void initState() {
    super.initState();
    encryptedSharedPrefs = EncryptedSharedPreferences();
    index = 0;
    driveButton = ElevatedButton(
        onPressed: () {
          googleDrive.getHttpClient();
        },
        child: Row(
          children: [Icon(Icons.add_to_drive), Text("Sign in to Drive")],
        ));
  }

 void storePrefs() async{
   await encryptedSharedPrefs.setString(
       'passwordHint', passwordHint);
   await encryptedSharedPrefs.setString(
       'loginPassword', savedPasswordValue);
   await encryptedSharedPrefs.setString(
       'passwordHint', passwordHintValueSaved);
   await encryptedSharedPrefs.setString(
       'dbPassword', savedPasswordValue);
   prefs.setBool('passwordEnabled', isSaved);
   prefs.setString('greeting', greetingValueSaved);
   prefs.setBool('firstVisit', false);
 }

 Widget _previousButton({void Function(int)? setIndex}){

    return   IconButton(
        onPressed: (){
          if(setIndex!=null){
            if(index>0){
              int prevIndex = index -1;
              index = prevIndex;
              setIndex(index);
            }
            else{
              index =0;
              setIndex(index);
            }
          }
        },

       icon:onboardingBackIcon


   );

 }
  Widget _nextButton({void Function(int)? setIndex,required int pageLength}){
    return IconButton(
        onPressed: (){
          if(setIndex!=null){
            if(index!= pageLength-1){
              int nextIndex = index +1;
              index = nextIndex;
              setIndex(index);
            }
            else{
            index = pageLength-1;
            setIndex(index);}
          }
        },
            icon:nextArrowIcon
                );
  }
 Widget _skipButton({void Function(int)? setIndex, required int pageLength}){
    return      ElevatedButton(
      onPressed: (){
        if(setIndex!=null){
          index = pageLength-1;
          setIndex(index);
        }
      },child:Text('Skip') ,
   // ),

    );
}
Widget _customIndicator(
  {
  required int pagesLength,
    required double dragDistance,
    required ThemeSwap themeNotifier
}
    ){
    var width =MediaQuery.of(context).size.width;
    var widgetWidth = width*0.040;
   return
     CustomIndicator(
      netDragPercent: dragDistance,
      pagesLength: pagesLength,
      indicator: Indicator(
        activeIndicator: ActiveIndicator(
            color: Color(themeNotifier.isColorSeed)),
        closedIndicator:
        const ClosedIndicator(),
        indicatorDesign: IndicatorDesign.polygon(polygonDesign:
        PolygonDesign(polygon: DesignType.polygon_diamond,
            polygonRadius: 2.0,polygonSpacer: widgetWidth))
      ),
    // ),
     //),
     );
}
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(
        builder: (context, ThemeSwap themeNotifier, child) {
      return Scaffold(
        body: Onboarding(
          pages: <PageModel>[
            //Introduction page
            PageModel(
              widget: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.0,
                  ),
                ),
                child: SingleChildScrollView(
                  controller: ScrollController(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 45.0,
                          vertical: 90.0,
                        ),
                        child: Image.asset(
                          'images/appicon-76x76.png',
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
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 45.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            first_intro_paragraph_string,
                            style: pageInfoStyle,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
Padding(padding: EdgeInsets.zero,child: SizedBox(height:MediaQuery.of(context).size.height ,),)
                    ],
                  ),
                ),
              ),
            ),
            //Security page
            PageModel(
                widget: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.0,
                ),
              ),
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 45.0,
                        vertical: 90.0,
                      ),
                      child: Icon(
                        Icons.security_sharp,
                        // color: Colors.black,
                        size: 60.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 45.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Security',
                          style: pageTitleStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 45.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          security_paragraph_intro_string,
                          style: pageInfoStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.zero,child: SizedBox(height:MediaQuery.of(context).size.height ,),)
                  ],
                ),
              ),
            )),
            //Home Page
            PageModel(
                widget: DecoratedBox(
              decoration: BoxDecoration(
                  border: Border.all(
                width: 0.0,
              )),
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 45.0,
                        vertical: 90.0,
                      ),
                      child: Icon(
                        Icons.home,
                        // color: Colors.black,
                        size: 60.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 45.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Home Page',
                          style: pageTitleStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          home_page_intro_paragraph_string,
                          style: pageInfoStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),Padding(padding: EdgeInsets.zero,child: SizedBox(height:MediaQuery.of(context).size.height ,),)


                  ],
                ),
              ),
            )),
            // Dashboard
            PageModel(
                widget: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.0,
                ),
              ),
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 45.0,
                        vertical: 90.0,
                      ),
                      child: Icon(
                        Icons.dashboard,
                        //  color: Colors.black,
                        size: 60.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 45.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Dashboard',
                          style: pageTitleStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          dashboard_paragraph_intro_string,
                          style: pageInfoStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.zero,child: SizedBox(height:MediaQuery.of(context).size.height ,),)
                  ],
                ),
              ),
            )),
            // Record Entry page
            PageModel(
                widget: DecoratedBox(
              decoration: BoxDecoration(
                  border: Border.all(
                width: 0.0,
              )),
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 45.0,
                        vertical: 90.0,
                      ),
                      child: Icon(
                        Icons.edit,
                        //   color: Colors.black,
                        size: 60.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 45.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Composing Entries',
                          style: pageTitleStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          records_intro_paragraph_string,
                          style: pageInfoStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.zero,child: SizedBox(height:MediaQuery.of(context).size.height ,),)
                  ],
                ),
              ),
            )),
            // Settings Page
            PageModel(
              widget: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.0,
                  ),
                ),
                child: ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 45.0,
                        vertical: 90.0,
                      ),
                      child: Icon(
                        Icons.settings,
                        size: 60.0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 45.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Settings',
                          style: pageTitleStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          settings_paragraph_intro_string,
                          style: pageInfoStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.zero,child: SizedBox(height:MediaQuery.of(context).size.height ,),)
                  ],
                ),
              ),
            ),
            //Backup And Sync Page
            PageModel(
                widget: DecoratedBox(
              decoration: BoxDecoration(
                  border: Border.all(
                width: 0.0,
              )),
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 45.0,
                        vertical: 90.0,
                      ),
                      child: Icon(
                        Icons.sync,
                        // color: Colors.black,
                        size: 60.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 45.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Backup and Sync Functionality',
                          style: pageTitleStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          backup_and_sync_intro_paragraph_string,
                          style: pageInfoStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          backup_and_sync_2nd_paragraph_string,
                          style: pageInfoStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.zero,child: SizedBox(height:MediaQuery.of(context).size.height ,),)
                  ],
                ),
              ),
            )),
            //Last page
            PageModel(
              widget: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.0,
                  ),
                ),
                child: ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 45.0,
                        vertical: 90.0,
                      ),
                      child: Icon(
                        Icons.done,
                        size: 60.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 45.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'One more thing...',
                          style: pageTitleStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          sixth_paragraph_intro_string,
                          style: pageInfoStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 15, bottom: 0),
                      child: TextField(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter your name here',
                            hintText: 'Enter your name here'),
                        onChanged: (text) {
                          greetingValueSaved = text;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 15, bottom: 0),
                      child: TextField(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'New Password for diary',
                            hintText: 'Enter a secure Password'),
                        onChanged: (text) {
                          savedPasswordValue = text;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 15, bottom: 0),
                      child: TextField(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password Hint',
                            hintText:
                                'Enter a hint to help you remember your password easier here'),
                        onChanged: (text) {
                          passwordHint = text;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: CheckboxListTile(
                          title: const Text("Password enabled?"),
                          activeColor: Color(themeNotifier.isColorSeed),
                          value: isSaved,
                          onChanged: (bool? changed) {
                            setState(() {
                              isSaved = changed!;
                            });
                          }),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (savedPasswordValue != '') {
                          await Future.sync(() => storePrefs()).whenComplete(() => {
                          dbPassword = savedPasswordValue,
                              userPassword = savedPasswordValue,
                              Navigator.pushReplacementNamed(context, '/login')
                          });
                        } else {
                          try {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      title: const Text('Password Required!'),
                                      content: const Text(
                                          password_Required_Message_String),
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('OK')),
                                      ],
                                    ));
                          } catch (e, s) {
                            if (kDebugMode) {
                              print(s);
                            }
                          }
                        }
                      },
                      child: const Text('Save'),
                    )
                  ],
                ),
              ),
            )
          ],
          onPageChange: (int pageIndex) {
            index = pageIndex;
          },
          startPageIndex: 0,
          footerBuilder: (context, dragDistance, pagesLength, setIndex) {
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.0,
                ),
              ),
              child: ColoredBox(
                color: background,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 25.0),
                  child:
                  Row(
                      children: [
                         index > 0 ?_previousButton(setIndex: setIndex) :const Text("           "),SizedBox(width:MediaQuery.of(context).size.width*0.0118 ,),
Expanded(flex:0 ,child: Align(alignment:Alignment.center,child: _customIndicator(pagesLength: pagesLength,
                                dragDistance: dragDistance,
                                themeNotifier: themeNotifier)),)
                        ,const SizedBox(width: 3.0,),const Spacer(flex: 4,),
                        index < pagesLength - 1 ? _nextButton(
                            setIndex: setIndex, pageLength: pagesLength) : Text(
                            ''),
                        const SizedBox(width: 3.0,),
                        index == pagesLength - 1 ? const SizedBox(width: 2.0,) : _skipButton(
                            setIndex: setIndex, pageLength: pagesLength),
                      ].withSpaceBetween(width: 2.0)),
                ),
              ),

            );
          },
        ),
      );
    });
  }
}
