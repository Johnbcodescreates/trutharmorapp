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
    _p(r'\bread (me )?(the|that|your) code\b'),
    _p(r'\bcode (we|i) (just )?sent\b'),
    _p(r'\b(verification|security|one[- ]time|confirmation|access|6[- ]digit|authentication) code\b'),
    _p(r'\b(read|send|tell|give|share|forward)\b.{0,25}\bcode\b'),
    _p(r'\botp\b'),
  ],
  'login_requested': [
    _p(r'\b(log ?in|sign ?in)\b.{0,40}\b(link|below|here|to (verify|restore|unlock|confirm))'),
    _p(r'\b(verify|confirm|update|restore)\b.{0,15}\b(your )?(account|identity|information|details)\b'),
  ],
  'personal_info_requested': [
    _p(r'\b(date of birth|dob|birth ?date|mother.?s maiden name|home address|mailing address)\b'),
  ],
  'deed_documents_requested': [
    _p(r'\b(copy|send|provide|upload)\b.{0,30}\b(deed|title|ownership (documents|papers|records))\b'),
    _p(r'\bquit ?claim\b'),
  ],

  // Financial
  'bank_info_requested': [
    _p(r'\bbank(ing)? ?(account|acct|details|info|information|login|credentials|password)\b'),
    _p(r'\b(account|routing|acct) (number|#|no\.?)\b'),
    _p(r'\b(bank|checking|savings) (account|details|info|information|login)\b'),
    _p(r'\brouting (number|#)\b'),
    _p(r'\bdirect deposit (form|info|details|information)\b'),
  ],
  'card_info_requested': [
    _p(r'\bupdate (your )?(payment|billing) (info|information|details|method)\b'),
    _p(r'\b(credit|debit|bank|atm) ?card ?(info|information|details|number|#|no\.?|pin)\b'),
    _p(r'\b(send|provide|share|give|submit|enter|confirm|verify|update|text|email|reply with)\b.{0,80}\b(credit|debit) ?card\b'),
    _p(r'\b(cvv|cvc|security code|expiration date)\b'),
    _p(r'\b(card number|cvv|cvc|security code on|expiration date|debit card|credit card) ?(number|details|info)?\b.{0,25}\b(verify|confirm|provide|enter|update)'),
    _p(r'\b(verify|confirm|provide|enter|update)\b.{0,25}\b(card number|cvv|pin)\b'),
  ],
  'payment_requested': [
    _p(r'\b(send|transfer|wire|lend|loan|give) (me|us) (\$\s?\d|money|cash|some money|funds)\b'),
    _p(r'\b(can|could|would) you (please )?(send|pay|transfer|lend|loan|wire)\b.{0,30}(\$\s?\d|money|cash|funds)'),
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
    _p(r'\bguaranteed (returns?|profits?|income|gains?)\b'),
    _p(r'\brisk[- ]free (investment|returns?|profits?|income)\b'),
    _p(r'\bdouble your (money|investment|crypto)\b'),
    _p(r'\b(guaranteed returns?|double your money|trading platform|investment (opportunity|platform|account)|invest (with|through) me|crypto (trading|mining) (platform|opportunity))\b'),
  ],
  'too_good_to_be_true': [
    _p(r'\b(earn|make) (money |cash |\$\s?\d[\d,]* )?(from home|online)\b'),
    _p(r'\bno experience (needed|required|necessary)\b.{0,60}\b(earn|make|\$)'),
    _p(r'\b(no experience (needed|required))\b.{0,60}\$\s?\d{3,}'),
    _p(r'\$\s?\d{2,3}(\.\d{2})?\s?(/|per )\s?(hr|hour)\b.{0,40}\b(no experience|data entry|flexible)\b'),
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
    _p(r'\b(interruption|loss|termination|suspension) of (your )?(service|access|account|benefits)\b'),
    _p(r'\b(avoid|prevent|face) (a )?(suspension|deactivation|penalt(y|ies)|late fees?|collections?|fines?)\b'),
    _p(r'\b(licen[cs]e|registration|account) (will|may|could) be (suspended|revoked|deactivated|closed|locked|terminated)\b'),
    _p(r'\b(sent|referred) to collections\b'),
    _p(r'\b(legal action|lawsuit|sued|court action|account (will be )?(closed|terminated|suspended)|benefits (will be )?(suspended|stopped))\b'),
  ],

  // Urgency / pressure
  'urgency': [
    _p(r'\b(final|last) (notice|reminder|warning|attempt)\b'),
    _p(r'\bwithin (\d+|one|two|twenty[- ]four|forty[- ]eight) (hours?|hrs?|minutes?|mins?|days?)\b'),
    _p(r'\b(limited time|act fast|respond now|immediate action|action required|time[- ]sensitive|before it.?s too late|expires? (tonight|at midnight))\b'),
    _p(r'\bbefore (you )?(check|talk|speak) (with|to) (anyone|someone|your)\b'),
    _p(r'\b(urgent(ly)?|immediately|right away|right now|hurry|act now|asap|within (24|48|12|2) hours|today only|final (notice|warning)|last chance|expires? (today|soon|in))\b'),
    _p(r"\b(don'?t|do not) (wait|delay|hang up)\b"),
  ],
  'emotional_pressure': [
    _p(r"\b(you('ll| will) regret|i('m| am) (so )?(scared|desperate)|please help me|only you can|if you (really )?love(d)? me|i thought you cared)\b"),
  ],
  'emergency_claim': [
    _p(r'\b(accident|hospital|emergency|stranded|bail|lawyer fees?|medical bills?|surgery|stuck at (the )?(airport|customs))\b'),
  ],

  // Common scam scripts
  'account_alert': [
    _p(r'\b(unusual|suspicious|unauthori[sz]ed|irregular) (activity|sign-?ins?|log-?ins?|access|charges?|transactions?|purchases?)\b'),
    _p(r'\baccount (problem|issue|alert|notice|on hold|(has been |is )(limited|restricted|flagged|locked|on hold|disabled))\b'),
    _p(r'\b(we|we.?ve|we have) (detected|noticed|identified)\b.{0,40}\b(unusual|suspicious|problem|issue|unauthori[sz]ed)\b'),
  ],
  'toll_ticket_notice': [
    _p(r'\b(unpaid|outstanding|overdue|pending) (tolls?|toll (charges?|balance|fees?))\b'),
    _p(r'\btoll (violation|balance|notice|charges?|fee|invoice|bill)\b'),
    _p(r'\b(e-?zpass|sunpass|fastrak|txtag|peach pass|i-?pass|the toll ?roads|nc quick pass|e-?zdrive)\b'),
    _p(r'\b(traffic|parking|speeding|camera) (ticket|violation|citation|fine)\b'),
    _p(r'\b(dmv|department of motor vehicles|motor vehicle (department|services))\b'),
  ],
  'delivery_notice': [
    _p(r'\b(package|parcel|shipment|delivery|order)\b.{0,40}\b(failed|unsuccessful|on hold|held|could not be delivered|couldn.?t be delivered|undeliverable|returned to sender)\b'),
    _p(r'\b(usps|ups|fedex|dhl|royal mail|canada post|post office|mail carrier|postal service)\b.{0,80}\b(reschedule|redeliver(y)?|update|confirm|track|address|fee)\b'),
    _p(r'\b(unable|failed|attempted) to deliver\b|\bdelivery attempt\b|\bredelivery\b'),
    _p(r'\b(address|zip code|postal code) (is |was )?(incomplete|incorrect|invalid|missing)\b'),
  ],
  'prize_claim': [
    _p(r'\bcongratulations\b.{0,80}\b(won|win|selected|chosen|winner|prize|reward|gift|eligible)\b'),
    _p(r"\byou('ve| have)? (won|been selected|been chosen|been picked)\b"),
    _p(r'\bclaim your (prize|reward|gift|winnings|refund|bonus|cash)\b'),
    _p(r"\b(lottery|sweepstakes|jackpot|giveaway|raffle)\b.{0,40}\b(winner|won|prize)\b|\byou('re| are) (our|a|the) (lucky )?winner\b"),
    _p(r'\b(small|processing|release|handling|shipping) fee to (claim|receive|release|get)\b'),
  ],
  'generic_greeting': [
    _p(r'\bdear (sir|madam|sir or madam|sir/madam|customer|valued customer|user|client|account holder|member|beneficiary|friend)\b'),
    _p(r'\b(would you )?kindly\b|\bdo the needful\b'),
  ],
  'click_link': [
    _p(r'\b(click|tap|follow|visit|open|use)(ing)? (on )?(the |this |our |below )?(link|here|url|button)\b'),
    _p(r'\b(link|button) below\b'),
  ],
  'approve_request': [
    _p(r'\b(tap|click|press|hit|select) .?approve\b'),
    _p(r'\b(tap|click|press|hit|select) .?(allow|yes|accept)\b.{0,60}\b(sign-?in|log-?in|verify|confirm (it.?s|that it.?s) you|security|account)\b'),
    _p(r'\bapprove (the|this|that|our) (request|sign-?in|log-?in|notification|prompt|push)\b'),
  ],
  'safe_account': [
    _p(r'\bwithdraw (the |your |all )?(cash|money|funds|savings)\b.{0,60}\b(secure|safe|protect|courier|pick ?up|agent)\b'),
    _p(r'\b(safe|secure|protected|holding|safety) (account|wallet)\b'),
    _p(r'\bmove (it|them|your (money|funds|savings|balance))\b.{0,40}\b(safe|secure|protected|new) (account|place|location)\b'),
    _p(r'\byour (money|funds|savings|account) (is|are) (not safe|at risk|in danger)\b'),
  ],
  'tech_support': [
    _p(r'\b(tech(nical)? support|microsoft support|apple support|windows (support|defender)|geek squad)\b'),
    _p(r'\b(computer|device|pc|laptop|phone|system) (is|has been|was|may be) (infected|hacked|compromised|locked)\b'),
    _p(r'\b(virus|malware|trojan|spyware|ransomware) (detected|found|alert|warning)\b'),
  ],
  'mistaken_payment': [
    _p(r'\b(sent|transferred|deposited|paid) (money|funds|it|\$\s?\d[\d,]*|you money)\b.{0,40}\bby (mistake|accident)\b'),
    _p(r'\b(accidentally|mistakenly) (sent|transferred|deposited|paid)\b'),
    _p(r'\bby mistake\b.{0,60}\b(send|return|refund|pay) (it |the money )?back\b'),
  ],
  'favor_request': [
    _p(r'\b(can|could) you do me a (quick |small |big )?favou?r\b'),
    _p(r'\b(i need|need) a (quick |small )?favou?r\b'),
  ],

  // Source
  'platform_move': [
    _p(r'\b(whatsapp|telegram|signal app|wickr|google chat|text me at|add me on)\b'),
  ],

  // Behavioral
  'secrecy': [
    _p(r'\b(stay on the line|do not hang up|don.?t hang up)\b'),
    _p(r'\b(do not|don.?t) tell (the )?(bank|bank staff|teller|branch|staff|police)\b'),
    _p(r'\b(bank )?(staff|employees|tellers?) (may|might|could) be (involved|in on it)\b'),
    _p(r"\b(keep (this|it) (between us|secret|confidential|private)|don'?t tell (anyone|mom|dad|my (mom|dad|parents)|grandpa|grandma|your (family|bank|kids|children|spouse))|do not tell (anyone|the bank)|our (little )?secret)\b"),
  ],
  'family_impersonation': [
    _p(r'\b(hi|hey|hello) (mum|mom|mommy|mama|dad|daddy|papa|grandma|grandpa)\b.{0,60}\b(new (number|phone)|lost my phone|broke my phone)\b'),
    _p(r'\b(this is|here.?s|heres) my new (number|phone)\b'),
    _p(r"\b(grandma|grandpa|grandmother|grandfather|nana|papa|mom|dad|auntie|uncle)[,!.?]?\s+(hi[,!]?\s+)?it'?s me\b"),
    _p(r"\bit'?s (me|your (grandson|granddaughter|son|daughter|nephew|niece))\b.{0,80}\b(trouble|accident|arrested|jail|hospital|help)\b"),
    _p(r"\b(i|i've|i have) (got )?a new (phone|number)\b|\blost my phone\b"),
    _p(r"\bmy voice (sounds|is) (weird|different|funny|strange)\b"),
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
