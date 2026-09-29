import '../models/assessment_draft.dart';
import '../models/question.dart';

/// DEMO EXAMPLES — entirely fictional scenarios for demonstrations.
/// No real people's personal information is used. Organization names are
/// invented unless the scenario is about impersonating a type of agency.
class DemoExample {
  const DemoExample({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.categoryId,
    required this.text,
    this.answers = const {},
    this.featured = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String categoryId;
  final String text;
  final Map<String, dynamic> answers;

  /// Featured on the judges' demo path (Senior + Youth protection).
  final bool featured;

  AssessmentDraft toDraft() => AssessmentDraft(
        categoryId: categoryId,
        text: text,
        answers: Map<String, dynamic>.from(answers),
        source: InputSource.demo,
        demoTitle: title,
      );
}

const List<DemoExample> kDemoExamples = [
  DemoExample(
    id: 'demo_job',
    title: 'Fake job offer',
    subtitle: 'Remote "data entry" job that moves fast and asks for a lot',
    categoryId: 'job',
    text: 'Hello! This is Karen Doyle, Senior HR Recruiter at Lumenfield Analytics. We reviewed your resume and '
        'you have been selected for our Remote Data Entry Clerk position, \$38/hour, no experience needed. '
        'Your interview will be held via Telegram chat today. Congratulations on your new role! '
        'To complete onboarding, please send your Social Security number, a photo of your driver\'s license, '
        'and your bank account details for direct deposit. We will mail you a check to purchase your laptop '
        'and software from our approved vendor. Please respond within 24 hours to secure the position. '
        'Contact: lumenfield.hr.team@gmail.com',
    answers: {
      'company': 'Lumenfield Analytics',
      'recruiter_email': 'lumenfield.hr.team@gmail.com',
      'found_where': 'They contacted me first',
      'interview_type': 'Text or chat app only',
      'hired_immediately': YesNo.yes,
    },
  ),
  DemoExample(
    id: 'demo_bank',
    title: 'Fake bank text',
    subtitle: '"Your account is locked" text with a link and a code request',
    categoryId: 'bank',
    featured: true,
    text: 'FIRST HARBOR BANK ALERT: Unusual sign-in detected. Your account has been locked. '
        'Verify your identity at https://firstharbor-secure-login.xyz/verify within 24 hours or your account '
        'will be closed. A fraud specialist will call you — read them the 6-digit verification code we send. '
        'Do not share this with anyone.',
    answers: {'company': 'First Harbor Bank'},
  ),
  DemoExample(
    id: 'demo_irs',
    title: 'Government "arrest" threat',
    subtitle: 'A caller claiming to be the IRS demands gift cards',
    categoryId: 'government',
    featured: true,
    text: 'This is Officer Daniel Reed, badge number 4471, with the Internal Revenue Service. There is a warrant '
        'for your arrest due to unpaid taxes. To avoid arrest today you must pay \$1,850 immediately using '
        'Target gift cards. Stay on the line, do not hang up, and do not tell anyone, including your bank. '
        'Read me the numbers on the back of the cards.',
    answers: {'agency': 'IRS', 'contact_method': 'Phone call'},
  ),
  DemoExample(
    id: 'demo_romance',
    title: 'Romance scam',
    subtitle: 'An online relationship that turns to money',
    categoryId: 'romance',
    featured: true,
    text: 'My love, I have never felt this way about anyone. You are my soulmate. I am still on the oil rig '
        'offshore and my camera is broken so I cannot video call yet. I am stuck with a customs fee of \$2,500 '
        'to release my equipment. Please send it in Bitcoin so I can come home to you. Keep this between us — '
        'your family would not understand what we have.',
    answers: {'met_where': 'Social media', 'how_long': '2 weeks – 2 months', 'video_called': YesNo.no},
  ),
  DemoExample(
    id: 'demo_phishing',
    title: 'Phishing email',
    subtitle: 'A "failed delivery" notice with a shortened link',
    categoryId: 'message',
    text: 'From: parcel-notice@delivery-status-update.top\n'
        'Subject: Delivery attempt failed — action required\n\n'
        'Dear Customer, we were unable to deliver your package. Please update your address and pay a \$1.99 '
        'redelivery fee within 12 hours or your package will be returned: http://bit.ly/3xRedeliv',
    answers: {'message_type': 'Email', 'expected': YesNo.no},
  ),
  DemoExample(
    id: 'demo_website',
    title: 'Suspicious website',
    subtitle: 'A look-alike link imitating a payment company',
    categoryId: 'website',
    text: 'http://paypa1-account-verify.com/login',
    answers: {'link_source': 'Text', 'asks_login': YesNo.yes},
  ),
  DemoExample(
    id: 'demo_youth',
    title: 'Concerning youth conversation',
    subtitle: 'A gaming "friend" asking for secrecy and to meet',
    categoryId: 'youth',
    featured: true,
    text: "you're so mature for your age, way more than other people in your grade. "
        "don't tell your parents about our chats, they wouldn't understand. "
        'add me on snap so we can talk more private. i can send you 1000 robux. '
        'what school do you go to? we should meet up this weekend',
    answers: {'who_checking': 'Parent or guardian', 'platform': 'Game / gaming chat'},
  ),
  DemoExample(
    id: 'demo_low',
    title: 'Ordinary reminder',
    subtitle: 'A routine message — shows what a low-risk result looks like',
    categoryId: 'message',
    text: 'Maple Street Pharmacy: Your prescription is ready for pickup at our Main St location. '
        'Store hours are 9am-7pm. Reply STOP to opt out of text reminders.',
    answers: {'message_type': 'Text message', 'expected': YesNo.yes},
  ),
];
