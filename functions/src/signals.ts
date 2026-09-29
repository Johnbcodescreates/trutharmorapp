/**
 * Signal ids — MUST stay in sync with lib/data/signal_catalog.dart.
 * The app (not the AI) owns the weights; the AI may only REPORT these ids.
 */
export const ALL_SIGNAL_IDS = [
  "ssn_requested", "id_document_requested", "password_requested", "verification_code_requested",
  "login_requested", "personal_info_requested", "deed_documents_requested", "bank_info_requested",
  "card_info_requested", "payment_requested", "gift_cards", "crypto_requested", "wire_transfer",
  "check_overpayment", "equipment_purchase", "money_mule", "investment_request", "too_good_to_be_true",
  "government_impersonation", "bank_impersonation", "domain_mismatch", "nonofficial_email", "arrest_threat",
  "legal_threat", "urgency", "emotional_pressure", "emergency_claim", "platform_move", "unsolicited_contact",
  "secrecy", "fast_affection", "avoids_verification", "remote_story", "instant_hire", "chat_only_interview",
  "signature_requested", "ownership_change_claim", "attachment_or_download", "remote_access",
  "shortened_url", "ip_address_url", "lookalike_domain", "punycode_domain", "unusual_tld", "insecure_http",
  "suspicious_url_structure", "known_malicious_url",
  "youth_secrecy", "youth_photo_request", "youth_sexual_content", "youth_location_request",
  "youth_personal_info", "youth_platform_move", "youth_meet_pressure", "youth_gifts", "youth_isolation",
  "youth_age_misrepresentation", "youth_flattery", "youth_threats",
] as const;

/** Link-structure and reputation signals are decided by code, never by the AI. */
const CODE_ONLY = new Set<string>([
  "shortened_url", "ip_address_url", "punycode_domain", "unusual_tld", "insecure_http",
  "suspicious_url_structure", "known_malicious_url",
]);

export const AI_SIGNAL_IDS: string[] = ALL_SIGNAL_IDS.filter((id) => !CODE_ONLY.has(id));

export const CATEGORY_IDS = [
  "job", "property", "bank", "government", "message", "website", "romance", "youth", "ai_message",
] as const;

export type CategoryId = (typeof CATEGORY_IDS)[number];

export function isYouthSignal(id: string): boolean {
  return id.startsWith("youth_");
}
