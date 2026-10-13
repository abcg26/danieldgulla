import 'package:flutter/material.dart';

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
  late final CaseRecord _case;

  @override
  void initState() {
    super.initState();
    _case = CaseStore.find(widget.caseId) ?? CaseStore.cases.last;
    _notes = TextEditingController(
      text: _case.id == 'KP-2026-004'
          ? 'Summoning both parties for initial Lupon Tagapamayapa hearing on Wednesday morning, Jan 14. PWD considerations will be met with ground floor accessibility room.'
          : '',
    );
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Widget _title(String t) => Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink));

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final a = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first[0] : '';
    final b = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (a + b).toUpperCase();
  }

  Widget _docTile(String title, String sub, String toastMsg) {
    return InkWell(
      onTap: () => toast(context, toastMsg),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 3),
            Text(sub, style: const TextStyle(fontSize: 9.5, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }

  Widget _profile() {
    final c = _case;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _title('Resident Profile'),
              if (c.pwd) const Pill('PWD / Senior Request', bg: Color(0xFFFEF3C7), fg: Color(0xFF92400E), fontSize: 9),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xFFEAF0FB), borderRadius: BorderRadius.circular(3)),
                child: Text(_initials(c.name), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  const SizedBox(height: 2),
                  Text('${c.phone} · ${c.barangay}', style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
                ],
              ),
            ],
          ),
          if (c.accommodation != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(3)),
              child: Row(
                children: [
                  const Icon(Icons.accessible, size: 14, color: Color(0xFF92400E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(c.accommodation!,
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF92400E))),
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
    final c = _case;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 4,
            children: [
              _title('Grievance Narrative'),
              Text('Filed ${c.date} · ${c.filedAt}', style: const TextStyle(fontSize: 10, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 12),
          Text(c.narrative, style: const TextStyle(fontSize: 12, height: 1.6, color: AppColors.body)),
        ],
      ),
    );
  }

  Widget _controls(bool narrow) {
    final tiles = [
      _docTile('Summons', 'Generate summons for both parties', 'Summons generated (prototype).'),
      _docTile('Hearing Notice', 'Schedule first mediation hearing', 'Hearing notice drafted (prototype).'),
      _docTile('Settlement Agreement', 'Draft amicable settlement terms', 'Settlement draft created (prototype).'),
      _docTile('Certificate to File Action', 'Eligible after officer review only', 'CFA is only available after officer review.'),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Lupon Officer Review & KP Document Controls'),
          const SizedBox(height: 14),
          if (narrow)
            Column(children: [for (final t in tiles) Padding(padding: const EdgeInsets.only(bottom: 8), child: SizedBox(width: double.infinity, child: t))])
          else
            Column(
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: tiles[0]), const SizedBox(width: 10), Expanded(child: tiles[1])]),
                const SizedBox(height: 10),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: tiles[2]), const SizedBox(width: 10), Expanded(child: tiles[3])]),
              ],
            ),
          const SizedBox(height: 14),
          const FieldLabel('Officer Review Notes'),
          TextField(
            controller: _notes,
            minLines: 3,
            maxLines: 6,
            style: const TextStyle(fontSize: 11.5),
            decoration: inputDec(hint: 'Add review notes for the Lupon record...'),
          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  onPressed: () => toast(context, '${_case.id} flagged for LGU escalation (prototype).')),
              AppButton('Save Officer Review',
                  outlined: true,
                  fontSize: 11.5,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  onPressed: () => toast(context, 'Officer review saved (prototype).')),
              AppButton('Issue Summons',
                  fontSize: 11.5,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  onPressed: () => toast(context, 'Summons issued for ${_case.id} (prototype).')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _aiRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.body)),
              const Flexible(
                child: Text('Pending Officer Verification',
                    textAlign: TextAlign.right, style: TextStyle(fontSize: 9, color: AppColors.muted)),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink)),
        ],
      ),
    );
  }

  String _titleCase(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  Widget _aside() {
    final c = _case;
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
              _aiRow('Predicted Category', c.aiCategory[0].toUpperCase() + c.aiCategory.substring(1)),
              _aiRow('Suggested Urgency Level', '${_titleCase(c.urgency)} (Barangay Mediation Priority)'),
              _aiRow('KP Jurisdiction Decision', 'Not yet determined (RA 7160, Sec. 408)'),
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
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: AppColors.primary)),
              SizedBox(height: 10),
              Text(
                'Under RA 7160, neighbor disputes, local curfews, boundary trees, and residential noise may fall within Lupon mediation if they meet jurisdictional requirements. A certificate of no amicable settlement may be issued only after officer review confirms the case is within barangay jurisdiction and mediation has been attempted.',
                style: TextStyle(fontSize: 10.5, height: 1.55, color: AppColors.body),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
            const SizedBox(width: 8),
            Text('/ Dispute ${_case.id}', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
        const Pill('AWAITING OFFICER VERIFICATION', bg: Color(0xFFFDE2E2), fg: Color(0xFFB42318), fontSize: 8.5),
      ],
    );

    final main = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_profile(), const SizedBox(height: 14), _narrative(), const SizedBox(height: 14), _controls(narrow)],
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
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [main, const SizedBox(height: 14), _aside()])
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(flex: 7, child: main), const SizedBox(width: 18), Expanded(flex: 4, child: _aside())],
            ),
        ],
      ),
    );
  }
}
