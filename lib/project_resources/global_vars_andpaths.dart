import 'dart:io';
import 'package:adhd_journal_flutter/adhd_machine_learning/adhd_feature_service.dart';
import 'package:adhd_journal_flutter/adhd_machine_learning/personalization_data.dart';
import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlCipher;

import '../adhd_machine_learning/personalization_service.dart';
import '../app_start_package/login_screen_file.dart';
import '../backup_providers/google_drive_backup_class.dart';
import '../backup_utils_package/preference_backup_class.dart';
import 'network_connectivity_checker.dart';


class Global{

//Symptom Lists
  static final positiveSymptomList = [
    'No Symptoms',
    'A small/big win today',
    'Major win today',
    'Positive Environment/Grace',
    'Momentum driven',
    'Emotional Resiliency',
    'Flow',
    'Hyperfocus',
  ];
  static final emotionalSymptomList = [
    'Emotion fueled response',
    'Emotional Flooding',
    'Rejection Sensitivity Dysphoria',
    'Emotional Meltdown',
  ];
  static List<String> emotionalRegDefinitionList = [
    "This is when your passion and emotions pair up and drive your response, sometimes your brain will not keep these in check when you make a response to something going on",
    "Your brain's emotion regulator inhibitors are overwhelmed with a surge of flooding, it can be any emotion. This is like when you have moments of intense joy or anger. Your brain is likely not going to be in a 'rational' state. Be careful ",
    "You are likely feeling the pain of a potential or actual rejection and it's driving a fear based response or something related",
    "Your emotional state is in a red zone, you may want to take a moment to step away and cool down. Don't see this as something negative, your loved ones still love you ",
  ];
  static final inattentiveSymptomsList = [
    'Distractions',
    'Bored',
    'Procrastination',
    'Sensory Overload',
    'Overwhelmed',
    'Struggling to focus',
    'Unable to focus',
    'Lacking Motivation',
    'Brain Fog',
    'ADHD Burnout',
    'Freeze/Mental Paralysis',
  ];
  static final executiveDysfunctionSymptomList = [
    'Impulsiveness',
    'Impatience',
    'Executive Dysfunction',
    'Hyperactivity',
    'Mental Sluggishness/Dopamine Hunt',
    'Having a bad day',
    'Working Memory Issues',
  ];
  static final executiveSymptomDefinitionList = [
    'This is described as an action often made out of impulse or out-of-nowhere',
    "This is often when you get really restless over waiting for something",
    "This is when you don't feel like doing something, but you know you should, I think?",
    "This is for feeling really hyperactive whether it be mental, physical, or both",
    "I NEED DOPAMINE, MY BRAIN IS HUNGRY",
    "This is when your day is going wrong in all of the ways and nothing seems to go right",
    "When your brain is forgetting important stuff in the short term",
  ];
  static List<String> inattentiveSymptomDefinitionList = [
    'Easily Distracted - Least Severe',
    ' this stuff doesn\'t intrest you',
    'Keep putting important things off, or don\'t feel like it today',
    'Your senses are overwhelmed and you are having trouble with focusing',
    'You\'re dealing with more than what you can carry',
    'Focusing is a bit challenging today, it\'s okay  ',
    'Your mind may be hyperfocusing on something else or your mind won\'t focus on what is at hand due to stress or something',
    'This stuff isn\'t helping with a dopamine shortage, or you may be wanting to not do this today',
    'Your mind is foggy and it isn\'t helpful to try and push your way through whatever the task is, you may want to take a break for a little',
    'You\'re likely wiped out from putting in your best efforts and are exhausted from this task, resting will help you tremendously',
    'This is probably the most severe of the bunch. You\'re likely not wanting to do anything because you have a writer\'s block like mindset or you don\'t know what to say or do, '
        'don\'t lose heart, it\'s probably going to be okay'
  ];
  static List<String> stressDefinitionList = [
    "This is driven by stress going on in your life. Think of this like your symptoms are magnified by an event.",
    "Your mind is probably wondering why you exist or there's too much going on around you to take in the moment. This may also apply to a situation where the world is crashing around you",
    "Your mind is panicking about something going on around you or internally, This is here because it can be classified as a symptom of ADHD. But it does take place in everyone'es lives.",
    "This is when life just seems meaningless and you don't want to exist. This is a catch all for depression symptoms."
  ];
  static final stressorSymptomList = [
    'Stress enhanced ADHD Response',
    'Existential crisis',
    'Anxiety',
    'Depression',
  ];
static bool dbDownloaded = false;
  // Network Connectivity Variable, will not be managed here.
  static NetworkConnectivity networkConnectivityChecker = NetworkConnectivity.instance;

