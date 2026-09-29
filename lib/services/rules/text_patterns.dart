/// Plain-language patterns the rule engine looks for in pasted / OCR text.
///
/// Each entry maps a signal id (see data/signal_catalog.dart) to phrases
/// that commonly indicate it. These are deliberately simple and readable so
/// student developers and judges can see exactly why something was flagged.
/// They are intentionally broad pattern families — not an exhaustive list.
RegExp _p(String pattern) => RegExp(pattern, caseSensitive: false);

final Map<String, List<RegExp>> kTextPatterns = {
  // Identity
  'ssn_requested': [
    _p(r'social security (number|#|no\.?)'),
    _p(r'\bssn\b'),
    _p(r'\bsocial\b.{0,20}\bnumber\b.{0,30}\b(verify|confirm|provide|send|need)'),
  ],
  'id_document_requested': [
    _p(r"(driver'?s?|drivers) licen[cs]e"),
    _p(r'\b(photo|picture|copy|scan) of (your )?(id|passport|licen[cs]e|state id)\b'),
    _p(r'\bpassport\b'),
  ],
  'password_requested': [
    _p(r'\b(your|confirm|enter|provide|send|verify)\b.{0,20}\bpassword\b'),
    _p(r'\bpassword\b.{0,20}\b(to verify|to confirm|for verification)\b'),
  ],
  'verification_code_requested': [
    _p(r'\b(verification|security|one[- ]time|confirmation|access|6[- ]digit|authentication) code\b'),
    _p(r'\b(read|send|tell|give|share|forward)\b.{0,25}\bcode\b'),
    _p(r'\botp\b'),
  ],
  'login_requested': [
    _p(r'\b(log ?in|sign ?in)\b.{0,40}\b(link|below|here|to (verify|restore|unlock|confirm))'),
    _p(r'\b(verify|confirm|update|restore)\b.{0,15}\b(your )?(account|identity|information|details)\b'),
  ],
  'personal_info_requested': [
    _p(r'\b(date of birth|dob|mother.?s maiden name|home address)\b'),
  ],
  'deed_documents_requested': [
    _p(r'\b(copy|send|provide|upload)\b.{0,30}\b(deed|title|ownership (documents|papers|records))\b'),
    _p(r'\bquit ?claim\b'),
  ],

  // Financial
  'bank_info_requested': [
    _p(r'\b(bank|checking|savings) (account|details|info|information|login)\b'),
    _p(r'\brouting (number|#)\b'),
    _p(r'\bdirect deposit (form|info|details|information)\b'),
  ],
  'card_info_requested': [
    _p(r'\b(card number|cvv|cvc|security code on|expiration date|debit card|credit card) ?(number|details|info)?\b.{0,25}\b(verify|confirm|provide|enter|update)'),
    _p(r'\b(verify|confirm|provide|enter|update)\b.{0,25}\b(card number|cvv|pin)\b'),
  ],
  'payment_requested': [
    _p(r'\b(pay|payment|fee|deposit)\b.{0,30}\b(required|due|now|today|immediately|to (proceed|continue|release|avoid))\b'),
    _p(r'\b(processing|registration|training|background check|release|customs|clearance|redelivery|delivery|shipping|toll|unpaid toll|activation|verification) fee\b'),
    _p(r'\bpay (a |the )?(small )?\$\s?\d'),
    _p(r'\boutstanding (balance|amount|debt)\b'),
  ],
  'gift_cards': [
    _p(r'\bgift ?cards?\b'),
    _p(r'\b(itunes|apple|google play|steam|target|walmart|amazon|ebay|razer gold) (gift )?cards?\b'),
    _p(r'\b(scratch|read) (off )?(the )?(back|numbers|pin)\b'),
  ],
  'crypto_requested': [
    _p(r'\b(bitcoin|btc|crypto(currency)?|usdt|tether|ethereum|eth|wallet address)\b'),
    _p(r'\b(bitcoin|crypto) (atm|machine|kiosk)\b'),
  ],
  'wire_transfer': [
    _p(r'\bwire (transfer|the money|funds)\b'),
    _p(r'\b(zelle|venmo|cash ?app|western union|moneygram)\b'),
    _p(r'\bsafe (account|wallet)\b'),
  ],
  'check_overpayment': [
    _p(r'\b(deposit|cash|mobile deposit)\b.{0,40}\bcheck\b.{0,80}\b(send|return|refund|purchase|buy|vendor|zelle|remaining)\b'),
    _p(r'\b(send|sending|mail|mailing|overnight) (you )?a (check|cheque)\b'),
  ],
  'equipment_purchase': [
    _p(r'\b(purchase|buy|order)\b.{0,40}\b(equipment|laptop|computer|software|supplies|office setup)\b'),
    _p(r'\b(approved|certified) vendor\b'),
    _p(r'\breimburs(e|ed|ement)\b.{0,40}\bequipment\b'),
  ],
  'money_mule': [
    _p(r'\b(receive|forward|transfer|process)\b.{0,20}\b(payments|funds|money)\b.{0,30}\b(for (us|the company|clients|me)|on (our|my) behalf)\b'),
    _p(r'\b(reship|re-ship|repackage)\b.{0,20}\b(packages|items)\b'),
    _p(r'\bpayment (processing|coordinator) (agent|assistant)\b'),
  ],
  'investment_request': [
    _p(r'\b(guaranteed returns?|double your money|trading platform|investment (opportunity|platform|account)|invest (with|through) me|crypto (trading|mining) (platform|opportunity))\b'),
  ],
  'too_good_to_be_true': [
    _p(r'\b(no experience (needed|required))\b.{0,60}\$\s?\d{3,}'),
    _p(r'\$\s?\d{2,3}(\.\d{2})?\s?(/|per )\s?(hr|hour)\b.{0,40}\b(no experience|data entry|flexible)\b'),
    _p(r"\byou('ve| have)? (won|been selected)\b"),
    _p(r'\b(guaranteed|risk[- ]free)\b.{0,20}\b(income|returns?|profit|money)\b'),
  ],

  // Impersonation
  'government_impersonation': [
    _p(r'\b(irs|internal revenue service|social security administration|ssa|medicare|department of (justice|treasury|homeland security)|u\.?s\.? marshals?|sheriff|federal agent|fbi|dea)\b'),
    _p(r'\b(badge number|case number|agent id)\b'),
  ],
  'bank_impersonation': [
    _p(r'\b(fraud department|security team|bank alert|account (has been )?(locked|suspended|restricted|compromised))\b'),
    _p(r'\b(chase|wells fargo|bank of america|citi(bank)?|capital one|paypal|zelle|venmo|cash app|navy federal|us bank)\b.{0,50}\b(alert|verify|locked|suspended|unusual|unauthorized)\b'),
  ],
  'arrest_threat': [
    _p(r'\b(warrant|arrest(ed)?|jail|police (will|are)|law enforcement will|avoid arrest|taken into custody)\b'),
  ],
  'legal_threat': [
    _p(r'\b(legal action|lawsuit|sued|court action|account (will be )?(closed|terminated|suspended)|benefits (will be )?(suspended|stopped))\b'),
  ],

  // Urgency / pressure
  'urgency': [
    _p(r'\b(urgent(ly)?|immediately|right away|act now|asap|within (24|48|12|2) hours|today only|final (notice|warning)|last chance|expires? (today|soon|in))\b'),
    _p(r"\b(don'?t|do not) (wait|delay|hang up)\b"),
  ],
  'emotional_pressure': [
    _p(r"\b(you('ll| will) regret|i('m| am) (so )?(scared|desperate)|please help me|only you can|if you (really )?love(d)? me|i thought you cared)\b"),
  ],
  'emergency_claim': [
    _p(r'\b(accident|hospital|emergency|stranded|bail|lawyer fees?|medical bills?|surgery|stuck at (the )?(airport|customs))\b'),
  ],

  // Source
  'platform_move': [
    _p(r'\b(whatsapp|telegram|signal app|wickr|google chat|text me at|add me on)\b'),
  ],

  // Behavioral
  'secrecy': [
    _p(r"\b(keep (this|it) (between us|secret|confidential|private)|don'?t tell (anyone|your (family|bank|kids|children|spouse))|do not tell (anyone|the bank)|our (little )?secret)\b"),
  ],
  'fast_affection': [
    _p(r"\b(i love you|soul ?mate|my (queen|king|wife|husband)|never felt this way|destiny|meant to be)\b"),
  ],
  'avoids_verification': [
    _p(r"\b(camera (is )?(broken|not working)|can'?t video|cannot video|no video|not allowed to (video|call)|bad (connection|signal) for video)\b"),
  ],
  'remote_story': [
    _p(r'\b(deployed|military base|peacekeeping|oil rig|offshore|on a ship|cargo ship|overseas contract|doctor (with|for) (the )?un|widow(er)?)\b'),
  ],
  'instant_hire': [
    _p(r"\b(you('ve| have) been (hired|selected)|you('re| are) hired|no interview (needed|required)|hired immediately|congratulations on your new (role|position))\b"),
  ],
  'chat_only_interview': [
    _p(r'\b(interview|interviewed)\b.{0,40}\b(via|on|through|over) (text|chat|telegram|whatsapp|signal|google hangouts|teams chat)\b'),
  ],
  'signature_requested': [
    _p(r'\b(sign|signature|notariz(e|ed))\b.{0,30}\b(documents?|papers?|forms?|deed|agreement|contract)\b'),
  ],
  'ownership_change_claim': [
    _p(r'\b(ownership (has )?(changed|transferred|dispute)|title (has been )?(transferred|changed)|lien (has been )?(placed|filed)|your (home|property) (is|was) (sold|transferred))\b'),
  ],
  'attachment_or_download': [
    _p(r'\b(open|download|install|see) (the )?(attached|attachment|file|invoice|app|apk)\b'),
    _p(r'\b\w+\.(zip|exe|apk|scr|iso)\b'),
  ],
  'remote_access': [
    _p(r'\b(anydesk|teamviewer|screenconnect|ultraviewer|logmein|quick ?assist|remote access|share (your )?screen)\b'),
  ],

  // ───── Youth safety (only evaluated in the youth category) ─────
  'youth_secrecy': [
    _p(r"\b(don'?t|do not|never) tell (your )?(mom|dad|parents?|anyone|teachers?|family)\b"),
    _p(r'\b(our (little )?secret|keep (this|it) (between us|secret)|just between (us|you and me))\b'),
    _p(r'\bdelete (this|these|our) (chat|messages?|conversation)\b'),
  ],
  'youth_photo_request': [
    _p(r'\b(send|show) (me )?(a |some )?(pic|pics|picture|photo|selfie|video)s?\b'),
    _p(r'\b(turn on|open) (your )?(camera|cam)\b'),
  ],
  'youth_sexual_content': [
    _p(r'\b(nudes?|naked|sexy|sexual|undress|no clothes|private (pics|photos|parts))\b'),
  ],
  'youth_location_request': [
    _p(r'\b(where do you live|what school|which school|your address|what town|home alone|when are your parents)\b'),
  ],
  'youth_personal_info': [
    _p(r"\b(what'?s your (real name|phone number|number|last name)|give me your number)\b"),
  ],
  'youth_platform_move': [
    _p(r'\b(snap(chat)?|kik|telegram|whatsapp|discord dm|private (server|chat)|disappearing messages)\b'),
  ],
  'youth_meet_pressure': [
    _p(r'\b(meet (up|me|in person)|come (over|meet)|pick you up|hang out in person|sneak out)\b'),
  ],
  'youth_gifts': [
    _p(r'\b(robux|v-?bucks|gift ?card|buy you|send you money|free (skins?|items?|gems))\b'),
  ],
  'youth_isolation': [
    _p(r"\b(only i understand you|your parents (don'?t|wouldn'?t) understand|they don'?t get you like i do|you don'?t need them)\b"),
  ],
  'youth_age_misrepresentation': [
    _p(r"\b(i'?m (really|actually) (older|\d{2})|age is just a number|don'?t worry about my age)\b"),
  ],
  'youth_flattery': [
    _p(r'\b(so mature (for your age)?|mature for your age|you.re (so )?(special|different from the others))\b'),
  ],
  'youth_threats': [
    _p(r"\b(or (else|i'?ll)|i'?ll (share|post|send) (your|the) (pics|photos|pictures)|you'?ll be in trouble|everyone will see)\b"),
  ],
};
