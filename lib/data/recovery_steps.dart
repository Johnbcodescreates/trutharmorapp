import '../models/scan_category.dart';
import 'help_resources.dart';

/// "ALREADY RESPONDED?" — what to do if the person already clicked, paid, or
/// shared something. Acting quickly often limits the damage, and nobody
/// should feel ashamed: scammers are professionals.
///
/// General U.S. guidance (FTC, IdentityTheft.gov). Review periodically.
class RecoveryScenario {
  const RecoveryScenario({
    required this.id,
    required this.title,
    required this.steps,
    this.resources = const [],
    this.relevantSignals = const {},
  });

  final String id;
  final String title;
  final List<String> steps;
  final List<HelpResource> resources;

  /// If any of these signals were found, this scenario is shown first.
  final Set<String> relevantSignals;
}

class ExtraResources {
  ExtraResources._();
  static const creditFreeze = HelpResource(
    name: 'Free credit freeze',
    detail: 'Contact all three credit bureaus — Equifax, Experian, and TransUnion. Freezing your credit is free.',
  );
  static const creditReports = HelpResource(
    name: 'AnnualCreditReport.com',
    detail: 'The official site for free credit reports. Look for accounts you don\'t recognize.',
    url: 'https://www.annualcreditreport.com',
  );
}

const List<RecoveryScenario> kRecoveryScenarios = [
  RecoveryScenario(
    id: 'paid',
    title: 'I sent money or paid something',
    relevantSignals: {
      'payment_requested', 'gift_cards', 'crypto_requested', 'wire_transfer', 'check_overpayment',
      'equipment_purchase', 'mistaken_payment', 'safe_account', 'prize_claim', 'investment_request',
    },
    steps: [
      'Act now — the sooner you report it, the better the chance of stopping the payment.',
      'Credit or debit card: call the number on the back of your card and say the charge was a scam. Ask to dispute it.',
      'Bank transfer, Zelle, Venmo, or Cash App: contact your bank or the app right away and ask them to stop or reverse it.',
      'Gift cards: contact the company that issued the card (the number is on the card or its website). Tell them it was used in a scam and ask for a refund. Keep the card and receipt.',
      'Wire transfer (like Western Union or MoneyGram): call the company right away and ask them to reverse the transfer.',
      'Cryptocurrency: contact the exchange or crypto ATM company you used. Crypto is very hard to get back, so report it quickly.',
      'Report it at ReportFraud.ftc.gov.',
      'Be careful of "recovery" offers — anyone promising to get your money back for a fee is usually another scammer.',
    ],
    resources: [Resources.ftc, Resources.ic3],
  ),
  RecoveryScenario(
    id: 'card_bank',
    title: 'I shared my card or bank details',
    relevantSignals: {'card_info_requested', 'bank_info_requested', 'bulk_personal_info'},
    steps: [
      'Call your bank or card company using the number on the back of your card or in their official app.',
      'Ask them to block or replace the card, and to watch the account for fraud.',
      'Turn on alerts for every purchase and transfer in your banking app.',
      'Check recent transactions and report any you don\'t recognize.',
    ],
    resources: [Resources.ftc],
  ),
  RecoveryScenario(
    id: 'identity',
    title: 'I shared my SSN, ID, or other personal information',
    relevantSignals: {'ssn_requested', 'id_document_requested', 'personal_info_requested', 'bulk_personal_info'},
    steps: [
      'Go to IdentityTheft.gov for a free, step-by-step recovery plan.',
      'Freeze your credit with all three credit bureaus (Equifax, Experian, TransUnion). It\'s free and stops new accounts being opened in your name.',
      'Check your credit reports at AnnualCreditReport.com for accounts you don\'t recognize.',
      'If you shared your Social Security number, consider getting an IRS Identity Protection PIN to block fake tax returns.',
      'If you shared a driver\'s license or passport photo, keep an eye out for accounts or loans opened in your name.',
    ],
    resources: [Resources.identityTheft, ExtraResources.creditFreeze, ExtraResources.creditReports],
  ),
  RecoveryScenario(
    id: 'clicked',
    title: 'I clicked a link or typed my password',
    relevantSignals: {
      'login_requested', 'password_requested', 'click_link', 'lookalike_domain', 'shortened_url',
      'suspicious_url_structure', 'account_alert', 'delivery_notice', 'toll_ticket_notice',
    },
    steps: [
      'If you only opened the link and typed nothing, close it. The risk is usually low.',
      'If you typed a password, change it right away — by going to the real website or app yourself, not the link.',
      'Change that password anywhere else you used it too.',
      'Turn on two-step verification for the account.',
      'If you entered card details, follow the card steps above.',
      'If you downloaded something, run a security scan or ask someone you trust for help.',
    ],
  ),
  RecoveryScenario(
    id: 'code',
    title: 'I shared a code or tapped "Approve"',
    relevantSignals: {'verification_code_requested', 'approve_request'},
    steps: [
      'Contact the company right away using its official app, website, or the number on your card.',
      'Change your password and sign out of all other devices if the account lets you.',
      'Check that your account\'s email address and phone number haven\'t been changed.',
      'Look for purchases, transfers, or messages you didn\'t make.',
    ],
  ),
  RecoveryScenario(
    id: 'remote',
    title: 'I let someone control my computer or phone',
    relevantSignals: {'remote_access', 'tech_support'},
    steps: [
      'Disconnect the device from the internet (turn off Wi-Fi or unplug it).',
      'Uninstall the program they had you install (for example AnyDesk or TeamViewer).',
      'Run a security scan, or ask a trusted person or a reputable repair shop for help.',
      'Using a different device, change your important passwords — email and banking first.',
      'Call your bank to tell them someone may have had access to your accounts.',
    ],
    resources: [Resources.ftc],
  ),
];

