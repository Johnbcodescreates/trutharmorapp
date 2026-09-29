import '../models/scan_category.dart';

/// Official, publicly listed U.S. reporting & help resources.
/// Verify these periodically — phone numbers and URLs can change.
class Resources {
  Resources._();

  static const ftc = HelpResource(
    name: 'FTC — ReportFraud.ftc.gov',
    detail: 'Report scams and fraud to the Federal Trade Commission.',
    url: 'https://reportfraud.ftc.gov',
  );
  static const identityTheft = HelpResource(
    name: 'IdentityTheft.gov',
    detail: 'Step-by-step recovery plan if personal information was shared.',
    url: 'https://www.identitytheft.gov',
  );
  static const ic3 = HelpResource(
    name: 'FBI Internet Crime Complaint Center (IC3)',
    detail: 'Report internet-enabled crime, including money lost online.',
    url: 'https://www.ic3.gov',
  );
  static const elderFraud = HelpResource(
    name: 'National Elder Fraud Hotline',
    detail: 'Free help for adults 60+ (U.S. Department of Justice).',
    phone: '1-833-372-8311',
  );
  static const aarp = HelpResource(
    name: 'AARP Fraud Watch Network Helpline',
    detail: 'Free, for anyone of any age. Talk with a trained volunteer.',
    phone: '1-877-908-3360',
  );
  static const tigta = HelpResource(
    name: 'TIGTA — IRS impersonation reports',
    detail: 'Report people pretending to be from the IRS.',
    url: 'https://www.tigta.gov',
  );
  static const ssaOig = HelpResource(
    name: 'Social Security OIG',
    detail: 'Report Social Security impersonation scams.',
    url: 'https://oig.ssa.gov',
  );
  static const spamText = HelpResource(
    name: 'Forward scam texts to 7726 (SPAM)',
    detail: 'Most U.S. carriers accept forwarded scam texts at 7726.',
  );
  static const phishing = HelpResource(
    name: 'Report phishing emails',
    detail: 'Forward phishing emails to reportphishing@apwg.org and the impersonated company.',
  );
  static const cyberTipline = HelpResource(
    name: 'NCMEC CyberTipline',
    detail: 'Report online exploitation or enticement of a child. Save evidence; do not delete it.',
    url: 'https://report.cybertip.org',
    phone: '1-800-843-5678',
  );
  static const takeItDown = HelpResource(
    name: 'Take It Down (NCMEC)',
    detail: 'Help removing nude or sexual images taken of someone under 18.',
    url: 'https://takeitdown.ncmec.org',
  );
  static const childhelp = HelpResource(
    name: 'Childhelp National Child Abuse Hotline',
    detail: 'Call or text 24/7 to talk with a counselor.',
    phone: '1-800-422-4453',
  );
  static const emergency = HelpResource(
    name: 'Immediate danger? Call 911',
    detail: 'If anyone is in immediate danger, contact emergency services.',
    phone: '911',
  );
  static const countyRecorder = HelpResource(
    name: 'Your county recorder / register of deeds',
    detail: 'Check official property records. Many counties offer free property-fraud alerts.',
  );
}
