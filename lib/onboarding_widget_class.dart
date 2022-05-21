import 'package:adhd_journal_flutter/login_screen_file.dart';
import 'package:adhd_journal_flutter/project_colors.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'splash_screendart.dart';
import 'project_strings_file.dart';

class OnBoardingWidget extends StatefulWidget {
  const OnBoardingWidget({Key? key}) : super(key: key);
  @override
  State<OnBoardingWidget> createState() => _OnBoardingWidgetState();
}
// Variables to store inside the DB
String savedPasswordValue = '';
String greetingValueSaved = '';
bool callingCard = false;

class _OnBoardingWidgetState extends State<OnBoardingWidget> {
  bool isSaved = false;

  var pageTitleStyle = const TextStyle(
    fontSize: 23.0,
    wordSpacing: 1,
    letterSpacing: 1.2,
    fontWeight: FontWeight.bold,
    //color: Colors.black,
  );
  var pageInfoStyle = const TextStyle(
  //  color: Colors.black,
    letterSpacing: 0.7,
    height: 1.5,
  );

  late Material materialButton;
  late int index;
 // Color background = Colors.white;

  @override
  void initState() {
    super.initState();
    encryptedSharedPrefs = EncryptedSharedPreferences();
    index = 0;
  }

// Onboarding pages location
  Material _skipButton({void Function(int)? setIndex}) {
    return Material(
      borderRadius: defaultSkipButtonBorderRadius,
      color: AppColors.mainAppColor,
      child: InkWell(
        borderRadius: defaultSkipButtonBorderRadius,
        onTap: () {
          if (setIndex != null) {
            index = 6;
            setIndex(6);
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
  Widget build(BuildContext context) {
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
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            home_page_intro_paragraph_string,
                            style: pageInfoStyle,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      )
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
                  )
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
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            records_intro_paragraph_string,
                            style: pageInfoStyle,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      )
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
                    ),),
                ],
    ),),),
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
                         labelText: 'Enter your name here',
                          hintText: 'Enter your name here'),
                      onChanged: (text) {
                        greetingValueSaved = text;
                      },
                    ),
                  ),
                  Padding(padding: const EdgeInsets.all(15.0),
                  child:CheckboxListTile(title: const Text("Password enabled?"),
    activeColor: AppColors.mainAppColor,
    value: isSaved,
    onChanged: (bool? changed) {
    setState(() {
    isSaved = changed!;

    });}),),
                  ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColors.mainAppColor),),
                    onPressed: () async {
                      if (savedPasswordValue != '') {
                        await encryptedSharedPrefs.setString(
                            'loginPassword', savedPasswordValue);
                        await encryptedSharedPrefs.setString(
                            'dbPassword', savedPasswordValue);
                        prefs.setBool('passwordEnabled', isSaved);
                        prefs.setString('greeting', greetingValueSaved);
                        prefs.setBool('firstVisit', false);
                        dbPassword = savedPasswordValue;
                        userPassword = savedPasswordValue;
callingCard = false;
                        Navigator.pushReplacementNamed(context, '/success');
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
                          print(s);
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
                padding: const EdgeInsets.all(45.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomIndicator(
                      netDragPercent: dragDistance,
                      pagesLength: pagesLength,
                      indicator: Indicator(
                        activeIndicator: ActiveIndicator(color: AppColors.mainAppColor),
                        closedIndicator: const ClosedIndicator(color: Colors.white),
                        indicatorDesign: IndicatorDesign.line(
                          lineDesign: LineDesign(
                            lineType: DesignType.line_uniform,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


