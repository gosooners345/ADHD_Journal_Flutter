import 'package:adhd_journal_flutter/app_start_package/login_screen_file.dart';
import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_start_package/splash_screendart.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
  final PageController _pageController = PageController();
  double? currentPage =0;
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
    _pageController.addListener(() {currentPage = _pageController.page;});

  }

  void storePrefs() async {
    await encryptedSharedPrefs.setString('passwordHint', passwordHint);
    await encryptedSharedPrefs.setString('loginPassword', savedPasswordValue);
    await encryptedSharedPrefs.setString(
        'passwordHint', passwordHintValueSaved);
    await encryptedSharedPrefs.setString('dbPassword', savedPasswordValue);
    prefs.setBool('passwordEnabled', isSaved);
    prefs.setString('greeting', greetingValueSaved);
    prefs.setBool('firstVisit', false);
  }


  PageView _buildOnboardingCards(ThemeSwap swapper){
    return PageView(controller: _pageController,
    children: [
   //Introduction
      _onboardingCard(SingleChildScrollView(
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
          Padding(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
            ),
          )
        ],
      ),
    ), swapper),
      //Security page

      _onboardingCard( SingleChildScrollView(
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
          Padding(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
            ),
          )
        ],
      ),
    ), swapper),
      //Home Page

      _onboardingCard(SingleChildScrollView(
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
          ),
          Padding(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
            ),
          )
        ],
      ),
    ), swapper),
      // Dashboard

      _onboardingCard( SingleChildScrollView(
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
          Padding(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
            ),
          )
        ],
      ),
    ), swapper),
      // Record Entry page

      _onboardingCard(SingleChildScrollView(
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
          Padding(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
            ),
          )
        ],
      ),
    ), swapper),
      // Settings Page
      _onboardingCard(ListView(
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
        Padding(
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
          ),
        )
      ],
    ), swapper),
      //Backup And Sync Page
      _onboardingCard( SingleChildScrollView(
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
            Padding(
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
              ),
            )
          ],
        ),
      ), swapper),
      //Last page
      _onboardingCard( ListView(
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
                activeColor: Color(swapper.isColorSeed),
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
                await Future.sync(() => storePrefs())
                    .whenComplete(() => {
                  dbPassword = savedPasswordValue,
                  userPassword = savedPasswordValue,
                  Navigator.pushReplacementNamed(
                      context, '/login')
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
      ), swapper),
    ],
    );
  }
  // Useful for Cards
  Widget _onboardingCard(Widget child,ThemeSwap swapper){
   return Card(borderOnForeground: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4),
          side: BorderSide(color:Color(swapper.isColorSeed).withOpacity(1.0))
      ),child: child,);
  }


  @override
  Widget build(BuildContext context) {
    const pageCount= 8;
    return Consumer<ThemeSwap>(
        builder: (context, ThemeSwap themeNotifier, child) {
      return Scaffold(
        body: SafeArea(minimum:const EdgeInsets.fromLTRB(8,8,8,80),child:Stack(children: [
          currentPage! == 0 ? const Text(""):
          Align(alignment: AlignmentDirectional.centerStart,
              child: IconButton(tooltip:"Previous",onPressed: (){_pageController.previousPage(duration: const Duration(milliseconds:200 ), curve:Curves.easeInExpo ).whenComplete(() =>
              {
                setState(() {
                  currentPage = _pageController.page!;
                })
              });
              },
                icon: backArrowIcon,)) ,
         Padding(padding: const EdgeInsets.fromLTRB(35, 8, 35, 10),child:  _buildOnboardingCards(themeNotifier)),
          currentPage! == pageCount-1 ? const Text(""):
          Align(alignment: AlignmentDirectional.centerEnd,
              child: IconButton(tooltip: "Next",onPressed: (){_pageController.nextPage(duration: const Duration(milliseconds:200 ), curve:Curves.easeInExpo ).whenComplete(() => {
                setState(() {
                  currentPage= _pageController.page!;
                })
              });},
                icon: nextArrowIcon,)),
          Align(alignment: Alignment.bottomCenter,
            child:SizedBox(height: 8,
                child:
                SmoothPageIndicator(controller: _pageController,
                  count:pageCount,
                  effect: const WormEffect(dotHeight: 12,dotWidth: 12),onDotClicked: (value){
                    setState(() {
                      currentPage = value.toDouble();
                      _pageController.jumpToPage(value);
                    });
                  },)),
          ),
        ],
        )),

      );
    });
  }
}
