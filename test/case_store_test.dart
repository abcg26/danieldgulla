import 'package:daniel_portal/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CaseStore.cases.clear();
  });

  test('saved cases reload after storage is initialized again', () async {
    await CaseStore.initialize();
    final record = CaseRecord(
      id: CaseStore.nextId(),
      date: 'Nov 6, 2026',
      name: 'Test Resident',
      category: 'Noise Disturbance',
      aiCategory: 'Noise/Nuisance',
      urgency: 'LOW',
      stage: 'Conciliation',
      status: 'IN PROGRESS',
      action: 'Open Case',
      narrative: 'A neighbor plays loud music late at night.',
      trackStep: 2,
      eligible: true,
      recommendedAction: 'Local Barangay Conciliation',
      confidence: 0.84,
    );
    await CaseStore.add(record);

    CaseStore.cases.clear();
    await CaseStore.initialize();

    expect(CaseStore.find(record.id)?.narrative, record.narrative);
    expect(CaseStore.find(record.id)?.status, 'IN PROGRESS');
  });

  test('workflow updates preserve analysis data and persist', () async {
    await CaseStore.initialize();
    final record = CaseRecord(
      id: CaseStore.nextId(),
      date: 'Nov 6, 2026',
      name: 'Test Resident',
      category: 'Noise Disturbance',
      aiCategory: 'Noise/Nuisance',
      urgency: 'LOW',
      stage: 'Conciliation',
      status: 'IN PROGRESS',
      action: 'Open Case',
      narrative: 'A neighbor plays loud music late at night.',
      trackStep: 2,
      eligible: true,
      recommendedAction: 'Local Barangay Conciliation',
      confidence: 0.84,
    );
    await CaseStore.add(record);
    await CaseStore.update(
      record.copyWith(
        stage: 'Hearing Scheduled',
        hearingAt: '2026-11-07T10:00:00.000',
        hearingLocation: 'Barangay Hall',
      ),
    );

    final updated = CaseStore.find(record.id)!;
    expect(updated.stage, 'Hearing Scheduled');
    expect(updated.hearingLocation, 'Barangay Hall');
    expect(updated.aiCategory, 'Noise/Nuisance');
    expect(updated.eligible, isTrue);
  });
}
