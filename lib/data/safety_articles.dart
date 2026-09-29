import 'package:flutter/material.dart';

/// Safety Center articles. Written so a teenager or a senior can follow them.
/// Every article answers the same five questions.
class SafetyArticle {
  const SafetyArticle({
    required this.id,
    required this.title,
    required this.icon,
    required this.looksLike,
    required this.warningSigns,
    required this.scammersWant,
    required this.whatToDo,
    required this.howToVerify,
    this.categoryId,
  });

  final String id;
  final String title;
  final IconData icon;

  /// 1. What the scam looks like
  final String looksLike;

  /// 2. Common warning signs
  final List<String> warningSigns;

  /// 3. What scammers want
  final String scammersWant;

  /// 4. What you should do
  final List<String> whatToDo;

  /// 5. How to verify safely
  final List<String> howToVerify;

  /// Category to open when the user taps "Check something now".
  final String? categoryId;
}

const List<SafetyArticle> kSafetyArticles = [
  SafetyArticle(
    id: 'job_scams',
    title: 'Job Scams',
    icon: Icons.work_outline_rounded,
    categoryId: 'job',
    looksLike:
        'A recruiter contacts you with a great remote job — often high pay for easy work. The "interview" happens over text '
        'or a chat app, you are hired almost instantly, and then they ask for personal information or money.',
    warningSigns: [
      'You were hired without a real interview',
      'The recruiter uses Gmail, Outlook, or another personal email',
      'They want your SSN or bank details before a real offer',
      'They send a check and ask you to buy equipment',
      'They move the conversation to WhatsApp or Telegram',
    ],
    scammersWant:
        'Your Social Security number, ID, and bank account (for identity theft), or your money through fake checks and '
        '"equipment" purchases. Some fake jobs also try to use you to move stolen money.',
    whatToDo: [
      'Stop and do not send personal information yet',
      'Never deposit a check from an employer you have not verified',
      'Never pay money to get a job',
    ],
    howToVerify: [
      'Find the company\'s official website yourself and look for the job on its careers page',
      'Call the company\'s main number and ask if the recruiter works there',
    ],
  ),
  SafetyArticle(
    id: 'phishing',
    title: 'Phishing (Fake Emails, Texts & Websites)',
    icon: Icons.phishing_rounded,
    categoryId: 'message',
    looksLike:
        'A message that looks like it is from a company you know — a bank, a delivery service, a streaming service — '
        'asking you to click a link, log in, pay a small fee, or open an attachment.',
    warningSigns: [
      'Urgent warnings like "your account will be closed"',
      'The sender\'s address or the link doesn\'t match the real company',
      'Shortened links or strange website endings',
      'Requests for passwords, codes, or card numbers',
      'Unexpected attachments',
    ],
    scammersWant: 'Your login details, verification codes, card number, or to install harmful software on your device.',
    whatToDo: [
      'Don\'t click links or open attachments in unexpected messages',
      'Report the message, then delete it',
      'If you already entered a password, change it right away from the official website',
    ],
    howToVerify: [
      'Type the company\'s website address yourself or use its official app',
      'Call a phone number you already have — not one from the message',
    ],
  ),
  SafetyArticle(
    id: 'elder_fraud',
    title: 'Elder Fraud',
    icon: Icons.elderly_rounded,
    looksLike:
        'Scammers target older adults with calls, texts, emails, and even home visits. Common stories: a grandchild in '
        'trouble, a government threat, a computer virus, a prize you "won", or a new online friend who needs money.',
    warningSigns: [
      'Someone you don\'t know asks for money or personal information',
      'You are told to keep it secret or stay on the phone',
      'Payment must be gift cards, wire transfer, cash, or cryptocurrency',
      'Someone wants to control your computer to "fix" a problem',
    ],
    scammersWant: 'Money, savings, retirement funds, Medicare or Social Security numbers, and access to bank accounts.',
    whatToDo: [
      'Hang up. It\'s okay to be "rude" to a stranger',
      'Talk with a family member or trusted friend before doing anything',
      'Call the National Elder Fraud Hotline (1-833-372-8311) for free help',
    ],
    howToVerify: [
      'Call your family member directly on the number you already have',
      'Contact your bank using the number on the back of your card',
    ],
  ),
  SafetyArticle(
    id: 'romance_scams',
    title: 'Romance Scams',
    icon: Icons.favorite_border_rounded,
    categoryId: 'romance',
    looksLike:
        'Someone you meet online becomes very affectionate very quickly. They always have a reason they can\'t meet or '
        'video chat. Eventually there is an emergency, a fee, or an investment opportunity that needs your money.',
    warningSigns: [
      'Strong feelings expressed quickly',
      'They are overseas, in the military, or working on a ship or oil rig',
      'They avoid video calls or keep cancelling plans to meet',
      'They ask you to keep the relationship secret',
      'They ask for money, gift cards, crypto, or help moving money',
    ],
    scammersWant: 'Your money — often again and again — and sometimes your help moving stolen money.',
    whatToDo: [
      'Never send money to someone you have only met online',
      'Talk to a friend or family member you trust',
      'Stop contact and report the profile to the site or app',
    ],
    howToVerify: [
      'Ask for a live video call',
      'Do a reverse image search on their profile photos',
    ],
  ),
  SafetyArticle(
    id: 'ai_scams',
    title: 'AI-Powered Scams',
    icon: Icons.auto_awesome_outlined,
    categoryId: 'ai_message',
    looksLike:
        'AI helps scammers write perfect messages, copy a company\'s style, and even imitate the voice of someone you '
        'love. The message may look professional and personal — but the request is the same: money or information, fast.',
    warningSigns: [
      'A "family member" calls from a new number with an emergency',
      'A polished message that still pushes urgency or secrecy',
      'A request that doesn\'t match how that person or company normally acts',
    ],
    scammersWant: 'Money or information, obtained by making you believe you are talking to someone you trust.',
    whatToDo: [
      'Pause — scammers depend on panic',
      'Create a family "safe word" for emergencies',
      'Remember: tools cannot reliably tell if AI wrote something. Focus on what is being asked of you',
    ],
    howToVerify: [
      'Hang up and call the person back on a number you already know',
      'Ask a question only the real person would know',
    ],
  ),
  SafetyArticle(
    id: 'identity_theft',
    title: 'Identity Theft',
    icon: Icons.badge_outlined,
    looksLike:
        'Someone uses your personal information — like your Social Security number, birth date, or bank details — to open '
        'accounts, file taxes, get loans, or make purchases in your name.',
    warningSigns: [
      'Bills or accounts you don\'t recognize',
      'Calls from debt collectors about debts that aren\'t yours',
      'A tax return is rejected because one was already filed',
      'Credit report entries you don\'t recognize',
    ],
    scammersWant: 'Enough personal information to pretend to be you.',
    whatToDo: [
      'Visit IdentityTheft.gov for a step-by-step recovery plan',
      'Consider freezing your credit with the three credit bureaus',
      'Change passwords and turn on two-step verification',
    ],
    howToVerify: [
      'Check your credit reports for free at AnnualCreditReport.com',
      'Review bank and card statements regularly',
    ],
  ),
  SafetyArticle(
    id: 'government_impersonation',
    title: 'Government Impersonation',
    icon: Icons.gavel_rounded,
    categoryId: 'government',
    looksLike:
        'A call, text, or email claims to be from the IRS, Social Security, a court, or the police. You are told you owe '
        'money, have a warrant, or your benefits will stop — unless you pay right now.',
    warningSigns: [
      'Threats of arrest or deportation',
      'Demands for gift cards, wire transfers, or cryptocurrency',
      'You are told not to hang up or not to tell anyone',
      'Caller ID shows a government name (this can be faked)',
    ],
    scammersWant: 'Immediate payment and your personal information.',
    whatToDo: [
      'Hang up. Real agencies don\'t demand instant payment by phone',
      'Never pay a government debt with gift cards or crypto',
      'Report IRS impersonation to TIGTA and Social Security impersonation to the SSA Inspector General',
    ],
    howToVerify: [
      'Go to the agency\'s official .gov website by typing it yourself',
      'Sign in to your official IRS or Social Security online account',
    ],
  ),
  SafetyArticle(
    id: 'online_child_safety',
    title: 'Online Child Safety',
    icon: Icons.family_restroom_rounded,
    categoryId: 'youth',
    looksLike:
        'An adult may pretend to be a friend — often in a game, chat, or social app — and slowly build trust with a young '
        'person using attention, compliments, or gifts. Over time they may push for secrecy, private chats, photos, or '
        'meeting in person.',
    warningSigns: [
      'Asking to keep conversations secret from parents',
      'Moving to private or disappearing-message apps',
      'Gifts, money, or game currency to build trust',
      'Asking for photos, location, or school name',
      'Pressure to meet, or threats',
    ],
    scammersWant: 'To build an unsafe relationship with a young person, away from the adults who protect them.',
    whatToDo: [
      'Young people: you are not in trouble. Tell a trusted adult',
      'Stop responding, but save the conversation — don\'t delete it',
      'Don\'t confront the person',
      'Report to the platform and to the NCMEC CyberTipline; call 911 if anyone is in immediate danger',
    ],
    howToVerify: [
      'Parents: talk openly and often about online friends — without punishment for telling you',
      'Use platform safety settings together, with your child\'s knowledge',
    ],
  ),
  SafetyArticle(
    id: 'property_fraud',
    title: 'Property Fraud',
    icon: Icons.home_outlined,
    categoryId: 'property',
    looksLike:
        'Criminals may try to sell or borrow against a home they don\'t own — especially vacant land or rental property — '
        'or trick owners into signing documents or wiring closing funds to the wrong account.',
    warningSigns: [
      'Unexpected requests for deed or title documents',
      'Pressure to sign quickly or notarize remotely',
      'Emailed changes to wiring instructions',
      'A "buyer" who never meets in person and wants a fast cash deal',
    ],
    scammersWant: 'Your property\'s equity, your closing funds, or your signature on documents that transfer ownership.',
    whatToDo: [
      'Don\'t sign anything you don\'t fully understand',
      'Have a title company or real-estate attorney review documents',
      'Sign up for your county\'s property-fraud alert, if offered',
    ],
    howToVerify: [
      'Check your property record with the county recorder or assessor',
      'Confirm wiring instructions by phone using a number you already have',
    ],
  ),
  SafetyArticle(
    id: 'financial_exploitation',
    title: 'Bank & Financial Exploitation',
    icon: Icons.account_balance_outlined,
    categoryId: 'bank',
    looksLike:
        'Someone pretends to be your bank\'s fraud department and says your money is at risk. To "protect" it, they ask '
        'you to share a code, move money to a "safe account", or let them access your computer.',
    warningSigns: [
      'Requests for verification codes or passwords',
      'Instructions to move money to a "safe account"',
      'Requests to install remote-access apps',
      'Pressure to act before you can call anyone',
    ],
    scammersWant: 'Access to your accounts and the money in them.',
    whatToDo: [
      'Hang up and call the number on the back of your card',
      'Never share one-time codes with anyone who contacts you',
      'Tell your bank right away if you shared information',
    ],
    howToVerify: [
      'Check your accounts in your official banking app',
      'Visit a branch in person if you are unsure',
    ],
  ),
];

SafetyArticle? articleById(String id) {
  for (final a in kSafetyArticles) {
    if (a.id == id) return a;
  }
  return null;
}
