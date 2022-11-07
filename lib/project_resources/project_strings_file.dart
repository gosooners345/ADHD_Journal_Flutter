// ignore_for_file: constant_identifier_names

/// These arrays are sorted by severity and type.
final positiveSymptomList = [
  'No Symptoms',
  'A small/big win today',
  'Major win today',
  'Positive Environment/Grace',
  'Momentum driven',
  'Emotional Resiliency',
  'Flow',
  'Hyperfocus',
];

final emotionalSymptomList = [
  'Emotion fueled response',
  'Emotional Flooding',
  'Rejection Sensitivity Dysphoria',
  'Emotional Meltdown',
];
final inattentiveSymptomsList = [
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
final executiveDysfunctionSymptomList = [
  'Impulsiveness',
  'Impatience',
  'Executive Dysfunction',
  'Hyperactivity',
  'Mental Sluggishness/Dopamine Hunt',
  'Having a bad day',
  'Working Memory Issues',
];
final stressorSymptomList = [
  'Stress enhanced ADHD Response',
  'Existential crisis',
  'Anxiety',
  'Depression',
];
const String reset_RSA_Key_Dialog_Message_String = "Do you want to reset your encryption keys for your preferences? "
    "Doing so will replace them in the cloud if you have backup and sync turned on."
    "When you load this app on another device connected to your Google Drive account, the keys and the encrypted data file associated with your data will download with it replacing the old set."
"Do this often to keep things secure. ";
const String connection_Error_Message_String = "You need to be connected to a Wifi or Mobile network to use backup and sync.";
const String downloading_journal_files_message_string ="Downloading updated journal files";
const String password_Required_Message_String =
    "Please enter a password below to continue.";
const String prefsName = 'journalStuff.txt';
const String databaseName = "activitylogger_db.db";
const String privateKeyFileName = "journ_privkey.pem";
const String pubKeyFileName = "journ_pubKey.pem";
const String dbWal = "activitylogger_db.db-wal";
const String first_intro_paragraph_string =
    'Welcome to the ADHD Journal! This journal serves you like a personal diary would. It intends to help people with ADHD track their symptoms better, track emotional state,'
    'and more. This app hopefully will make ADHD treatment better as more people use it.';
const String records_intro_paragraph_string =
    'You can record entries by hitting the record button on the bottom right corner of the app. You can enter a title, put details about the event in,'
    'how you\'re feeling, relevant ADHD symptoms, any thoughts about the event or  entry you might have, a rating from 0 (bad) to 100 (great), and give it a success or fail rating.';
const String security_paragraph_intro_string =
    'This journal is your private journal. This means it is going to be encrypted so that hackers and unsuspecting people can\'t just log into this app and see your private thoughts.'
    'You will need to enter a password to encrypt the journal, even though you may not feel like putting it in to log in every time. The journal is stored inside an encrypted database.'
    'The journal is stored inside an encrypted database locally and the password is stored inside an encrypted file so hackers can\'t steal your info  ';
const String settings_paragraph_intro_string =
    'From the settings page, you can change your password, greeting, app\'s theme color, and give feedback and email the developer about any bugs or app ideas for future updates.';
const String dashboard_paragraph_intro_string =
    'The dashboard gives you an overview of statistics information about your ratings, success/fail rate, emotional info, symptom data, and a summary of the data.';
const String sixth_paragraph_intro_string =
    'You\'ve made it to the end of the tutorial. A couple of things left to do, first I\'ll need you to enter  your name, a password, and a password hint so I can greet you when you enter the app.'
    ' After that, hit save and you\'ll be ready to go!'
    ' Let\'s make mental health better for everyone!';
const String home_page_intro_paragraph_string =
    'Once you log in, you\'ll see your journal entries, the navigation bar at the bottom, the compose button in the lower right hand corner, and several buttons on top. '
    "\r\n Here\'s a quick rundown of the buttons: The search button is in the middle with a clear all button for resetting the list after a search is completed, the sort button is the second from the right, and the settings is button on the upper right hand corner of the screen."
    "\r\n This is where you will probably spend most of the time in the app if you\'re not composing an entry or viewing the dashboard. ";
const String resource_link_title =
    'Click here to quickly access resources about ADHD and to learn more about how to cope with it\'s many symptoms';
const String password_hint_needed =
    'The app now features the ability to add a password hint so you can remember your password easier. '
    'Enter a password hint below and hit save to continue.'
    '';
const String first_time_user_intro_string = "This is your first time using this application. "
    "\r\nLet's get you started!";
const String backup_and_sync_intro_paragraph_string =
    'You can backup and sync your journal across multiple devices. At this time, only Google Drive integration is supported. Other services will be added later. To activate, hit Sign into Google Drive. You can turn this off in settings by toggling the backup and sync switch.';
const String backup_and_sync_2nd_paragraph_string =
    'When you update one journal, any updates you make will be uploaded on loading, exiting settings, and exiting to the login screen. Make sure to close the app to the login screen if you want to upload it right away. '
    'When you open the app and the app detects any updated files online, the app will automatically download the files onto your device when loading. The app will update the values in the application if you changed your app\'s password or any other values. See the help page for more info.';

const String link_how_to_ADHD_YT = 'https://www.youtube.com/c/HowtoADHD';
const String link_chadd_website = 'https://www.chadd.org';
const String link_additudemag_website = 'https://www.additudemag.com/';

final anger_emotion_cluster = [
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
final joy_emotion_cluster = [
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
final sorrow_emotion_cluster = [
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
final stress_based_emotion_cluster = [
  'stressed',
  'nervous',
  'uneasy',
  'puzzled',
  'conflicted',
  'confused',
  'crazy',
  'overwhelmed',
];
final mindful_state_emotion_cluster = [
  'humble',
  'sobered',
  'humbled',
  'informed',
];
final conviction_based_emotion_cluster = ['convicted', 'repentant', 'serious'];
final body_pain_emotion_cluster = ['sore', 'pain', 'sick', 'achy'];
final fear_emotion_cluster = [
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
final apathetic_emotion_cluster = [
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
final peaceful_emotion_cluster = [
  'content',
  'peace',
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
final confidence_emotion_cluster = [
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
final shame_emotion_cluster = [
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
final hurt_emotion_cluster = [
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
final confused_emotion_cluster = [
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
final love_emotion_cluster = [
  'loved',
  'love',
  'warm',
  'caring',
  'devoted',
  'affectionate',
  'aroused'
];
final surprised_emotion_cluster = [
  'amazed',
  'aghast',
  'astonished',
  'incredulous',
  'startled',
  'shocked',
];
final wanting_emotion_cluster = [
  'empty',
  'envious',
  'homesick',
  'jealous',
  'ignored',
  'hungry',
  'lonely'
];
final body_exhaustion_cluster = ['tired', 'sleepy', 'exhausted'];
final weak_emotional_cluster = [
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
