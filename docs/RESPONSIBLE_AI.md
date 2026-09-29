# Responsible AI in TruthArmor

## What TruthArmor is — and is not

TruthArmor provides a **pattern-based risk assessment**. It clearly tells users:

- AI can make mistakes.
- Results are based on patterns, not proof.
- It does **not** determine legal truth (warrants, debts, property ownership).
- It does **not** determine whether a person is a criminal or a predator.
- It does **not** guarantee that a website, job, or message is legitimate.
- It **cannot** reliably determine whether a message was written by AI.
- Users should verify important information independently — and they make the final decision.

## How the design enforces this

| Principle | Where it lives |
|---|---|
| Green is **"Low Risk — No major warning signs detected"**, never "Safe" | `models/risk.dart` |
| The disclaimer appears on **every** assessment | `DisclaimerBox` on the results screen |
| Risk level and **analysis confidence** are separate | `RiskScorer._confidence` |
| The AI can't decide the result alone: fixed weights, AI-only signals at 70%, ±12 cap, combination floors | `services/risk/risk_scorer.dart` |
| The AI may only report **known** signal ids; code-only link signals can't come from AI | `functions/src/signals.ts`, `handler.ts` |
| Careful wording is enforced on the server ("is safe", "is a predator", "definitely a scam" are rewritten) | `functions/src/handler.ts` (`soften`) |
| Prompt-injection defense: message content is wrapped as `<untrusted_content>` and treated as data | `functions/src/prompt.ts` |
| Every reason is explainable, with its source and evidence | "Details for each signal" + "How was this calculated?" |
| Demo AI is always labeled and never changes a score | `DemoAnalysisService`, results screen labels |

## Careful language by category

- **Romance:** "This interaction contains patterns commonly associated with romance scams" — never "your
  partner is a scammer".
- **Government:** "patterns commonly associated with government impersonation scams. Verify directly with the
  relevant official agency using independently obtained contact information" — never whether a warrant exists.
- **Websites:** "No obvious high-risk indicators detected" — never "this site is safe".
- **Youth safety:** "Potentially unsafe interaction", "Concerning behavior pattern", "Possible grooming
  indicators" — never "predator".

## Child & teen safety

- Always encourages involving a **trusted adult**; tells young people they are not in trouble.
- Advises **not** confronting the other person and **not** deleting the conversation (it may be evidence).
- Points to the platform's reporting tools, the **NCMEC CyberTipline**, **Take It Down**, Childhelp, and 911 in
  an emergency.
- **No surveillance:** TruthArmor never secretly monitors anyone and gives no instructions for secretly monitoring
  a child. Future family features are built on education, consent, trusted-adult involvement, and privacy.
- The AI is instructed not to repeat or describe explicit content.

## Privacy

- **Minimum data:** the app never asks for SSNs, passwords, codes, or full account numbers, and warns users not to
  enter them — with a stronger warning when it detects them.
- **Redaction twice:** sensitive numbers are removed on the phone *and again on the server* before any AI call.
- **Screenshots never leave the phone:** OCR runs on-device; only reviewed text is analyzed.
- **History = metadata only:** date, category, risk level, and a generic title — on the device. Users can delete
  any scan, clear all history, or turn history off.
- **Server logs** record only status and category — never content.
- **No secrets in the app:** the AI key is a server-side secret.

## Known limitations (be honest with judges and users)

- Rule patterns are English-only and intentionally simple; new scam scripts appear constantly.
- The look-alike-domain check covers a fixed list of well-known brands and uses a simplified domain parser.
- OCR can misread text, which is why users must review it.
- The AI can be wrong or inconsistent; that is why it is one input among several.
- A "Low Risk" result means only that no major warning signs were found in what was shared.
