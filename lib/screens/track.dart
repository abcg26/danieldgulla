import 'package:flutter/material.dart';

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
    _controller = TextEditingController(text: widget.initialId ?? 'KP-2026-004');
    _result = CaseStore.find(_controller.text);
    _searched = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    setState(() {
      _result = CaseStore.find(_controller.text);
      _searched = true;
    });
  }

  static const _steps = ['Filed', 'Under Review', 'Mediation Set', 'Resolved'];

  Widget _node(int i, int current) {
    const size = 18.0;
    if (i < current) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
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
        child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
      child: Text('${i + 1}', style: const TextStyle(fontSize: 9, color: AppColors.muted, fontWeight: FontWeight.w700)),
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
                        color: i == 0 ? const Color(0x00000000) : (i <= current ? AppColors.primary : AppColors.border),
                      ),
                    ),
                    _node(i, current),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == _steps.length - 1 ? const Color(0x00000000) : (i < current ? AppColors.primary : AppColors.border),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_steps[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: i <= current ? FontWeight.w700 : FontWeight.w400,
                        color: i == current ? AppColors.primary : (i < current ? AppColors.ink : AppColors.muted))),
              ],
            ),
          ),
      ],
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.body));

  Widget _resultCard(CaseRecord c, bool narrow) {
    final done = c.trackStep >= 4;
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
                  Text('Case Ref: ${c.id}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  const SizedBox(height: 4),
                  Text('Filed on ${c.date} at ${c.filedAt} PHT', style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
                ],
              ),
              Pill(c.category.toUpperCase(), bg: const Color(0xFFEAF0FB), fg: AppColors.primary),
            ],
          ),
          const SizedBox(height: 22),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 18),
          _label('LUPON JURISDICTIONAL PROGRESS'),
          const SizedBox(height: 18),
          _stepper(c.trackStep),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          _label('ASSIGNED CONCILIATOR'),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Officer J. Cruz', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(width: 10),
              AppButton('Contact Officer',
                  fontSize: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  onPressed: () => toast(context, 'Contact request sent to Officer J. Cruz (prototype).')),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Official Barangay Conciliation Secretary', style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
          const SizedBox(height: 18),
          _label('NEXT SCHEDULED ACTION'),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(3),
            ),
            child: done
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No further hearings scheduled',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      SizedBox(height: 6),
                      Text('This case has been closed or elevated. Contact the Lupon Secretary for copies of the settlement or certificate.',
                          style: TextStyle(fontSize: 11, height: 1.5, color: AppColors.body)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Preliminary Hearing',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      const SizedBox(height: 4),
                      const Text('Wednesday, Jan 14, 2026 at 10:00 AM · Lupon Session Hall',
                          style: TextStyle(fontSize: 10.5, color: AppColors.body)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          AppButton('Download Summons PDF',
                              fontSize: 10.5,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                              onPressed: () => toast(context, 'PDF download is not available in this prototype.')),
                          AppButton('Add Hearing to Calendar',
                              outlined: true,
                              fontSize: 10.5,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                              onPressed: () => toast(context, 'Calendar export is not available in this prototype.')),
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
                            Text('What to bring', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ink)),
                            SizedBox(height: 4),
                            Text(
                              'Bring your summons/notice, a valid government-issued photo ID (e.g. PhilID, driver\'s license or passport), copies of your complaint and relevant evidence.',
                              style: TextStyle(fontSize: 10.5, height: 1.5, color: AppColors.body),
                            ),
                          ],
                        ),
                      ),
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
              TextField(controller: _controller, style: const TextStyle(fontSize: 12), decoration: inputDec(), onSubmitted: (_) => _search()),
              const SizedBox(height: 10),
              AppButton('Track Status', onPressed: _search),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: TextField(
                    controller: _controller, style: const TextStyle(fontSize: 12), decoration: inputDec(), onSubmitted: (_) => _search()),
              ),
              const SizedBox(width: 12),
              AppButton('Track Status', padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16), onPressed: _search),
            ],
          );

    return PublicScaffold(
      active: '/track',
      background: AppColors.page,
      footerBlurb:
          'D.A.N.I.E.L.D.G.U.L.L.A ensures peace, order, and structured dispute management under the Barangay Justice System of the Philippines. Powered by certified local legal audits.',
      child: Boxed(
        maxWidth: 740,
        padding: EdgeInsets.symmetric(horizontal: narrow ? 14 : 24, vertical: 44),
        child: Column(
          children: [
            const Text('REAL-TIME AUDIT & VERIFICATION',
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.primary)),
            const SizedBox(height: 8),
            Text('Track Your Complaint',
                style: TextStyle(fontSize: narrow ? 26 : 32, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 10),
            const Text(
              'Enter your transaction Case ID to instantly audit legal jurisdiction parameters, check Lupon scheduling records, and see active mediation timelines.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, height: 1.55, color: AppColors.body),
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
                      child: Text('No record found for that Case ID. Check the number on your acknowledgement and try again.',
                          style: TextStyle(fontSize: 12, color: AppColors.body)),
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
