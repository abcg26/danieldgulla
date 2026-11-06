import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ai_service.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

class ComplaintDetailPage extends StatefulWidget {
  final String caseId;
  const ComplaintDetailPage({super.key, required this.caseId});

  @override
  State<ComplaintDetailPage> createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage> {
  late final TextEditingController _notes;
  late CaseRecord? _case;

  @override
  void initState() {
    super.initState();
    _case = CaseStore.find(widget.caseId);
    _notes = TextEditingController(text: _case?.officerNotes ?? '');
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Widget _title(String t) => Text(t,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink));

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final a = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first[0] : '';
    final b = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (a + b).toUpperCase();
  }

  Widget _docTile(String title, String sub, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink)),
            const SizedBox(height: 3),
            Text(sub,
                style: const TextStyle(fontSize: 9.5, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }

  Widget _profile() {
    final c = _case!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _title('Resident Profile'),
              if (c.pwd)
                const Pill('PWD / Senior Request',
                    bg: Color(0xFFFEF3C7), fg: Color(0xFF92400E), fontSize: 9),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: const Color(0xFFEAF0FB),
                    borderRadius: BorderRadius.circular(3)),
                child: Text(_initials(c.name),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink)),
                  const SizedBox(height: 2),
                  Text('${c.phone} · ${c.barangay}',
                      style: const TextStyle(
                          fontSize: 10.5, color: AppColors.muted)),
                ],
              ),
            ],
          ),
          if (c.accommodation != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(3)),
              child: Row(
                children: [
                  const Icon(Icons.accessible,
                      size: 14, color: Color(0xFF92400E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(c.accommodation!,
                        style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF92400E))),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _narrative() {
    final c = _case!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 4,
            children: [
              _title('Grievance Narrative'),
              Text('Filed ${c.date} · ${c.filedAt}',
                  style: const TextStyle(fontSize: 10, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 12),
          Text(c.narrative,
              style: const TextStyle(
                  fontSize: 12, height: 1.6, color: AppColors.body)),
        ],
      ),
    );
  }

  Future<void> _saveCase(CaseRecord updated, String message) async {
    try {
      await CaseStore.update(updated);
    } catch (error) {
      if (mounted) toast(context, 'Could not save this update: $error');
      return;
    }
    if (!mounted) return;
    setState(() => _case = updated);
    toast(context, message);
  }

  String _documentDraft(String title, CaseRecord c) {
    final hearing = c.hearingAt.isEmpty
        ? 'Not scheduled'
        : '${DateTime.parse(c.hearingAt).toLocal()} at ${c.hearingLocation}';
    return '''DRAFT - FOR BARANGAY STAFF REVIEW
$title

Case ID: ${c.id}
Complainant: ${c.name}
Barangay: ${c.barangay}
Category: ${c.category}
AI triage category: ${c.aiCategory}
AI recommendation: ${c.recommendedAction ?? 'Unavailable'}
Hearing: $hearing

Complaint summary:
${c.narrative}

This draft is not an issued legal notice. Complete required details, confirm procedure, and serve through authorized barangay staff.''';
  }

  Future<void> _copyDocument(String title) async {
    final c = _case!;
    try {
      await Clipboard.setData(ClipboardData(text: _documentDraft(title, c)));
    } catch (error) {
      if (mounted) toast(context, 'Could not copy the draft: $error');
      return;
    }
    if (!mounted) return;
    if (title == 'Summons' && !c.summonsDrafted) {
      await _saveCase(
          c.copyWith(summonsDrafted: true), 'Summons draft copied.');
      return;
    }
    toast(context, '$title draft copied to clipboard.');
  }

  Future<void> _scheduleHearing() async {
    final c = _case!;
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 3),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(days: 1))),
    );
    if (time == null || !mounted) return;

    final locationController = TextEditingController(
      text: c.hearingLocation.isEmpty ? c.barangay : c.hearingLocation,
    );
    final location = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hearing location'),
        content: TextField(
          controller: locationController,
          autofocus: true,
          decoration: inputDec(hint: 'Barangay hall or meeting place'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, locationController.text.trim()),
            child: const Text('Save hearing'),
          ),
        ],
      ),
    );
    locationController.dispose();
    if (location == null || location.isEmpty || !mounted) return;

    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    await _saveCase(
      c.copyWith(
        stage: 'Hearing Scheduled',
        status: 'IN PROGRESS',
        trackStep: 2,
        hearingAt: scheduledAt.toIso8601String(),
        hearingLocation: location,
      ),
      'Hearing schedule saved.',
    );
  }

  Future<void> _escalateToReferral() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Refer this case?'),
        content: const Text(
          'This changes the case status to Referred. It does not submit the complaint to another agency.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Mark referred'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _saveCase(
      _case!.copyWith(
        stage: 'Referral',
        status: 'REFERRED',
        action: 'View Referral',
        trackStep: 4,
      ),
      'Case marked as referred.',
    );
  }

  Future<void> _resolveCase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Resolve this case?'),
        content: const Text(
          'This closes the local case record. It does not create or sign a settlement agreement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Mark resolved'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _saveCase(
      _case!.copyWith(
        stage: 'Resolved',
        status: 'RESOLVED',
        action: 'View Case',
        trackStep: 3,
      ),
      'Case marked resolved.',
    );
  }

  Future<void> _saveOfficerNotes() async {
    await _saveCase(
      _case!.copyWith(officerNotes: _notes.text.trim()),
      'Officer notes saved.',
    );
  }

  Future<void> _createSummonsDraft() async {
    await _copyDocument('Summons');
  }

  Future<void> _retryAiAnalysis() async {
    final c = _case!;
    try {
      final result = await AiService.triage(c.narrative);
      final urgency = switch (result.urgency.trim().toLowerCase()) {
        'immediate intervention' || 'immediate' => 'IMMEDIATE',
        'high' => 'HIGH',
        'medium' => 'MEDIUM',
        'low' => 'LOW',
        _ => throw const AiServiceException(
            'The AI service returned an unknown urgency level.'),
      };
      final updated = c.copyWith(
        aiCategory: result.category,
        urgency: urgency,
        eligible: result.eligible,
        exclusion: result.exclusion,
        recommendedAction: result.recommendedAction,
        confidence: result.minConfidence,
        needsReview: result.needsStaffReview,
        ruleReasons: result.ruleReasons,
        stage: result.eligible ? 'Conciliation' : 'Referral',
        status: result.eligible ? 'IN PROGRESS' : 'REFERRED',
        action: result.eligible ? 'Open Case' : 'View Referral',
        trackStep: result.eligible ? 2 : 4,
      );
      await _saveCase(updated, 'AI triage completed and case updated.');
    } on AiServiceException catch (error) {
      if (mounted) toast(context, error.message);
    }
  }

  Widget _controls(bool narrow) {
    final tiles = [
      _docTile(
          'Summons', 'Generate summons for both parties', _createSummonsDraft),
      _docTile(
        'Hearing Notice',
        _case!.hearingAt.isEmpty
            ? 'Schedule a hearing before creating notice'
            : 'Copy notice for scheduled hearing',
        _case!.hearingAt.isEmpty
            ? _scheduleHearing
            : () => _copyDocument('Hearing Notice'),
      ),
      _docTile('Settlement Agreement', 'Draft amicable settlement terms',
          () => _copyDocument('Settlement Agreement')),
      _docTile(
        'CFA Eligibility Checklist',
        'Copy the statutory checklist; this does not issue a certificate',
        () => _copyDocument('CFA Eligibility Checklist'),
      ),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Case Actions & Document Drafts'),
          const SizedBox(height: 14),
          if (narrow)
            Column(children: [
              for (final t in tiles)
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(width: double.infinity, child: t))
            ])
          else
            Column(
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: tiles[0]),
                  const SizedBox(width: 10),
                  Expanded(child: tiles[1])
                ]),
                const SizedBox(height: 10),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: tiles[2]),
                  const SizedBox(width: 10),
                  Expanded(child: tiles[3])
                ]),
              ],
            ),
          const SizedBox(height: 14),
          const FieldLabel('Officer Review Notes'),
          TextField(
            controller: _notes,
            minLines: 3,
            maxLines: 6,
            style: const TextStyle(fontSize: 11.5),
            decoration:
                inputDec(hint: 'Add review notes for the Lupon record...'),
          ),
          if (_case!.eligible == null) ...[
            const SizedBox(height: 12),
            AppButton(
              'Retry AI Analysis',
              outlined: true,
              fontSize: 11.5,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onPressed: _retryAiAnalysis,
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 10,
            children: [
              AppButton('Escalate to LGU',
                  outlined: true,
                  color: AppColors.danger,
                  fontSize: 11.5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  onPressed: _escalateToReferral),
              AppButton('Save Officer Review',
                  outlined: true,
                  fontSize: 11.5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  onPressed: _saveOfficerNotes),
              AppButton(
                  _case!.summonsDrafted
                      ? 'Copy Summons Draft'
                      : 'Create Summons Draft',
                  fontSize: 11.5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  onPressed: _createSummonsDraft),
              if (_case!.status != 'RESOLVED')
                AppButton(
                  'Mark Resolved',
                  outlined: true,
                  fontSize: 11.5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  onPressed: _resolveCase,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _aiRow(String label, String value, {required String note}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 10, color: AppColors.body)),
              Flexible(
                child: Text(note,
                    textAlign: TextAlign.right,
                    style:
                        const TextStyle(fontSize: 9, color: AppColors.muted)),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink)),
        ],
      ),
    );
  }

  String _confidenceNote(CaseRecord c) {
    if (c.confidence == null) return 'Analysis unavailable';
    final percent = (c.confidence! * 100).round();
    return c.needsReview
        ? '$percent% confidence · low confidence'
        : '$percent% model confidence';
  }

  String _jurisdiction(CaseRecord c) {
    if (c.eligible == null) {
      return 'Not analyzed; retry AI analysis';
    }
    if (c.eligible!) {
      return 'Conciliation workflow';
    }
    return 'Referral recommended${c.exclusion == null ? '' : ' (${c.exclusion})'}';
  }

  String _titleCase(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  Widget _aside() {
    final c = _case!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          color: const Color(0xFFEFF3F9),
          borderColor: const Color(0xFFD9E2F0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.memory, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  _title('AI Classification Analysis'),
                ],
              ),
              const SizedBox(height: 16),
              _aiRow(
                'Predicted Category',
                c.aiCategory,
                note: _confidenceNote(c),
              ),
              _aiRow(
                'Suggested Urgency Level',
                '${_titleCase(c.urgency)} (Barangay Mediation Priority)',
                note: _confidenceNote(c),
              ),
              _aiRow(
                'KP Jurisdiction Recommendation',
                _jurisdiction(c),
                note: c.eligible == null
                    ? 'Retry available below'
                    : 'Automated routing',
              ),
              if (c.recommendedAction != null)
                _aiRow(
                  'Recommended Next Step',
                  c.recommendedAction!,
                  note: 'AI suggestion only',
                ),
              for (final reason in c.ruleReasons)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'Rule triggered: $reason',
                    style: const TextStyle(fontSize: 10, color: AppColors.body),
                  ),
                ),
              const Text(
                'Automated triage routes this case using the configured model and rules. Staff may update the case or add notes.',
                style:
                    TextStyle(fontSize: 10, height: 1.5, color: AppColors.body),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          color: const Color(0xFFEFF3F9),
          borderColor: const Color(0xFFD9E2F0),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('KATARUNGANG PAMBARANGAY GUIDE',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: AppColors.primary)),
              SizedBox(height: 10),
              Text(
                'Under RA 7160, neighbor disputes, local curfews, boundary trees, and residential noise may fall within Lupon mediation if they meet jurisdictional requirements. A certificate of no amicable settlement may be issued only after officer review confirms the case is within barangay jurisdiction and mediation has been attempted.',
                style: TextStyle(
                    fontSize: 10.5, height: 1.55, color: AppColors.body),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_case == null) {
      return AdminShell(
        light: true,
        active: 'Complaints',
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title('Case not found'),
              const SizedBox(height: 8),
              const Text(
                  'The case may have been removed or this browser has no saved record.'),
              const SizedBox(height: 12),
              AppButton('Back to cases',
                  onPressed: () => go(context, '/officer')),
            ],
          ),
        ),
      );
    }
    final c = _case!;
    final narrow = isNarrow(context);

    final topBar = Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => go(context, '/officer'),
              child: const Text('← Back to Complaints',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
            const SizedBox(width: 8),
            Text('/ ${c.id}',
                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
        statusPill(c.status),
      ],
    );

    final main = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _profile(),
        const SizedBox(height: 14),
        _narrative(),
        const SizedBox(height: 14),
        _controls(narrow)
      ],
    );

    return AdminShell(
      light: true,
      active: 'Complaints',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          topBar,
          const SizedBox(height: 16),
          if (narrow)
            Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [main, const SizedBox(height: 14), _aside()])
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: main),
                const SizedBox(width: 18),
                Expanded(flex: 4, child: _aside())
              ],
            ),
        ],
      ),
    );
  }
}
