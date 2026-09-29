import 'package:flutter/material.dart';

import '../models/question.dart';
import '../models/scan_category.dart';
import 'help_resources.dart';

/// All TruthArmor categories. To add a category, add one ScanCategory here
/// (plus a matching prompt in functions/src/categoryPrompts.ts).
class Categories {
  Categories._();

  // Shared option lists
  static const _contactMethods = ['Phone call', 'Text message', 'Email', 'Mail / letter', 'Social media', 'In person', 'Other'];

  // ─────────────────────────────── 1. JOB ───────────────────────────────
  static const job = ScanCategory(
    id: 'job',
    title: 'Job or Work Opportunity',
    shortTitle: 'Job Offer',
    icon: Icons.work_outline_rounded,
    phase: 2,
    articleId: 'job_scams',
    description:
        'Fake jobs can be used to collect Social Security numbers, banking information, identification '
        'documents, and other personal data. Check before applying, responding, or sharing sensitive information.',
    simpleDescription: 'Check a job offer before you share personal information or money.',
    detectionKeywords: [
      'job', 'position', 'hiring', 'recruiter', 'interview', 'salary', 'per hour', '/hr', 'remote',
      'work from home', 'onboarding', 'hr department', 'resume', 'applicant', 'candidate', 'employment',
      'offer letter', 'training', 'equipment', 'data entry', 'part-time', 'full-time',
    ],
    questions: [
      Question(id: 'company', label: 'Company name', type: QuestionType.text, role: FieldRole.claimedOrganization, section: 'The job'),
      Question(id: 'job_title', label: 'Job title', type: QuestionType.text, section: 'The job'),
      Question(id: 'location', label: 'Job location', type: QuestionType.text, section: 'The job'),
      Question(
        id: 'work_type',
        label: 'Remote, onsite, or hybrid?',
        type: QuestionType.singleChoice,
        options: ['Remote', 'Onsite', 'Hybrid', 'Not sure'],
        section: 'The job',
      ),
      Question(id: 'pay', label: 'Compensation offered', hint: 'e.g. \$35/hour', type: QuestionType.text, section: 'The job'),
      Question(
        id: 'too_good',
        label: 'Does the pay seem unusually high for the work involved?',
        simpleLabel: 'Does the pay seem too good to be true?',
        signalIfYes: 'too_good_to_be_true',
        section: 'The job',
      ),
      Question(id: 'recruiter_name', label: 'Recruiter name', type: QuestionType.text, section: 'The recruiter'),
      Question(id: 'recruiter_email', label: 'Recruiter email', type: QuestionType.email, role: FieldRole.senderEmail, section: 'The recruiter'),
      Question(id: 'recruiter_phone', label: 'Recruiter phone', type: QuestionType.phone, role: FieldRole.senderPhone, section: 'The recruiter'),
      Question(id: 'company_website', label: 'Company website', hint: 'e.g. company.com', type: QuestionType.url, role: FieldRole.officialWebsite, section: 'The recruiter'),
      Question(id: 'posting_url', label: 'Job posting link', type: QuestionType.url, role: FieldRole.suspiciousUrl, section: 'The recruiter'),
      Question(
        id: 'found_where',
        label: 'Where did you find the job?',
        type: QuestionType.singleChoice,
        options: ['Indeed', 'LinkedIn', 'Company website', 'They contacted me first', 'Social media', 'Other'],
        optionSignals: {'They contacted me first': 'unsolicited_contact'},
        section: 'The recruiter',
      ),
      Question(id: 'interviewed', label: 'Was an interview conducted?', signalIfNo: 'instant_hire', section: 'Hiring process'),
      Question(
        id: 'interview_type',
        label: 'What kind of interview?',
        type: QuestionType.singleChoice,
        options: ['Video call', 'Phone call', 'In person', 'Text or chat app only', 'No interview'],
        optionSignals: {'Text or chat app only': 'chat_only_interview', 'No interview': 'instant_hire'},
        section: 'Hiring process',
      ),
      Question(id: 'hired_immediately', label: 'Were you hired immediately?', signalIfYes: 'instant_hire', section: 'Hiring process'),
      Question(
        id: 'moved_platform',
        label: 'Was communication moved to WhatsApp, Telegram, or Signal?',
        simpleLabel: 'Did they ask to move to WhatsApp, Telegram, or another chat app?',
        signalIfYes: 'platform_move',
        section: 'Hiring process',
      ),
      Question(id: 'pressured', label: 'Were you pressured to act quickly?', signalIfYes: 'urgency', section: 'Hiring process'),
      Question(id: 'ssn', label: 'Was your Social Security number requested?', signalIfYes: 'ssn_requested', section: 'What they asked for'),
      Question(id: 'license', label: "Was a driver's license or ID requested?", signalIfYes: 'id_document_requested', section: 'What they asked for'),
      Question(id: 'bank', label: 'Was banking information requested?', signalIfYes: 'bank_info_requested', section: 'What they asked for'),
      Question(id: 'payment', label: 'Were you asked to pay anything (fees, training, background check)?', simpleLabel: 'Did they ask you to pay money?', signalIfYes: 'payment_requested', section: 'What they asked for'),
      Question(id: 'equipment', label: 'Were you asked to buy equipment or supplies?', signalIfYes: 'equipment_purchase', section: 'What they asked for'),
      Question(id: 'check_sent', label: 'Did they send you a check to deposit?', signalIfYes: 'check_overpayment', section: 'What they asked for'),
      Question(id: 'crypto', label: 'Was cryptocurrency involved?', signalIfYes: 'crypto_requested', section: 'What they asked for'),
      Question(id: 'move_money', label: 'Were you asked to receive or forward money or packages?', signalIfYes: 'money_mule', section: 'What they asked for'),
    ],
    recommendedActions: [
      'Look up the company yourself and apply through its official careers page',
      'Contact the company using a phone number or email from its official website',
      'Do not share your SSN or bank details until you have verified the employer',
    ],
    verifySteps: [
      VerifyStep('Find the company on your own', 'Search for the company name yourself. Do not use links or phone numbers from the message.'),
      VerifyStep('Check the official careers page', 'Real openings are usually listed on the company\'s own website. See if this job is there.'),
      VerifyStep('Call the company directly', 'Use the main phone number from the official website and ask if the recruiter works there.'),
      VerifyStep('Compare email addresses', 'Real recruiters usually email from the company\'s own domain (name@company.com), not Gmail or Outlook.'),
      VerifyStep('Know the normal order', 'Legitimate employers collect SSN and bank info for payroll only after a real offer and interview — and never ask you to pay to work.'),
    ],
    resources: [Resources.ftc, Resources.identityTheft],
  );

