class CaseRecord {
  final String id;
  final String date;
  final String filedAt;
  final String name;
  final String category;
  final String aiCategory;
  final String urgency;
  final String stage;
  final String status;
  final String action;
  final String narrative;
  final int trackStep; // 0 Filed, 1 Under Review, 2 Mediation Set, 3 Resolved, 4 = all done
  final bool pwd;
  final String? accommodation;
  final String phone;
  final String barangay;

  const CaseRecord({
    required this.id,
    required this.date,
    this.filedAt = '09:14 AM',
    required this.name,
    required this.category,
    required this.aiCategory,
    required this.urgency,
    required this.stage,
    required this.status,
    required this.action,
    required this.narrative,
    required this.trackStep,
    this.pwd = false,
    this.accommodation,
    this.phone = '+63 917 123 4567',
    this.barangay = 'Brgy. San Lorenzo',
  });
}

String fmtDate(DateTime d) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${m[d.month - 1]} ${d.day}, ${d.year}';
}

class CaseStore {
  static final List<CaseRecord> cases = [
    const CaseRecord(
      id: 'KP-2026-004', date: 'Jan 12, 2026', filedAt: '10:14 AM', name: 'Estrella Lopez',
      category: 'Noise (Videoke)', aiCategory: 'Noise disturbance', urgency: 'HIGH',
      stage: 'Mediation', status: 'NEW', action: 'Issue Summons', trackStep: 2,
      pwd: true, accommodation: 'Household accommodation requested for elderly grandmother.',
      phone: '+63 918 765 4321',
      narrative:
          'Our neighbor continuously hosts noisy videoke sessions starting at 11 PM onwards, extending past barangay curfew hours. We tried approaching them peacefully last weekend, but it resulted in a verbal altercation. This is severely disrupting the rest and health of our elderly grandmother who requires quiet rest.',
    ),
    const CaseRecord(
      id: 'KP-2026-003', date: 'Jan 11, 2026', name: 'Ricardo Santos', category: 'Property Boundary',
      aiCategory: 'Land dispute', urgency: 'MEDIUM', stage: 'Conciliation', status: 'UNDER REVIEW',
      action: 'Schedule Conciliation', trackStep: 1,
      narrative: 'The adjoining lot owner moved the boundary marker about half a meter into my property during recent fence repairs.',
    ),
    const CaseRecord(
      id: 'KP-2026-002', date: 'Jan 09, 2026', name: 'Amelia Cruz', category: 'Neighbor Dispute',
      aiCategory: 'Interpersonal conflict', urgency: 'LOW', stage: 'Conciliation', status: 'RESOLVED',
      action: 'View Settlement', trackStep: 4,
      narrative: 'Repeated verbal disagreements with a neighbor over shared hallway use and cleanliness.',
    ),
    const CaseRecord(
      id: 'KP-2026-001', date: 'Jan 08, 2026', name: 'Roberto Diaz', category: 'Infrastructure Damage',
      aiCategory: 'Public impact', urgency: 'MEDIUM', stage: 'CFA Issued', status: 'ESCALATED',
      action: 'View CFA', trackStep: 4,
      narrative: "A neighbor's construction vehicle damaged the shared access road and the drainage cover.",
    ),
    const CaseRecord(
      id: 'KP-2026-005', date: 'Jan 07, 2026', name: 'Maya Reyes', category: 'Water Supply Dispute',
      aiCategory: 'Utility access', urgency: 'LOW', stage: 'Mediation', status: 'NEW',
      action: 'Issue Summons', trackStep: 1,
      narrative: 'A neighbor connected a secondary line to our water meter without consent, reducing our household supply.',
    ),
    const CaseRecord(
      id: 'KP-2026-006', date: 'Jan 06, 2026', name: 'Leo Marquez', category: 'Fence Encroachment',
      aiCategory: 'Property boundary', urgency: 'MEDIUM', stage: 'Conciliation', status: 'UNDER REVIEW',
      action: 'Schedule Conciliation', trackStep: 1,
      narrative: 'A newly built concrete fence extends beyond the agreed property line and blocks my side gate.',
    ),
    const CaseRecord(
      id: 'KP-2026-007', date: 'Jan 05, 2026', name: 'Sofia Tan', category: 'Pet Disturbance',
      aiCategory: 'Animal nuisance', urgency: 'LOW', stage: 'Mediation', status: 'RESOLVED',
      action: 'View Settlement', trackStep: 4,
      narrative: "Neighbor's dogs bark through the night and roam unleashed in the common area.",
    ),
    const CaseRecord(
      id: 'KP-2026-008', date: 'Jan 04, 2026', name: 'Carlos Rivera', category: 'Drainage Obstruction',
      aiCategory: 'Public works', urgency: 'MEDIUM', stage: 'CFA Issued', status: 'ESCALATED',
      action: 'View CFA', trackStep: 4,
      narrative: 'Debris from a nearby lot is blocking the shared drainage canal, causing flooding during rain.',
    ),
    const CaseRecord(
      id: 'KP-2026-009', date: 'Jan 03, 2026', name: 'Nina Gomez', category: 'Shared Wall Damage',
      aiCategory: 'Property damage', urgency: 'HIGH', stage: 'Arbitration', status: 'IN PROGRESS',
      action: 'Schedule Arbitration', trackStep: 2,
      narrative: 'Renovation work next door has cracked the shared wall and the repair cost remains unsettled.',
    ),
    const CaseRecord(
      id: 'KP-2026-010', date: 'Jan 02, 2026', name: 'Mark Santos', category: 'Construction Noise',
      aiCategory: 'Noise disturbance', urgency: 'LOW', stage: 'Conciliation', status: 'RESOLVED',
      action: 'View Settlement', trackStep: 4,
      narrative: 'Construction work started before permitted hours on multiple weekdays.',
    ),
  ];

  static CaseRecord? find(String id) {
    final key = id.trim().toUpperCase();
    for (final c in cases) {
      if (c.id == key) return c;
    }
    return null;
  }

  static String nextId() => 'KP-2026-${(cases.length + 1).toString().padLeft(3, '0')}';
}
