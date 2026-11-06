import 'package:daniel_portal/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a triage response and keeps its lowest confidence', () {
    final result = TriageResult.fromJson({
      'category': 'Noise/Nuisance',
      'urgency': 'High',
      'eligible': true,
      'exclusion': null,
      'recommended_action': 'Local Barangay Conciliation',
      'confidence': {
        'dispute_category': 0.91,
        'urgency_score': 0.74,
        'exclusion': 0.88,
      },
      'rule_reasons': <String>[],
      'needs_staff_review': false,
    });

    expect(result.category, 'Noise/Nuisance');
    expect(result.urgency, 'High');
    expect(result.eligible, isTrue);
    expect(result.minConfidence, 0.74);
    expect(result.needsStaffReview, isFalse);
  });

  test('rejects an incomplete triage response', () {
    expect(
      () => TriageResult.fromJson({'category': 'Noise/Nuisance'}),
      throwsFormatException,
    );
  });
}