  // ─────────────────────────────── 2. PROPERTY ───────────────────────────────
  static const property = ScanCategory(
    id: 'property',
    title: 'Property or Home',
    shortTitle: 'Property',
    icon: Icons.home_outlined,
    phase: 3,
    articleId: 'property_fraud',
    description:
        'Property fraud can have serious consequences. Verify unusual requests involving your home, deed, title, '
        'ownership records, or property documents before signing or sharing information.',
    simpleDescription: 'Check unusual requests about your home, deed, or property papers.',
    specialNotice:
        'TruthArmor cannot determine property ownership or legal status. Verify through your county recorder or '
        'assessor, a licensed title company, or a real-estate attorney.',
    detectionKeywords: [
      'deed', 'title', 'property', 'home', 'house', 'lien', 'escrow', 'closing', 'mortgage', 'refinance',
      'ownership', 'parcel', 'county recorder', 'buyer', 'cash offer', 'quitclaim', 'notary', 'real estate',
    ],
    questions: [
      Question(
        id: 'property_type',
        label: 'Property type',
        type: QuestionType.singleChoice,
        options: ['House', 'Condo / apartment', 'Land / vacant lot', 'Rental property', 'Other'],
        section: 'The property',
      ),
      Question(id: 'general_location', label: 'General location (city/county only)', hint: 'Please do not enter your full address', type: QuestionType.text, section: 'The property'),
      Question(
        id: 'inquiry',
        label: 'What is this about?',
        type: QuestionType.multiChoice,
        options: ['Selling', 'Buying', 'Refinancing', 'Title inquiry', 'Deed inquiry', 'Ownership issue', 'Unsolicited offer'],
        optionSignals: {'Unsolicited offer': 'unsolicited_contact'},
        section: 'The property',
      ),
      Question(id: 'contact_name', label: 'Person or company contacting you', type: QuestionType.text, role: FieldRole.claimedOrganization, section: 'Who contacted you'),
      Question(id: 'contact_email', label: 'Their email', type: QuestionType.email, role: FieldRole.senderEmail, section: 'Who contacted you'),
      Question(id: 'contact_phone', label: 'Their phone', type: QuestionType.phone, role: FieldRole.senderPhone, section: 'Who contacted you'),
      Question(id: 'contact_website', label: 'Their website', type: QuestionType.url, role: FieldRole.suspiciousUrl, section: 'Who contacted you'),
      Question(id: 'docs_requested', label: 'Were deed or title documents requested?', signalIfYes: 'deed_documents_requested', section: 'What they asked for'),
      Question(id: 'signature', label: 'Were you asked to sign something?', signalIfYes: 'signature_requested', section: 'What they asked for'),
      Question(id: 'payment', label: 'Was payment requested?', signalIfYes: 'payment_requested', section: 'What they asked for'),
      Question(id: 'wire', label: 'Were you asked to wire money (e.g. for closing)?', signalIfYes: 'wire_transfer', section: 'What they asked for'),
      Question(id: 'urgency', label: 'Is there an urgent deadline?', signalIfYes: 'urgency', section: 'Pressure'),
      Question(id: 'legal_action', label: 'Did they claim legal action?', signalIfYes: 'legal_threat', section: 'Pressure'),
      Question(id: 'ownership_change', label: 'Did they claim ownership has changed?', signalIfYes: 'ownership_change_claim', section: 'Pressure'),
    ],
    recommendedActions: [
      'Check your property record with your county recorder or assessor',
      'Have a title company or real-estate attorney review documents before signing',
      'Confirm wiring instructions by calling a known number — never from an email',
    ],
    verifySteps: [
      VerifyStep('Look up your own record', 'Visit your county recorder, register of deeds, or assessor website (search for it yourself) to see the official record.'),
      VerifyStep('Sign up for property-fraud alerts', 'Many counties offer free alerts when any document is recorded with your name.'),
      VerifyStep('Get a professional to review', 'A licensed title company or real-estate attorney can review documents before you sign anything.'),
      VerifyStep('Verify wiring instructions by phone', 'Call your title/escrow company at a number you already have. Wire instructions changed by email are a major warning sign.'),
    ],
    resources: [Resources.countyRecorder, Resources.ftc, Resources.ic3],
  );