  // Google Drive folder directory
  static String driveStoreDirectory = "Journals";
  ///Application strings
  static const String reset_RSA_Key_Dialog_Message_String =
      "Do you want to reset your encryption keys for your preferences? "
      "Doing so will replace them in the cloud if you have backup and sync turned on."
      "When you load this app on another device connected to your Google Drive account, the keys and the encrypted data file associated with your data will download with it replacing the old set."
      "Do this often to keep things secure. ";
  static const String connection_Error_Message_String =
      "You need to be connected to a Wifi or Mobile network to use backup and sync.";
  static const String downloading_journal_files_message_string =
      "Downloading updated journal files";
  static const String password_Required_Message_String =
      "Please enter a password below to continue.";

  static const String first_intro_paragraph_string =
      'Welcome to the ADHD Journal! This journal serves you like a personal diary would. It intends to help people with ADHD track their symptoms better, track emotional state,'
      'and more. This app hopefully will make ADHD treatment better as more people use it.';
 static const String records_intro_paragraph_string =
      'You can record entries by hitting the record button on the bottom right corner of the app. You can enter a title, put details about the event in,'
      'how you\'re feeling, relevant ADHD symptoms, any thoughts about the event or  entry you might have, a rating from 0 (bad) to 100 (great), and give it a success or fail rating.';
 static const String security_paragraph_intro_string =
      'This journal is your private journal. This means it is going to be encrypted so that hackers and unsuspecting people can\'t just log into this app and see your private thoughts.'
      'You will need to enter a password to encrypt the journal, even though you may not feel like putting it in to log in every time. The journal is stored inside an encrypted database.'
      'The journal is stored inside an encrypted database locally and the password is stored inside an encrypted file so hackers can\'t steal your info  ';
 static  const String settings_paragraph_intro_string =
      'From the settings page, you can change your password, greeting, app\'s theme color, and give feedback and email the developer about any bugs or app ideas for future updates.';
 static const String dashboard_paragraph_intro_string =
      'The dashboard gives you an overview of statistics information about your ratings, success/fail rate, emotional info, symptom data, and a summary of the data.';
static  const String sixth_paragraph_intro_string =
      'You\'ve made it to the end of the tutorial. A couple of things left to do, first I\'ll need you to enter  your name, a password, and a password hint so I can greet you when you enter the app.'
      ' After that, hit save and you\'ll be ready to go!'
      ' Let\'s make mental health better for everyone!';
static  const String home_page_intro_paragraph_string =
      'Once you log in, you\'ll see your journal entries, the navigation bar at the bottom, the compose button in the lower right hand corner, and several buttons on top. '
      "\r\n Here's a quick rundown of the buttons: The search button is in the middle with a clear all button for resetting the list after a search is completed, the sort button is the second from the right, and the settings is button on the upper right hand corner of the screen."
      "\r\n This is where you will probably spend most of the time in the app if you're not composing an entry or viewing the dashboard. ";
static  const String resource_link_title =
      'Click here to quickly access resources about ADHD and to learn more about how to cope with it\'s many symptoms';
static  const String password_hint_needed =
      'The app now features the ability to add a password hint so you can remember your password easier. '
      'Enter a password hint below and hit save to continue.'
      '';
static  const String first_time_user_intro_string =
      "This is your first time using this application. "
      "\r\nLet's get you started!";
static  const String backup_and_sync_intro_paragraph_string =
      'You can backup and sync your journal across multiple devices. At this time, only Google Drive integration is supported. Other services will be added later. To activate, hit Sign into Google Drive. You can turn this off in settings by toggling the backup and sync switch.';
static  const String backup_and_sync_2nd_paragraph_string =
      'When you update one journal, any updates you make will be uploaded on loading, exiting settings, and exiting to the login screen. Make sure to close the app to the login screen if you want to upload it right away. '
      'When you open the app and the app detects any updated files online, the app will automatically download the files onto your device when loading. The app will update the values in the application if you changed your app\'s password or any other values. See the help page for more info.';

static late SharedPreferences prefs;
static EncryptedSharedPreferences encryptedSharedPrefs = EncryptedSharedPreferences(); // Keep as is
 //manage Google Drive instance here. save the numerous calls.
  static GoogleDrive googleDrive = GoogleDrive();
static bool userActiveBackup = false;
  // Manage preference sync and upload.
  static PreferenceBackupAndEncrypt preferenceBackupAndEncrypt =
  PreferenceBackupAndEncrypt();
  //manage login button
  static LoginButtonReady readyButton = LoginButtonReady();




static  const String link_how_to_ADHD_YT = 'https://www.youtube.com/c/HowtoADHD';
static  const String link_chadd_website = 'https://www.chadd.org';
static  const String link_additudemag_website = 'https://www.additudemag.com/';
 static final files_list_types=['Journal','Keys','Preferences'];
 static  final files_list_names=[databaseName,privateKeyFileName,prefsName];
  // Emotion clusters for sorting
  static final anger_emotion_cluster = [
    'angry',
    'anger',
    'furious',
    'angered',
    'mad',
    'rage',
    'enraged',
    'hatred',
    'triggered',
    'annoyed',
    'spiteful',
    'hostile',
    'resentful',
    'frustrated',
    'obstinate',
    'pissed off',
    'peeved',
    'rebellious',
    'vengeful',
    'upset'
  ];
  static final joy_emotion_cluster = [
    'some joy',
    'joy',
    'joyful',
    'happy',
    'lively',
    'exuberant',
    'happier',
    'happiest',
    'ecstatic',
    'pumped',
    'excited',
    'excitement',
    'glee',
    'gleeful',
    'delighted',
  ];
  static final sorrow_emotion_cluster = [
    'grief',
    'depressed',
    'depression',
    'sad',
    'sadness',
    'sorrowful',
    'despair',
    'upset',
    'discouraged',
    'crappy',
    'near tears',
    'tearful',
    'broken',
    'suicidal',
    'heartache',
    'heartbroken',
    'heartbreak',
    'achy',
    'dumb',
    'horrible',
    'shame',
    'despair',
    'dread',
    'dreadful',
    'sorrow',
    'mourning',
    'disappointed',
    'death',
    'torn',
    'devastated',
    'hurt',
  ];
  static final stress_based_emotion_cluster = [
    'stressed',
    'nervous',
    'uneasy',
    'puzzled',
    'conflicted',
    'confused',
    'crazy',
    'overwhelmed',
  ];
  static final mindful_state_emotion_cluster = [
    'humble',
    'humbled',
    'informed',
    'inner peace',
  ];
  static final conviction_based_emotion_cluster = [
    'convicted',
    'repentant',
    'serious',
    'sobered',
  ];
  static final body_pain_emotion_cluster = ['sore', 'pain', 'sick', 'achy'];
  static final fear_emotion_cluster = [
    'terrified',
    'anxious',
    'anxiety',
    'rejected',
    'uneasy',
    'skeptical',
    'nervous',
    'stressed',
    'panicky',
    'panic',
    'fear',
    'fearful',
    'untrusting',
    'deceived',
    'distress',
    'distressed',
    'scared',
    'hopeless',
    'helpless',
    'fidgety',
    'worried',
    'flaky',
    'insane',
    'unsure',
    'trapped',
    'frightened',
    'mistrust',
    'shocked',
    'surprised',
    'uncertain',
    'flakey'
  ];
  static final apathetic_emotion_cluster = [
    'reckless',
    'impulsive',
    'apathetic',
    'apathy',
    'struggling',
    'lethargic',
    'lazy',
    'self-destructive',
    'meh',
    'bored'
  ];
  static final peaceful_emotion_cluster = [
    'content',
    'peace',
    'inner peace',
    'peaceful',
    'calm',
    'thankful',
    'blessed',
    'relaxed',
    'relief',
    'slightest bit of relief',
    'pleased',
    'mellow',
    'adequate',
    'calmer',
    ''
  ];
  static final confidence_emotion_cluster = [
    'confident',
    'bold',
    'boldness',
    'challenged',
    'inspired',
    'respected',
    'respectful',
    'energetic',
    'focused',
    'accomplished',
    'victorious',
    'passion',
    'determination',
    'awake',
    'determined',
    'hope',
    'eager',
    'curious',
    'motivated',
    'good',
    'functional',
    'successful',
    'hopeful',
    'relieved',
    'in the groove',
    'groovy',
    'catching fire',
    'fired up',
    'brave',
    'courage',
    'courageous',
    'hyperfocused',
  ];
  static final shame_emotion_cluster = [
    'ashamed',
    'humiliated',
    'foolish',
    'guilty',
    'guilt',
    'humble',
    'idiotic',
    'embarrassed',
    'regretful',
    'shameful',
    'remorseful',
    'worthless',
    'remorse',
    'regret'
  ];
  static final hurt_emotion_cluster = [
    'abandoned',
    'abused',
    'attacked',
    'belittled' 'bitter',
    'bitterness',
    'cheated',
    'disappointed',
    'dismayed',
    'grieving',
    'gypped',
    'humiliated',
    'mournful',
    'sorrowful',
    'rejected',
    'resentful',
  ];
  static final confused_emotion_cluster = [
    'baffled',
    'befuddled',
    'bewildered',
    'confused',
    'puzzled',
    'flustered',
    'disoriented',
    'scattered',
    'troubled',
    'unfocused',
  ];
  static final love_emotion_cluster = [
    'loved',
    'love',
    'warm',
    'caring',
    'devoted',
    'affectionate',
    'aroused',
  ];
  static final surprised_emotion_cluster = [
    'amazed',
    'aghast',
    'astonished',
    'incredulous',
    'startled',
    'shocked',
  ];
  static final wanting_emotion_cluster = [
    'empty',
    'envious',
    'homesick',
    'jealous',
    'ignored',
    'hungry',
    'lonely',
  ];
  static final body_exhaustion_cluster = ['tired', 'sleepy', 'exhausted'];
  static final weak_emotional_cluster = [
    'weak',
    'inadequate',
    'controlled',
    'burdened',
    'lost',
    'powerless',
    'restricted',
    'discouraged',
    'hopeless',
    'inhibited',
    'helpless',
    'despair',
    'despairing',
    'broken'
  ];

