import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ai_service.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

class TrackPage extends StatefulWidget {
  final String? initialId;
  const TrackPage({super.key, this.initialId});

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  late final TextEditingController _controller;
  CaseRecord? _result;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialId ?? '');
    _result = CaseStore.find(_controller.text);
    _searched = widget.initialId != null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    if (_controller.text.trim().isEmpty) {
      setState(() {
        _result = null;
        _searched = true;
      });
      return;
    }
    setState(() {
      _result = CaseStore.find(_controller.text);
      _searched = true;
    });
  }

  Future<void> _copyCalendarEvent(CaseRecord c) async {
    if (c.hearingAt.isEmpty) return;
    final start = DateTime.parse(c.hearingAt).toUtc();
    final end = start.add(const Duration(hours: 1));
    String icsDate(DateTime date) =>
        date.toIso8601String().replaceAll(RegExp(r'[-:]'), '').split('.').first;
    final event = '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Daniel Portal//Hearing//EN
BEGIN:VEVENT
UID:${c.id}@daniel-portal
DTSTAMP:${icsDate(DateTime.now().toUtc())}Z
DTSTART:${icsDate(start)}Z
DTEND:${icsDate(end)}Z
SUMMARY:Barangay case hearing - ${c.id}
LOCATION:${c.hearingLocation.replaceAll(',', r'\,')}
DESCRIPTION:Case ${c.id} - ${c.category}
END:VEVENT
END:VCALENDAR''';
    try {
      await Clipboard.setData(ClipboardData(text: event));
      if (mounted) {
        toast(
            context, 'Calendar event copied. Paste it into your calendar app.');
      }
    } catch (error) {
      if (mounted) toast(context, 'Could not copy the calendar event: $error');
    }
  }

  Future<void> _copySummonsDraft(CaseRecord c) async {
    final draft = '''DRAFT - FOR BARANGAY STAFF REVIEW
SUMMONS

Case ID: ${c.id}
Complainant: ${c.name}
Barangay: ${c.barangay}
Category: ${c.category}
Hearing: ${c.hearingAt.isEmpty ? 'Not scheduled' : DateTime.parse(c.hearingAt).toLocal()}
Location: ${c.hearingLocation}

Complaint summary:
${c.narrative}

This draft is not an issued legal notice. Complete required details, confirm procedure, and serve through authorized barangay staff.''';
    try {
      await Clipboard.setData(ClipboardData(text: draft));
      if (!c.summonsDrafted) {
        await CaseStore.update(c.copyWith(summonsDrafted: true));
      }
      if (mounted) toast(context, 'Summons draft copied to clipboard.');
    } catch (error) {
      if (mounted) toast(context, 'Could not create the summons draft: $error');
    }
  }

  Future<void> _retryAiAnalysis(CaseRecord c) async {
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
      await CaseStore.update(updated);
      if (mounted) {
        setState(() => _result = updated);
        toast(context, 'AI triage completed and case updated.');
      }
    } on AiServiceException catch (error) {
      if (mounted) toast(context, error.message);
    } catch (error) {
      if (mounted) toast(context, 'Could not save AI results: $error');
    }
  }

  static const _steps = ['Filed', 'Under Review', 'Mediation Set', 'Resolved'];

  Widget _node(int i, int current) {
    const size = 18.0;
    if (i < current) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
        child: const Icon(Icons.check, size: 12, color: AppColors.white),
      );
    }
    if (i == current) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle)),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(2)),
      child: Text('${i + 1}',
          style: const TextStyle(
              fontSize: 9,
              color: AppColors.muted,
              fontWeight: FontWeight.w700)),
    );
  }

  Widget _stepper(int current) {
    return Row(
      children: [
        for (int i = 0; i < _steps.length; i++)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == 0
                            ? const Color(0x00000000)
                            : (i <= current
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                    ),
                    _node(i, current),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == _steps.length - 1
                            ? const Color(0x00000000)
                            : (i < current
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_steps[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight:
                            i <= current ? FontWeight.w700 : FontWeight.w400,
                        color: i == current
                            ? AppColors.primary
                            : (i < current ? AppColors.ink : AppColors.muted))),
              ],
            ),
          ),
      ],
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: AppColors.body));

  Widget _resultCard(CaseRecord c, bool narrow) {
    final referred = c.status == 'REFERRED';
    final done = c.status == 'RESOLVED';
    return AppCard(
      padding: EdgeInsets.all(narrow ? 18 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.start,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Case Ref: ${c.id}',
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink)),
                  const SizedBox(height: 4),
                  Text('Filed on ${c.date} at ${c.filedAt} PHT',
                      style: const TextStyle(
                          fontSize: 10.5, color: AppColors.muted)),
                ],
              ),
              statusPill(c.status),
              Pill(c.category.toUpperCase(),
                  bg: const Color(0xFFEAF0FB), fg: AppColors.primary),
            ],
          ),
          const SizedBox(height: 22),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 18),
          _label('LUPON JURISDICTIONAL PROGRESS'),
          const SizedBox(height: 18),
          if (referred)
            const Text(
              'This case was routed to the referral pathway. Contact the relevant agency using your local barangay directory.',
              style:
                  TextStyle(fontSize: 11, height: 1.5, color: AppColors.body),
            )
          else
            _stepper(c.trackStep.clamp(0, 3)),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          _label('HEARING SCHEDULE'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(3),
            ),
            child: referred
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Referral recommended',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary)),
                      SizedBox(height: 6),
                      Text(
                          'The app records the referral recommendation but does not submit the complaint to another agency.',
                          style: TextStyle(
                              fontSize: 11,
                              height: 1.5,
                              color: AppColors.body)),
                    ],
                  )
                : done
                    ? const Text(
                        'This case is marked resolved.',
                        style: TextStyle(fontSize: 12, color: AppColors.body),
                      )
                    : c.hearingAt.isEmpty
                        ? const Text(
                            'No hearing has been scheduled yet.',
                            style:
                                TextStyle(fontSize: 12, color: AppColors.body),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Scheduled hearing',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary)),
                              const SizedBox(height: 4),
                              Text(
                                '${DateTime.parse(c.hearingAt).toLocal()} · ${c.hearingLocation}',
                                style: const TextStyle(
                                    fontSize: 10.5, color: AppColors.body),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  AppButton('Copy Summons Draft',
                                      fontSize: 10.5,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 11),
                                      onPressed: () => _copySummonsDraft(c)),
                                  AppButton('Copy calendar event',
                                      outlined: true,
                                      fontSize: 10.5,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 11),
                                      onPressed: () => _copyCalendarEvent(c)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('What to bring',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.ink)),
                                    SizedBox(height: 4),
                                    Text(
                                      'Bring your summons/notice, a valid government-issued photo ID (e.g. PhilID, driver\'s license or passport), copies of your complaint and relevant evidence.',
                                      style: TextStyle(
                                          fontSize: 10.5,
                                          height: 1.5,
                                          color: AppColors.body),
                                    ),
                                  ],
                                ),
                              ),
                              if (c.eligible == null &&
                                  c.status != 'REFERRED') ...[
                                const SizedBox(height: 12),
                                AppButton(
                                  'Retry AI Analysis',
                                  outlined: true,
                                  onPressed: () => _retryAiAnalysis(c),
                                ),
                              ],
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);

    final searchRow = narrow
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                  controller: _controller,
                  style: const TextStyle(fontSize: 12),
                  decoration: inputDec(),
                  onSubmitted: (_) => _search()),
              const SizedBox(height: 10),
              AppButton('Track Status', onPressed: _search),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 12),
                    decoration: inputDec(),
                    onSubmitted: (_) => _search()),
              ),
              const SizedBox(width: 12),
              AppButton('Track Status',
                  padding:
                      const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                  onPressed: _search),
            ],
          );

    return PublicScaffold(
      active: '/track',
      background: AppColors.page,
      footerBlurb:
          'D.A.N.I.E.L.D.G.U.L.L.A ensures peace, order, and structured dispute management under the Barangay Justice System of the Philippines. Powered by certified local legal audits.',
      child: Boxed(
        maxWidth: 740,
        padding:
            EdgeInsets.symmetric(horizontal: narrow ? 14 : 24, vertical: 44),
        child: Column(
          children: [
            const Text('CASE STATUS LOOKUP',
                style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppColors.primary)),
            const SizedBox(height: 8),
            Text('Track Your Complaint',
                style: TextStyle(
                    fontSize: narrow ? 26 : 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink)),
            const SizedBox(height: 10),
            const Text(
              'Enter your transaction Case ID to instantly audit legal jurisdiction parameters, check Lupon scheduling records, and see active mediation timelines.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11.5, height: 1.55, color: AppColors.body),
            ),
            const SizedBox(height: 28),
            AppCard(
              padding: EdgeInsets.all(narrow ? 16 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel('Enter your Case ID (e.g. KP-2026-004)'),
                  searchRow,
                ],
              ),
            ),
            const SizedBox(height: 22),
            if (_result != null)
              _resultCard(_result!, narrow)
            else if (_searched)
              AppCard(
                padding: const EdgeInsets.all(24),
                child: const Row(
                  children: [
                    Icon(Icons.search_off, color: AppColors.muted),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                          'No record found for that Case ID. Check the number on your acknowledgement and try again.',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.body)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