  // ─────────────────────────────── 3. BANK ───────────────────────────────
  static const bank = ScanCategory(
    id: 'bank',
    title: 'Bank or Payment',
    shortTitle: 'Bank / Payment',
    icon: Icons.account_balance_outlined,
    phase: 2,
    articleId: 'financial_exploitation',
    description:
        'Scammers often impersonate banks and payment services to steal account information, passwords, '
        'verification codes, or money.',
    simpleDescription: 'Check a message that says it is from your bank or a payment app.',
    detectionKeywords: [
      'bank', 'account', 'locked', 'suspended', 'fraud alert', 'transaction', 'debit', 'credit card', 'zelle',
      'venmo', 'paypal', 'cash app', 'refund', 'unauthorized', 'charge', 'wells fargo', 'chase',
      'bank of america', 'card ending', 'dispute',
    ],
    questions: [
      Question(id: 'company', label: 'Bank or payment company named', type: QuestionType.text, role: FieldRole.claimedOrganization, section: 'Who contacted you'),
      Question(id: 'sender_name', label: 'Sender name', type: QuestionType.text, section: 'Who contacted you'),
      Question(id: 'sender_email', label: 'Sender email', type: QuestionType.email, role: FieldRole.senderEmail, section: 'Who contacted you'),
      Question(id: 'sender_phone', label: 'Phone number', type: QuestionType.phone, role: FieldRole.senderPhone, section: 'Who contacted you'),
      Question(id: 'url', label: 'Link in the message', type: QuestionType.url, role: FieldRole.suspiciousUrl, section: 'Who contacted you'),
      Question(
        id: 'claimed_problem',
        label: 'What problem do they claim?',
        type: QuestionType.multiChoice,
        options: ['Account locked', 'Fraud alert', 'Payment dispute', 'Refund', 'Other'],
        section: 'The message',
      ),
      Question(id: 'login', label: 'Were you asked to log in through a link?', signalIfYes: 'login_requested', section: 'What they asked for'),
      Question(id: 'password', label: 'Was your password requested?', signalIfYes: 'password_requested', section: 'What they asked for'),
      Question(id: 'code', label: 'Was a verification code requested?', simpleLabel: 'Did they ask for a code sent to your phone?', signalIfYes: 'verification_code_requested', section: 'What they asked for'),
      Question(id: 'ssn', label: 'Was your SSN requested?', signalIfYes: 'ssn_requested', section: 'What they asked for'),
      Question(id: 'card', label: 'Was debit/credit card information requested?', signalIfYes: 'card_info_requested', section: 'What they asked for'),
      Question(id: 'transfer', label: 'Were you asked to transfer money (e.g. "to a safe account")?', signalIfYes: 'wire_transfer', section: 'What they asked for'),
      Question(id: 'gift_cards', label: 'Were gift cards mentioned?', signalIfYes: 'gift_cards', section: 'What they asked for'),
      Question(id: 'crypto', label: 'Was cryptocurrency mentioned?', signalIfYes: 'crypto_requested', section: 'What they asked for'),
      Question(id: 'urgency', label: 'Is it urgent (act now or lose access)?', signalIfYes: 'urgency', section: 'Pressure'),
      Question(id: 'threat', label: 'Were you threatened (account closure, legal action)?', signalIfYes: 'legal_threat', section: 'Pressure'),
    ],
    recommendedActions: [
      'Call the number on the back of your card or open your official banking app',
      'Do not share passwords or verification codes — your bank will never ask for them',
      'If you already shared information, contact your bank immediately',
    ],
    verifySteps: [
      VerifyStep('Use the number on your card', 'Call the phone number printed on the back of your debit or credit card, or on your statement.'),
      VerifyStep('Open the official app yourself', 'Check for alerts inside your bank\'s official app or by typing the website address yourself.'),
      VerifyStep('Hang up and call back', 'If someone calls you, hang up and call the official number. Scammers can fake caller ID.'),
      VerifyStep('Remember the rule', 'Banks will never ask you to move money to a "safe account", pay with gift cards, or read them a verification code.'),
    ],
    resources: [Resources.ftc, Resources.ic3, Resources.spamText],
  );

