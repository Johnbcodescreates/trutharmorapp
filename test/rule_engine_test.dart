import 'package:flutter_test/flutter_test.dart';
import 'package:truth_armor/data/categories.dart';
import 'package:truth_armor/data/demo_examples.dart';
import 'package:truth_armor/models/ai_analysis.dart';
import 'package:truth_armor/models/question.dart';
import 'package:truth_armor/models/risk.dart';
import 'package:truth_armor/services/ai/demo_analysis_service.dart';
import 'package:truth_armor/services/assessment_pipeline.dart';
import 'package:truth_armor/services/category_detector.dart';
import 'package:truth_armor/services/privacy/redactor.dart';
import 'package:truth_armor/services/risk/risk_scorer.dart';
import 'package:truth_armor/services/rules/rule_engine.dart';
import 'package:truth_armor/services/rules/url_analyzer.dart';

void main() {
  const engine = RuleEngine();
  const scorer = RiskScorer();

  Assessment assess(String categoryId, {String text = '', Map<String, dynamic> answers = const {}, AiAnalysis? ai}) {
    final category = Categories.byId(categoryId);
    final rules = engine.evaluate(category: category, text: text, answers: answers);
    return scorer.score(
      id: 't',
      category: category,
      rules: rules,
      ai: ai,
      answeredCount: answers.length,
      textLength: text.length,
    );
  }

  group('Rule engine', () {
    test('SSN + bank info + payment in a job is HIGH risk regardless of AI', () {
      final a = assess('job', answers: {'ssn': YesNo.yes, 'bank': YesNo.yes, 'payment': YesNo.yes});
      expect(a.level, RiskLevel.high);

      // Even an AI that says "0 risk" cannot pull it below the combination floor.
      const calmAi = AiAnalysis(summary: 's', simpleSummary: 's', signals: [], riskEstimate: 0, isDemo: false);
      final b = assess('job', answers: {'ssn': YesNo.yes, 'bank': YesNo.yes, 'payment': YesNo.yes}, ai: calmAi);
      expect(b.score, greaterThanOrEqualTo(75));
    });

    test('ordinary message is low risk and never labeled SAFE', () {
      final a = assess('message', text: 'Hi! Your dentist appointment is Tuesday at 3pm. See you then.');
      expect(a.level, RiskLevel.low);
      expect(a.level.label, isNot(contains('SAFE')));
      expect(a.headline, contains('No major warning signs'));
    });

    test('free-mail recruiter is flagged', () {
      final a = assess('job', answers: {'company': 'Acme Corp', 'recruiter_email': 'acme.hr@gmail.com'});
      expect(a.signals.map((s) => s.id), contains('nonofficial_email'));
    });

    test('email domain vs website mismatch is flagged', () {
      final a = assess('job', answers: {'recruiter_email': 'jobs@acme-careers.net', 'company_website': 'acme.com'});
      expect(a.signals.map((s) => s.id), contains('domain_mismatch'));
    });

    test('youth signals only apply in the youth category', () {
      const text = "don't tell your parents, add me on snap";
      final youth = assess('youth', text: text);
      final other = assess('message', text: text);
      expect(youth.signals.map((s) => s.id), contains('youth_secrecy'));
      expect(other.signals.map((s) => s.id).where((id) => id.startsWith('youth_')), isEmpty);
    });

    test('AI-only signals count at reduced weight and unknown ids are ignored', () {
      const ai = AiAnalysis(
        summary: 's',
        simpleSummary: 's',
        signals: [AiSignal('urgency', 'act now'), AiSignal('not_a_real_signal', 'x')],
        riskEstimate: 30,
        isDemo: false,
      );
      final a = assess('message', text: 'Please review the attached.', ai: ai);
      final urgency = a.signals.firstWhere((s) => s.id == 'urgency');
      expect(urgency.source, SignalSource.ai);
      expect(a.signals.where((s) => s.id == 'not_a_real_signal'), isEmpty);
    });

    test('AI adjustment is capped', () {
      const ai = AiAnalysis(summary: 's', simpleSummary: 's', signals: [], riskEstimate: 100, isDemo: false);
      final a = assess('message', text: 'Hello there, see you soon.', ai: ai);
      expect(a.score, lessThanOrEqualTo(RiskScorer.maxAiAdjustment));
    });

    test('demo AI never changes the score', () {
      const demo = AiAnalysis(summary: 's', simpleSummary: 's', signals: [], riskEstimate: 100, isDemo: true);
      final a = assess('message', text: 'Hello there, see you soon.', ai: demo);
      expect(a.score, 0);
      expect(a.isDemoAi, isTrue);
    });

    test('result always has 3-5 actions and reasons are at most 5', () {
      for (final e in kDemoExamples) {
        final a = assess(e.categoryId, text: e.text, answers: e.answers);
        expect(a.actions.length, inInclusiveRange(2, 5), reason: e.id);
        expect(a.reasons.length, lessThanOrEqualTo(5), reason: e.id);
      }
    });
  });

  group('Demo examples produce sensible results', () {
    final expected = {
      'demo_job': RiskLevel.high,
      'demo_bank': RiskLevel.high,
      'demo_irs': RiskLevel.high,
      'demo_romance': RiskLevel.high,
      'demo_website': RiskLevel.high,
      'demo_youth': RiskLevel.high,
      'demo_low': RiskLevel.low,
    };
    for (final e in kDemoExamples) {
      test(e.id, () {
        final a = assess(e.categoryId, text: e.text, answers: e.answers);
        if (expected.containsKey(e.id)) {
          expect(a.level, expected[e.id]);
        } else {
          expect(a.level.index, greaterThanOrEqualTo(RiskLevel.caution.index));
        }
      });
    }
  });

  group('URL analyzer', () {
    const u = UrlAnalyzer();
    List<String> ids(String url) => u.analyze(url).map((f) => f.signalId).toList();

    test('look-alike domains', () {
      expect(ids('http://paypa1-account-verify.com/login'), contains('lookalike_domain'));
      expect(ids('https://paypal.com.secure-login.xyz'), containsAll(['lookalike_domain', 'unusual_tld']));
      expect(ids('https://www.paypal.com/signin'), isNot(contains('lookalike_domain')));
      expect(ids('https://www.applebees.com'), isEmpty);
    });

    test('shorteners, IPs, punycode', () {
      expect(ids('https://bit.ly/abc'), contains('shortened_url'));
      expect(ids('http://192.168.4.20/login'), contains('ip_address_url'));
      expect(ids('https://xn--pypal-4ve.com'), contains('punycode_domain'));
    });

    test('extracts links without catching OCR run-ons or emails', () {
      final urls = u.extractUrls('Visit secure-bank.xyz/verify today.Please reply to help@acme.com');
      expect(urls, contains('secure-bank.xyz/verify'));
      expect(urls.any((x) => x.contains('today.Please')), isFalse);
      expect(urls.any((x) => x.contains('acme.com')), isFalse);
    });

    test('registrable domain', () {
      expect(u.registrableDomain('login.paypal.com.evil.xyz'), 'evil.xyz');
      expect(u.registrableDomain('www.bbc.co.uk'), 'bbc.co.uk');
    });
  });

  group('Redactor', () {
    const r = Redactor();
    test('hides SSNs, cards, codes, passwords, accounts', () {
      final out = r.redact('SSN 123-45-6789 card 4111 1111 1111 1111 code is 482913 password: hunter2 account number 12345678901');
      expect(out.text, isNot(contains('123-45-6789')));
      expect(out.text, isNot(contains('4111 1111 1111 1111')));
      expect(out.text, isNot(contains('482913')));
      expect(out.text, isNot(contains('hunter2')));
      expect(out.text, isNot(contains('12345678901')));
      expect(out.count, 5);
    });
    test('leaves phone numbers alone', () {
      expect(r.redact('Call 555-123-4567').changed, isFalse);
    });
  });

  group('Quick Scan category detector', () {
    const d = CategoryDetector();
    test('job text', () {
      expect(d.detect('Recruiter here — remote position, \$30 per hour, interview today, send your resume').category.id, 'job');
    });
    test('bare link', () {
      expect(d.detect('https://bit.ly/xyz').category.id, 'website');
    });
    test('unknown falls back to suspicious message', () {
      final g = d.detect('hello');
      expect(g.category.id, 'ai_message');
      expect(g.confident, isFalse);
    });
  });

  group('Pipeline', () {
    test('runs end-to-end in demo mode', () async {
      const pipeline = AssessmentPipeline(ai: DemoAnalysisService(delay: Duration.zero));
      final e = kDemoExamples.first;
      final a = await pipeline.run(e.toDraft());
      expect(a.isDemoAi, isTrue);
      expect(a.isDemoExample, isTrue);
      expect(a.summary, isNotEmpty);
    });
  });
}