  //Application DB Handling and Other prefs handling internal variables.
static String appDocumentsDirectoryPath = '';
static String dbLocation = "";
static String docsLocation = "";
static String keyLocation="";
static String dbPath="";
// File names
  static const String prefsName = 'journalStuff.txt';
  static  const String databaseName = "activitylogger_db.db";
  static  const String privateKeyFileName = "journ_privkey.pem";
  static const String pubKeyFileName = "journ_pubKey.pem";
  static const String dbWal = "activitylogger_db.db-wal";
static const String PLATFORMCHANNEL_PATH = "com.activitylogger.release1/ADHDJournal";
//File paths
  static String get fullDeviceDocsPath => docsLocation;
  static String get DBPathNOFile=> dbPath;
  static String get fullDevicePubKeyPath => '$docsLocation/$pubKeyFileName';
  static String get fullDevicePrivKeyPath => '$docsLocation/$privateKeyFileName';
  static String get fullDeviceDBPath => dbLocation;
  static String get fullDevicePrefsPath => '$docsLocation/$prefsName';
//Credential management and Preference settings
  static String userPassword='';
  static String dbPassword='';
  static String userPasswordHint='';
   static String userGreeting='Hello';
   static bool passwordRequired=false;
   static bool isInitialized = false;
   static int colorSeed=AppColors.mainAppColor.value;
static late final AdhdMlService adhdMlService;
  static late final PersonalizationService personalizationService;
   // Handles paths so the app can simply load the files
   static Future<bool> initializeAppPaths() async{
     try{
       final directory = await getApplicationDocumentsDirectory();
       await PersonalizationDbHelper.instance.database;
       print ("Database is ready");
       personalizationService = PersonalizationService();
print("ML Service is ready");
       if(directory==null){
         throw Exception('Directory is null');
       } else {
         // Variable below can be used to target journal, but we're keeping that on its own code for
         //readability
         appDocumentsDirectoryPath = directory.path;
         docsLocation = directory.path;
         dbLocation = join (await sqlCipher.getDatabasesPath(),databaseName);
dbPath = await sqlCipher.getDatabasesPath();
         if(kDebugMode){
          print("Global variables initialized, anything that needs more than a single class should be started here except for Google Drive");
         }

isInitialized=true;
return true;

       }
     } catch (e,s){
       if (kDebugMode) {
         print("Global:$e");
         print("Global:$s");
       }
return false;
     }



   }



}