  // ─────────────────────────────── 4. GOVERNMENT ───────────────────────────────
  static const government = ScanCategory(
    id: 'government',
    title: 'Tax or Government',
    shortTitle: 'Government',
    icon: Icons.gavel_rounded,
    phase: 2,
    articleId: 'government_impersonation',
    description:
        'Scammers may impersonate government agencies to create fear, demand payment, or obtain personal information.',
    simpleDescription: 'Check a message that says it is from the IRS, Social Security, a court, or police.',
    specialNotice:
        'TruthArmor cannot tell whether a warrant, debt, or legal case actually exists. Verify directly with the '
        'relevant official agency using independently obtained contact information.',
    detectionKeywords: [
      'irs', 'tax', 'social security', 'ssa', 'warrant', 'arrest', 'court', 'jury duty', 'police', 'sheriff',
      'federal', 'government', 'agent', 'badge', 'medicare', 'benefits', 'suspended', 'legal action',
      'lawsuit', 'fine', 'penalty', 'department of',
    ],
    questions: [
      Question(
        id: 'agency',
        label: 'Which agency do they claim to be?',
        type: QuestionType.singleChoice,
        options: ['IRS', 'Social Security', 'Court / jury duty', 'Police / sheriff', 'Medicare', 'Immigration', 'Other agency'],
        role: FieldRole.claimedOrganization,
        section: 'Who contacted you',
      ),
      Question(id: 'contact_method', label: 'How did they contact you?', type: QuestionType.singleChoice, options: _contactMethods, section: 'Who contacted you'),
      Question(id: 'sender', label: 'Sender name, email, or number', type: QuestionType.text, section: 'Who contacted you'),
      Question(id: 'sender_email', label: 'Sender email (if any)', type: QuestionType.email, role: FieldRole.senderEmail, section: 'Who contacted you'),
      Question(id: 'link', label: 'Link (if any)', type: QuestionType.url, role: FieldRole.suspiciousUrl, section: 'Who contacted you'),
      Question(id: 'payment_demand', label: 'Did they demand payment?', signalIfYes: 'payment_requested', section: 'What they asked for'),
      Question(id: 'gift_cards', label: 'Did they ask for gift cards?', signalIfYes: 'gift_cards', section: 'What they asked for'),
      Question(id: 'wire', label: 'Did they ask for a wire transfer or payment app?', signalIfYes: 'wire_transfer', section: 'What they asked for'),
      Question(id: 'crypto', label: 'Did they ask for cryptocurrency or a crypto ATM?', signalIfYes: 'crypto_requested', section: 'What they asked for'),
      Question(id: 'bank', label: 'Did they ask for bank information?', signalIfYes: 'bank_info_requested', section: 'What they asked for'),
      Question(id: 'ssn', label: 'Did they ask for your SSN?', signalIfYes: 'ssn_requested', section: 'What they asked for'),
      Question(id: 'arrest', label: 'Did they threaten arrest or claim there is a warrant?', signalIfYes: 'arrest_threat', section: 'Threats and pressure'),
      Question(id: 'legal', label: 'Did they threaten legal action or suspension of benefits?', signalIfYes: 'legal_threat', section: 'Threats and pressure'),
      Question(id: 'deadline', label: 'Did they give a short deadline ("pay today")?', signalIfYes: 'urgency', section: 'Threats and pressure'),
      Question(id: 'secret', label: 'Did they tell you not to tell anyone or stay on the line?', signalIfYes: 'secrecy', section: 'Threats and pressure'),
    ],
    recommendedActions: [
      'Do not pay. Government agencies do not demand gift cards, crypto, or wire transfers',
      'Hang up and contact the agency using its official .gov website or a number you already have',
      'Talk with a trusted person before doing anything',
    ],
    verifySteps: [
      VerifyStep('Go to the official .gov website', 'Type the agency\'s address yourself (for example irs.gov or ssa.gov). Don\'t use links from the message.'),
      VerifyStep('Check your official account', 'The IRS and Social Security have online accounts where real notices and balances appear.'),
      VerifyStep('Call the court clerk directly', 'For warrants or jury duty, look up the court clerk\'s number yourself and call.'),
      VerifyStep('Know how agencies really contact you', 'The IRS usually starts with a letter by mail. Agencies do not threaten immediate arrest over the phone.'),
    ],
    resources: [Resources.tigta, Resources.ssaOig, Resources.ftc, Resources.elderFraud],
  );