/// Youth safety uses different, protective guidance.
const List<RecoveryScenario> kYouthRecoveryScenarios = [
  RecoveryScenario(
    id: 'youth_images',
    title: 'Photos or videos were already shared',
    relevantSignals: {'youth_photo_request', 'youth_sexual_content', 'youth_threats'},
    steps: [
      'You are not in trouble. Tell a parent, guardian, or another trusted adult now.',
      'Do not send anything more, and do not pay or do what they demand — threats often get worse when people comply.',
      'Save the messages and the account name as evidence. Do not delete them.',
      'Block and report the account on the app.',
      'Take It Down can help get images of people under 18 removed from many sites.',
      'Report it to the NCMEC CyberTipline. If anyone is in immediate danger, call 911.',
    ],
    resources: [Resources.takeItDown, Resources.cyberTipline, Resources.emergency],
  ),
  RecoveryScenario(
    id: 'youth_location',
    title: 'My location, school, or address was shared',
    relevantSignals: {'youth_location_request', 'youth_meet_pressure', 'youth_personal_info'},
    steps: [
      'Tell a parent, guardian, or another trusted adult right away.',
      'Do not agree to meet, and stop replying.',
      'Block and report the account, and save the messages as evidence.',
      'Review privacy settings together so your location and school aren\'t visible.',
      'If you feel unsafe right now, call 911.',
    ],
    resources: [Resources.emergency, Resources.cyberTipline, Resources.childhelp],
  ),
];

/// Scenarios for this check, most relevant first.
List<(RecoveryScenario, bool)> recoveryScenariosFor(ScanCategory category, Set<String> signalIds) {
  final list = category.id == 'youth' ? kYouthRecoveryScenarios : kRecoveryScenarios;
  final scored = [
    for (final s in list) (s, s.relevantSignals.any(signalIds.contains)),
  ];
  scored.sort((a, b) => (b.$2 ? 1 : 0).compareTo(a.$2 ? 1 : 0));
  return scored;
}
