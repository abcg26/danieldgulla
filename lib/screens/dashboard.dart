import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _query = '';

  Widget _stat(String label, String value) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x1FFFFFFF),
        border: Border.all(color: const Color(0x33FFFFFF)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xCCFFFFFF), letterSpacing: 0.3)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.white)),
          const Text('Sample data', style: TextStyle(fontSize: 9, color: Color(0xB3FFFFFF))),
        ],
      ),
    );
  }

  Widget _cell(int flex, Widget child) => Expanded(flex: flex, child: Align(alignment: Alignment.centerLeft, child: child));

  static const _headStyle = TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: AppColors.body);

  Widget _headRow() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _cell(2, const Text('CASE ID', style: _headStyle)),
            _cell(2, const Text('DATE FILED', style: _headStyle)),
            _cell(3, const Text('RESIDENT NAME', style: _headStyle)),
            _cell(4, const Text('CATEGORY', style: _headStyle)),
            _cell(2, const Text('URGENCY', style: _headStyle)),
            _cell(2, const Text('KP STAGE', style: _headStyle)),
            _cell(3, const Text('STATUS', style: _headStyle)),
            Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: const Text('ACTIONS', style: _headStyle))),
          ],
        ),
      );

  Widget _row(CaseRecord c) {
    return InkWell(
      onTap: () => go(context, '/officer/complaint', args: c.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
        child: Row(
          children: [
            _cell(2, Text(c.id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ink))),
            _cell(2, Text(c.date, style: const TextStyle(fontSize: 10.5, color: AppColors.muted))),
            _cell(3, Text(c.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ink))),
            _cell(
              4,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink)),
                  Text('AI: ${c.aiCategory}', style: const TextStyle(fontSize: 9, color: AppColors.muted)),
                ],
              ),
            ),
            _cell(2, urgencyPill(c.urgency)),
            _cell(2, Text(c.stage, style: const TextStyle(fontSize: 10.5, color: AppColors.body))),
            _cell(3, statusPill(c.status)),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  c.action,
                  outlined: true,
                  color: AppColors.ink,
                  fontSize: 10.5,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  onPressed: () => toast(context, '${c.action} for ${c.id} (prototype).'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);
    final q = _query.trim().toLowerCase();
    final rows = CaseStore.cases.where((c) {
      if (q.isEmpty) return true;
      return c.id.toLowerCase().contains(q) ||
          c.name.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q) ||
          c.aiCategory.toLowerCase().contains(q);
    }).toList();

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Lupon Tagapamayapa Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.white)),
        SizedBox(height: 6),
        Text('Brgy. San Lorenzo · Certified Local Legal Audits Portal · Illustrative operational counters',
            style: TextStyle(fontSize: 10.5, color: Color(0xCCFFFFFF))),
      ],
    );

    final stats = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _stat('Approaching 15-day limit', '12 cases'),
        _stat('Pending Pangkat Constitution', '7 cases'),
        _stat('CFA issued this month', '18 cases'),
      ],
    );

    final banner = Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
      child: narrow
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [titleBlock, const SizedBox(height: 16), stats])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(child: titleBlock), const SizedBox(width: 20), Flexible(child: stats)],
            ),
    );

    final toolbar = Row(
      children: [
        SizedBox(
          width: narrow ? 220 : 300,
          child: TextField(
            style: const TextStyle(fontSize: 12),
            onChanged: (v) => setState(() => _query = v),
            decoration: inputDec(hint: 'Search case ID, resident, or category...').copyWith(
              prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.muted),
              prefixIconConstraints: const BoxConstraints(minWidth: 36),
            ),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: () => toast(context, 'Filters are not available in this prototype.'),
          icon: const Icon(Icons.filter_alt_outlined, size: 14),
          label: const Text('Filters'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            backgroundColor: AppColors.white,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          ),
        ),
      ],
    );

    final tableHeader = Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 8,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Active Grievances & KP Process Tally',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 3),
              Text('Illustrative operational data · ${rows.length} cases shown',
                  style: const TextStyle(fontSize: 9.5, color: AppColors.muted)),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Pill('Sample data', bg: AppColors.surface, fg: AppColors.body, fontSize: 9),
              SizedBox(width: 10),
              Icon(Icons.refresh, size: 13, color: AppColors.body),
              SizedBox(width: 4),
              Text('Auto-update live', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.body)),
            ],
          ),
        ],
      ),
    );

    final table = AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tableHeader,
          LayoutBuilder(
            builder: (context, constraints) {
              final w = math.max(constraints.maxWidth, 1000.0);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: w,
                  child: Column(
                    children: [
                      Container(color: const Color(0xFFF7F8FA), child: _headRow()),
                      for (final c in rows) _row(c),
                      if (rows.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(28),
                          child: Text('No cases match your search.', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );

    return AdminShell(
      active: 'Dashboard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          banner,
          const SizedBox(height: 16),
          Align(alignment: Alignment.centerLeft, child: toolbar),
          const SizedBox(height: 14),
          table,
        ],
      ),
    );
  }
}