  // ─────────────────────────────── 5. EMAIL / TEXT ───────────────────────────────
  static const message = ScanCategory(
    id: 'message',
    title: 'Email or Text Message',
    shortTitle: 'Email / Text',
    icon: Icons.mark_email_unread_outlined,
    phase: 2,
    articleId: 'phishing',
    description:
        'Phishing messages are designed to look legitimate while tricking you into clicking, responding, '
        'downloading something, or giving away personal information.',
    simpleDescription: 'Check an email or text before you click, reply, or download.',
    detectionKeywords: [
      'click', 'verify', 'confirm', 'update your', 'package', 'delivery', 'usps', 'fedex', 'ups', 'invoice',
      'unsubscribe', 'dear customer', 'attachment', 'reply', 'text stop', 'toll', 'order',
    ],
    questions: [
      Question(
        id: 'message_type',
        label: 'Message type',
        type: QuestionType.singleChoice,
        options: ['Email', 'Text message', 'Social media message', 'Other'],
        section: 'The message',
      ),
      Question(id: 'claimed_org', label: 'Who does it claim to be from?', type: QuestionType.text, role: FieldRole.claimedOrganization, section: 'The message'),
      Question(id: 'sender_email', label: 'Sender email', type: QuestionType.email, role: FieldRole.senderEmail, section: 'The message'),
      Question(id: 'sender_phone', label: 'Sender phone number', type: QuestionType.phone, role: FieldRole.senderPhone, section: 'The message'),
      Question(id: 'url', label: 'Link in the message', type: QuestionType.url, role: FieldRole.suspiciousUrl, section: 'The message'),
      Question(id: 'expected', label: 'Were you expecting this message?', signalIfNo: 'unsolicited_contact', section: 'The message'),
      Question(id: 'attachment', label: 'Does it include an attachment or ask you to download something?', signalIfYes: 'attachment_or_download', section: 'What it asks'),
      Question(id: 'login', label: 'Does it ask you to log in?', signalIfYes: 'login_requested', section: 'What it asks'),
      Question(id: 'password', label: 'Does it ask for a password?', signalIfYes: 'password_requested', section: 'What it asks'),
      Question(id: 'code', label: 'Does it ask for a verification code?', signalIfYes: 'verification_code_requested', section: 'What it asks'),
      Question(id: 'payment', label: 'Does it ask for payment?', signalIfYes: 'payment_requested', section: 'What it asks'),
      Question(id: 'personal', label: 'Does it ask for personal information?', signalIfYes: 'personal_info_requested', section: 'What it asks'),
      Question(id: 'urgency', label: 'Is it urgent?', signalIfYes: 'urgency', section: 'Pressure'),
      Question(id: 'threat', label: 'Does it threaten you?', signalIfYes: 'legal_threat', section: 'Pressure'),
    ],
    recommendedActions: [
      'Do not click links or open attachments in the message',
      'Go to the organization\'s website by typing the address yourself',
      'Report and delete the message',
    ],
    verifySteps: [
      VerifyStep('Don\'t use the message\'s links or numbers', 'Do not use the contact information in the suspicious message to verify it.'),
      VerifyStep('Go to the source yourself', 'Visit the organization\'s official website or use a trusted phone number you already have.'),
      VerifyStep('Check the sender carefully', 'Look at the full email address, not just the display name. Small spelling changes are a warning sign.'),
      VerifyStep('Report it', 'Forward scam texts to 7726 (SPAM) and phishing emails to reportphishing@apwg.org.'),
    ],
    resources: [Resources.spamText, Resources.phishing, Resources.ftc],
  );

