import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CaseRecord {
  static const _notProvided = Object();
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
  final int trackStep;
  final bool pwd;
  final String? accommodation;
  final String phone;
  final String barangay;
  final bool? eligible;
  final String? exclusion;
  final String? recommendedAction;
  final double? confidence;
  final bool needsReview;
  final List<String> ruleReasons;
  final String officerNotes;
  final String hearingAt;
  final String hearingLocation;
  final bool summonsDrafted;

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
    this.phone = '',
    this.barangay = '',
    this.eligible,
    this.exclusion,
    this.recommendedAction,
    this.confidence,
    this.needsReview = false,
    this.ruleReasons = const [],
    this.officerNotes = '',
    this.hearingAt = '',
    this.hearingLocation = '',
    this.summonsDrafted = false,
  });

  CaseRecord copyWith({
    String? aiCategory,
    String? urgency,
    String? stage,
    String? status,
    String? action,
    int? trackStep,
    Object? exclusion = _notProvided,
    Object? recommendedAction = _notProvided,
    double? confidence,
    bool? eligible,
    bool? needsReview,
    List<String>? ruleReasons,
    String? officerNotes,
    String? hearingAt,
    String? hearingLocation,
    bool? summonsDrafted,
  }) {
    return CaseRecord(
      id: id,
      date: date,
      filedAt: filedAt,
      name: name,
      category: category,
      aiCategory: aiCategory ?? this.aiCategory,
      urgency: urgency ?? this.urgency,
      stage: stage ?? this.stage,
      status: status ?? this.status,
      action: action ?? this.action,
      narrative: narrative,
      trackStep: trackStep ?? this.trackStep,
      pwd: pwd,
      accommodation: accommodation,
      phone: phone,
      barangay: barangay,
      eligible: eligible ?? this.eligible,
      exclusion: identical(exclusion, _notProvided)
          ? this.exclusion
          : exclusion as String?,
      recommendedAction: identical(recommendedAction, _notProvided)
          ? this.recommendedAction
          : recommendedAction as String?,
      confidence: confidence ?? this.confidence,
      needsReview: needsReview ?? this.needsReview,
      ruleReasons: ruleReasons ?? this.ruleReasons,
      officerNotes: officerNotes ?? this.officerNotes,
      hearingAt: hearingAt ?? this.hearingAt,
      hearingLocation: hearingLocation ?? this.hearingLocation,
      summonsDrafted: summonsDrafted ?? this.summonsDrafted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'filedAt': filedAt,
        'name': name,
        'category': category,
        'aiCategory': aiCategory,
        'urgency': urgency,
        'stage': stage,
        'status': status,
        'action': action,
        'narrative': narrative,
        'trackStep': trackStep,
        'pwd': pwd,
        'accommodation': accommodation,
        'phone': phone,
        'barangay': barangay,
        'eligible': eligible,
        'exclusion': exclusion,
        'recommendedAction': recommendedAction,
        'confidence': confidence,
        'needsReview': needsReview,
        'ruleReasons': ruleReasons,
        'officerNotes': officerNotes,
        'hearingAt': hearingAt,
        'hearingLocation': hearingLocation,
        'summonsDrafted': summonsDrafted,
      };

  factory CaseRecord.fromJson(Map<String, dynamic> json) {
    String stringValue(String key) {
      final value = json[key];
      if (value is! String) throw FormatException('Invalid case field: $key');
      return value;
    }

    final trackStep = json['trackStep'];
    final ruleReasons = json['ruleReasons'] ?? const <dynamic>[];
    if (trackStep is! int ||
        trackStep < 0 ||
        trackStep > 4 ||
        ruleReasons is! List ||
        ruleReasons.any((reason) => reason is! String)) {
      throw const FormatException('Invalid case progress data.');
    }
    final confidence = json['confidence'];
    if (confidence != null &&
        (confidence is! num || confidence < 0 || confidence > 1)) {
      throw const FormatException('Invalid case confidence.');
    }
    final eligible = json['eligible'];
    if (eligible != null && eligible is! bool) {
      throw const FormatException('Invalid case eligibility.');
    }

    return CaseRecord(
      id: stringValue('id'),
      date: stringValue('date'),
      filedAt: stringValue('filedAt'),
      name: stringValue('name'),
      category: stringValue('category'),
      aiCategory: stringValue('aiCategory'),
      urgency: stringValue('urgency'),
      stage: stringValue('stage'),
      status: stringValue('status'),
      action: stringValue('action'),
      narrative: stringValue('narrative'),
      trackStep: trackStep,
      pwd: json['pwd'] == true,
      accommodation: json['accommodation'] as String?,
      phone: stringValue('phone'),
      barangay: stringValue('barangay'),
      eligible: eligible as bool?,
      exclusion: json['exclusion'] as String?,
      recommendedAction: json['recommendedAction'] as String?,
      confidence: confidence?.toDouble(),
      needsReview: json['needsReview'] == true,
      ruleReasons: List<String>.from(ruleReasons),
      officerNotes: stringValue('officerNotes'),
      hearingAt: stringValue('hearingAt'),
      hearingLocation: stringValue('hearingLocation'),
      summonsDrafted: json['summonsDrafted'] == true,
    );
  }
}

String fmtDate(DateTime d) {
  const m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${m[d.month - 1]} ${d.day}, ${d.year}';
}

class CaseStore {
  static const _storageKey = 'daniel_portal.cases.v1';
  static final List<CaseRecord> cases = [];
  static SharedPreferences? _preferences;

  static Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
    final stored = _preferences!.getString(_storageKey);
    if (stored == null) return;

    final decoded = jsonDecode(stored);
    if (decoded is! List) {
      throw const FormatException('Saved case data must be a list.');
    }
    final restored = <CaseRecord>[];
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
            'Saved case data contains an invalid record.');
      }
      restored.add(CaseRecord.fromJson(item));
    }
    cases
      ..clear()
      ..addAll(restored);
  }

  static Future<void> add(CaseRecord record) async {
    if (find(record.id) != null) {
      throw StateError('A case with ID ${record.id} already exists.');
    }
    cases.insert(0, record);
    try {
      await _persist();
    } catch (_) {
      cases.removeAt(0);
      rethrow;
    }
  }

  static Future<void> update(CaseRecord record) async {
    final index = cases.indexWhere((item) => item.id == record.id);
    if (index < 0) throw StateError('Case ${record.id} was not found.');
    final previous = cases[index];
    cases[index] = record;
    try {
      await _persist();
    } catch (_) {
      cases[index] = previous;
      rethrow;
    }
  }

  static Future<void> _persist() async {
    final preferences = _preferences;
    if (preferences == null) {
      throw StateError('Case storage has not been initialized.');
    }
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(cases.map((record) => record.toJson()).toList()),
    );
    if (!saved) throw StateError('Could not save cases to local storage.');
  }

  static CaseRecord? find(String id) {
    final key = id.trim().toUpperCase();
    for (final record in cases) {
      if (record.id == key) return record;
    }
    return null;
  }

  static String nextId() {
    final year = DateTime.now().year;
    final prefix = 'KP-$year-';
    var largest = 0;
    for (final record in cases) {
      if (!record.id.startsWith(prefix)) continue;
      final sequence = int.tryParse(record.id.substring(prefix.length));
      if (sequence != null && sequence > largest) largest = sequence;
    }
    return '$prefix${(largest + 1).toString().padLeft(3, '0')}';
  }
}