  // ─────────────────────────────── 6. WEBSITE ───────────────────────────────
  static const website = ScanCategory(
    id: 'website',
    title: 'Website or Link',
    shortTitle: 'Website / Link',
    icon: Icons.link_rounded,
    phase: 2,
    articleId: 'phishing',
    description:
        'Fake websites can imitate banks, employers, stores, government agencies, and other trusted '
        'organizations to steal information.',
    simpleDescription: 'Check a link before you open it or type anything into it.',
    detectionKeywords: ['http', 'www', '.com', 'link', 'website', 'site', 'url'],
    questions: [
      Question(id: 'url', label: 'The link (URL)', type: QuestionType.url, role: FieldRole.suspiciousUrl, section: 'The link'),
      Question(
        id: 'link_source',
        label: 'Where did the link come from?',
        type: QuestionType.singleChoice,
        options: ['Email', 'Text', 'Job posting', 'Social media', 'Search engine', 'Advertisement', 'Someone sent it', 'Other'],
        section: 'The link',
      ),
      Question(id: 'claimed_org', label: 'What organization does the site claim to be?', type: QuestionType.text, role: FieldRole.claimedOrganization, section: 'The link'),
      Question(id: 'asks_login', label: 'Does the site ask you to log in or enter personal info?', signalIfYes: 'login_requested', section: 'What the site does'),
      Question(id: 'asks_download', label: 'Does it ask you to download or install something?', signalIfYes: 'attachment_or_download', section: 'What the site does'),
      Question(id: 'asks_payment', label: 'Does it ask for payment or card details?', signalIfYes: 'card_info_requested', section: 'What the site does'),
    ],
    recommendedActions: [
      'Do not enter passwords or payment details on this site',
      'Type the organization\'s official address yourself instead of using the link',
    ],
    verifySteps: [
      VerifyStep('Read the website name right-to-left', 'The real owner is the part just before .com/.org/.gov. "paypal.com.secure-login.xyz" belongs to "secure-login.xyz", not PayPal.'),
      VerifyStep('Type the address yourself', 'Use a bookmark or type the official address instead of clicking.'),
      VerifyStep('Search the organization separately', 'Search for the organization and compare the official website to the link you received.'),
      VerifyStep('Be careful with ads', 'Scammers sometimes buy search ads that look like official sites.'),
    ],
    resources: [Resources.phishing, Resources.ftc],
  );

  // ─────────────────────────────── 7. ROMANCE ───────────────────────────────
  static const romance = ScanCategory(
    id: 'romance',
    title: 'Online Relationship / Romance',
    shortTitle: 'Online Relationship',
    icon: Icons.favorite_border_rounded,
    phase: 2,
    articleId: 'romance_scams',
    description:
        'Romance scammers may build emotional trust before requesting money, financial information, gifts, '
        'or other assistance.',
    simpleDescription: 'Check an online relationship if something feels off, especially if money comes up.',
    headlines: {
      'low': 'No major warning signs detected in what you shared.',
      'caution': 'This interaction contains some patterns worth paying attention to.',
      'elevated': 'This interaction contains patterns commonly associated with romance scams.',
      'high': 'This interaction contains several patterns commonly associated with romance scams.',
    },
    specialNotice:
        'TruthArmor cannot tell you who a person really is. It only looks for patterns commonly seen in romance scams.',
    detectionKeywords: [
      'love', 'darling', 'my dear', 'sweetheart', 'honey', 'baby', 'soulmate', 'destiny', 'military', 'deployed',
      'oil rig', 'overseas', 'widow', 'customs', 'hospital', 'plane ticket', 'visa', 'dating',
    ],
    questions: [
      Question(
        id: 'met_where',
        label: 'Where did you meet?',
        type: QuestionType.singleChoice,
        options: ['Dating app', 'Social media', 'Gaming platform', 'Messaging app', 'Other'],
        section: 'How you met',
      ),
      Question(
        id: 'how_long',
        label: 'How long have you been talking?',
        type: QuestionType.singleChoice,
        options: ['Less than 2 weeks', '2 weeks – 2 months', '2 – 6 months', 'More than 6 months'],
        section: 'How you met',
      ),
      Question(id: 'met_in_person', label: 'Have you met in person?', signalIfNo: 'avoids_verification', section: 'Verification'),
      Question(id: 'video_called', label: 'Have you had a live video call?', signalIfNo: 'avoids_verification', section: 'Verification'),
      Question(id: 'avoids', label: 'Do they make excuses to avoid video calls or meeting?', signalIfYes: 'avoids_verification', section: 'Verification'),
      Question(id: 'fast_feelings', label: 'Did they express strong feelings very quickly?', signalIfYes: 'fast_affection', section: 'Behavior'),
      Question(id: 'secrecy', label: 'Have they asked you to keep the relationship secret?', signalIfYes: 'secrecy', section: 'Behavior'),
      Question(id: 'emergency', label: 'Have they described a sudden emergency?', signalIfYes: 'emergency_claim', section: 'Behavior'),
      Question(
        id: 'story',
        label: 'Do they say they are…',
        type: QuestionType.multiChoice,
        options: ['Overseas', 'In the military', 'On a ship or oil rig', 'A doctor abroad', 'None of these'],
        optionSignals: {
          'Overseas': 'remote_story',
          'In the military': 'remote_story',
          'On a ship or oil rig': 'remote_story',
          'A doctor abroad': 'remote_story',
        },
        section: 'Behavior',
      ),
      Question(id: 'money', label: 'Have they asked for money?', signalIfYes: 'payment_requested', section: 'Money'),
      Question(id: 'gift_cards', label: 'Gift cards?', signalIfYes: 'gift_cards', section: 'Money'),
      Question(id: 'crypto', label: 'Cryptocurrency?', signalIfYes: 'crypto_requested', section: 'Money'),
      Question(id: 'wire', label: 'Wire transfer?', signalIfYes: 'wire_transfer', section: 'Money'),
      Question(id: 'bank', label: 'Your bank information?', signalIfYes: 'bank_info_requested', section: 'Money'),
      Question(id: 'move_money', label: 'Asked you to receive or move money for them?', signalIfYes: 'money_mule', section: 'Money'),
      Question(id: 'invest', label: 'Encouraged you to invest (often in crypto)?', signalIfYes: 'investment_request', section: 'Money'),
    ],
    recommendedActions: [
      'Do not send money, gift cards, or crypto to someone you have not met in person',
      'Talk with a trusted friend or family member about this relationship',
      'Try a reverse image search of their profile photos',
    ],
    verifySteps: [
      VerifyStep('Ask for a live video call', 'A real person can usually video chat. Repeated excuses are a warning sign.'),
      VerifyStep('Reverse image search their photos', 'Use a reverse image search to see if their photos appear under other names.'),
      VerifyStep('Talk to someone you trust', 'Share what is happening with a friend or family member. Scammers often ask for secrecy for a reason.'),
      VerifyStep('Keep money out of it', 'Never send money or financial help to someone you have only met online.'),
    ],
    resources: [Resources.ftc, Resources.ic3, Resources.aarp, Resources.elderFraud],
  );

  // ─────────────────────────────── 8. YOUTH ───────────────────────────────
  static const youth = ScanCategory(
    id: 'youth',
    title: 'Child & Teen Online Safety',
    shortTitle: 'Youth Safety',
    icon: Icons.family_restroom_rounded,
    phase: 3,
    articleId: 'online_child_safety',
    description:
        'Online predators may use trust, secrecy, gifts, manipulation, or pressure to create unsafe relationships '
        'with young people. TruthArmor helps identify concerning patterns and encourages safe adult support.',
    simpleDescription: 'Check an online conversation with a young person for unsafe patterns.',
    headlines: {
      'low': 'No major concerning patterns detected in what you shared.',
      'caution': 'Some concerning behavior patterns were identified. Talk it over with a trusted adult.',
      'elevated': 'Potentially unsafe interaction. Concerning behavior patterns were identified.',
      'high': 'Potentially unsafe interaction. Possible grooming indicators were identified — please involve a trusted adult now.',
    },
    specialNotice:
        'TruthArmor cannot determine whether someone is a predator. It looks for concerning behavior patterns. '
        'Please involve a trusted adult. Do not confront the other person, and do not delete the conversation — '
        'it may be important evidence.',
    detectionKeywords: [
      "don't tell", 'dont tell', 'our secret', 'parents', 'mom', 'dad', 'school', 'snapchat', 'discord', 'roblox',
      'fortnite', 'minecraft', 'robux', 'v-bucks', 'how old', 'grade', 'pic', 'selfie', 'mature for your age',
      'meet up', 'delete this', 'teacher',
    ],
    questions: [
      Question(
        id: 'who_checking',
        label: 'Who is doing this check?',
        type: QuestionType.singleChoice,
        options: ['Parent or guardian', 'Educator / counselor', 'Young person', 'Other trusted adult'],
        section: 'About this check',
      ),
      Question(
        id: 'platform',
        label: 'Where is the conversation happening?',
        type: QuestionType.singleChoice,
        options: ['Game / gaming chat', 'Social media', 'Messaging app', 'Video platform', 'Other'],
        section: 'About this check',
      ),
      Question(id: 'secrecy', label: 'Did they ask to keep things secret or not tell parents?', simpleLabel: 'Did they say "don\'t tell your parents" or "keep this secret"?', signalIfYes: 'youth_secrecy', section: 'What happened'),
      Question(id: 'private_move', label: 'Did they ask to move to a private or disappearing-message app?', signalIfYes: 'youth_platform_move', section: 'What happened'),
      Question(id: 'personal', label: 'Did they ask for personal information (full name, phone number)?', signalIfYes: 'youth_personal_info', section: 'What happened'),
      Question(id: 'location', label: 'Did they ask for location, school, or address?', signalIfYes: 'youth_location_request', section: 'What happened'),
      Question(id: 'photos', label: 'Did they ask for photos or videos?', signalIfYes: 'youth_photo_request', section: 'What happened'),
      Question(id: 'sexual', label: 'Did they send or ask for anything sexual or inappropriate?', signalIfYes: 'youth_sexual_content', section: 'What happened'),
      Question(id: 'gifts', label: 'Did they offer gifts, money, or game currency?', signalIfYes: 'youth_gifts', section: 'What happened'),
      Question(id: 'meet', label: 'Did they pressure to meet in person?', signalIfYes: 'youth_meet_pressure', section: 'What happened'),
      Question(id: 'isolation', label: 'Did they try to turn the young person against family or friends?', signalIfYes: 'youth_isolation', section: 'What happened'),
      Question(id: 'flattery', label: 'Lots of flattery (e.g. "you\'re so mature")?', signalIfYes: 'youth_flattery', section: 'What happened'),
      Question(id: 'age', label: 'Is there any sign they lied about their age?', signalIfYes: 'youth_age_misrepresentation', section: 'What happened'),
      Question(id: 'threats', label: 'Were there threats or pressure (including threats to share images)?', signalIfYes: 'youth_threats', section: 'What happened'),
    ],
    recommendedActions: [
      'Involve a trusted adult — a parent, guardian, school counselor, or teacher',
      'Stop responding, but do not delete the conversation — save it as evidence',
      'Do not confront the other person or arrange any meeting',
      'Block and report the account on the platform',
    ],
    verifySteps: [
      VerifyStep('Tell a trusted adult', 'Young people: you are not in trouble. Tell a parent, guardian, school counselor, or teacher.'),
      VerifyStep('Save, don\'t delete', 'Keep screenshots of the conversation and the account name. Evidence can help protect you and others.'),
      VerifyStep('Don\'t confront', 'Do not confront or warn the other person. Stop replying and let a trusted adult help.'),
      VerifyStep('Report', 'Report the account to the platform. For exploitation or enticement of a minor, report to the NCMEC CyberTipline. In immediate danger, call 911.'),
    ],
    resources: [Resources.emergency, Resources.cyberTipline, Resources.takeItDown, Resources.childhelp],
  );

  // ─────────────────────────────── 9. AI / SUSPICIOUS MESSAGE ───────────────────────────────
  static const aiMessage = ScanCategory(
    id: 'ai_message',
    title: 'AI or Suspicious Message',
    shortTitle: 'Suspicious Message',
    icon: Icons.auto_awesome_outlined,
    phase: 3,
    articleId: 'ai_scams',
    description:
        'AI can make scams sound polished, personalized, and convincing. Analyze suspicious communications for '
        'manipulation and scam patterns.',
    simpleDescription: 'Check any message that feels "off" — even if it sounds very professional.',
    specialNotice:
        'AI authorship cannot be determined with certainty. This assessment focuses on scam and manipulation patterns.',
    detectionKeywords: ['grandma', 'grandpa', "it's me", 'new number', 'voice', 'accident', 'bail', 'lawyer', 'emergency', 'help me'],
    questions: [
      Question(id: 'claimed_sender', label: 'Who does the message claim to be from?', type: QuestionType.text, role: FieldRole.claimedOrganization, section: 'The message'),
      Question(id: 'contact_method', label: 'How did it arrive?', type: QuestionType.singleChoice, options: _contactMethods, section: 'The message'),
      Question(id: 'url', label: 'Link (if any)', type: QuestionType.url, role: FieldRole.suspiciousUrl, section: 'The message'),
      Question(id: 'new_number', label: 'Did someone you know contact you from a new number or account?', signalIfYes: 'unsolicited_contact', section: 'The message'),
      Question(id: 'emergency', label: 'Is there an emergency (accident, arrest, hospital)?', signalIfYes: 'emergency_claim', section: 'What it asks'),
      Question(id: 'money', label: 'Does it ask for money?', signalIfYes: 'payment_requested', section: 'What it asks'),
      Question(id: 'secrecy', label: 'Does it ask you to keep it secret?', signalIfYes: 'secrecy', section: 'What it asks'),
      Question(id: 'remote', label: 'Does it ask you to install an app or share your screen?', signalIfYes: 'remote_access', section: 'What it asks'),
      Question(id: 'urgency', label: 'Is it urgent?', signalIfYes: 'urgency', section: 'What it asks'),
    ],
    recommendedActions: [
      'Contact the person or organization through a number or account you already know',
      'Use a family "safe word" to confirm emergencies',
      'Do not send money or information until you have verified independently',
    ],
    verifySteps: [
      VerifyStep('Call back on a known number', 'If "a relative" says they are in trouble, hang up and call them (or another family member) on the number you already have.'),
      VerifyStep('Use a family safe word', 'Agree on a secret word with family that a scammer — even one using an AI voice — would not know.'),
      VerifyStep('Ask a personal question', 'Ask something only the real person would know and that isn\'t on social media.'),
      VerifyStep('Slow down', 'Scammers rely on panic. Taking ten minutes to verify is always okay.'),
    ],
    resources: [Resources.ftc, Resources.ic3, Resources.elderFraud],
  );

  /// Display order on the Home screen.
  static const List<ScanCategory> all = [job, bank, government, message, website, romance, youth, property, aiMessage];

  static ScanCategory byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => aiMessage);
}
