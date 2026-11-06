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
  String _statusFilter = 'ALL';

  Widget _stat(String label, int value) {
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
              style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xCCFFFFFF),
                  letterSpacing: 0.3)),
          const SizedBox(height: 5),
          Text('$value',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white)),
          const Text('Saved cases',
              style: TextStyle(fontSize: 9, color: Color(0xB3FFFFFF))),
        ],
      ),
    );
  }

  Widget _cell(int flex, Widget child) => Expanded(
      flex: flex, child: Align(alignment: Alignment.centerLeft, child: child));

  static const _headStyle = TextStyle(
      fontSize: 9.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
      color: AppColors.body);

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
            Expanded(
                flex: 3,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: const Text('ACTIONS', style: _headStyle))),
          ],
        ),
      );

  Widget _row(CaseRecord c) {
    return InkWell(
      onTap: () => go(context, '/officer/complaint', args: c.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border))),
        child: Row(
          children: [
            _cell(
                2,
                Text(c.id,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink))),
            _cell(
                2,
                Text(c.date,
                    style: const TextStyle(
                        fontSize: 10.5, color: AppColors.muted))),
            _cell(
                3,
                Text(c.name,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink))),
            _cell(
              4,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.category,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink)),
                  Text('AI: ${c.aiCategory}',
                      style:
                          const TextStyle(fontSize: 9, color: AppColors.muted)),
                ],
              ),
            ),
            _cell(2, urgencyPill(c.urgency)),
            _cell(
                2,
                Text(c.stage,
                    style: const TextStyle(
                        fontSize: 10.5, color: AppColors.body))),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  onPressed: () =>
                      go(context, '/officer/complaint', args: c.id),
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
      if (_statusFilter != 'ALL' && c.status != _statusFilter) return false;
      if (q.isEmpty) return true;
      return c.id.toLowerCase().contains(q) ||
          c.name.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q) ||
          c.aiCategory.toLowerCase().contains(q);
    }).toList();

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Case Management Dashboard',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.white)),
        SizedBox(height: 6),
        Text('Cases saved in this browser · updates persist after refresh',
            style: TextStyle(fontSize: 10.5, color: Color(0xCCFFFFFF))),
      ],
    );

    final stats = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _stat('Total cases', CaseStore.cases.length),
        _stat('In conciliation',
            CaseStore.cases.where((c) => c.status == 'IN PROGRESS').length),
        _stat('Referred',
            CaseStore.cases.where((c) => c.status == 'REFERRED').length),
      ],
    );

    final banner = Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [titleBlock, const SizedBox(height: 16), stats])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: titleBlock),
                const SizedBox(width: 20),
                Flexible(child: stats)
              ],
            ),
    );

    final statuses = CaseStore.cases.map((c) => c.status).toSet().toList()
      ..sort();
    final toolbar = Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: narrow ? 220 : 300,
          child: TextField(
            style: const TextStyle(fontSize: 12),
            onChanged: (v) => setState(() => _query = v),
            decoration:
                inputDec(hint: 'Search case ID, resident, or category...')
                    .copyWith(
              prefixIcon:
                  const Icon(Icons.search, size: 16, color: AppColors.muted),
              prefixIconConstraints: const BoxConstraints(minWidth: 36),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(3),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _statusFilter,
              style: const TextStyle(fontSize: 11.5, color: AppColors.ink),
              items: [
                for (final status in ['ALL', ...statuses])
                  DropdownMenuItem(
                    value: status,
                    child: Text(status == 'ALL' ? 'All statuses' : status),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _statusFilter = value);
              },
            ),
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
              const Text('Case Records',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink)),
              const SizedBox(height: 3),
              Text(
                  '${rows.length} cases shown · ${CaseStore.cases.length} total',
                  style:
                      const TextStyle(fontSize: 9.5, color: AppColors.muted)),
            ],
          ),
          const Pill(
            'LOCAL STORAGE',
            bg: AppColors.surface,
            fg: AppColors.body,
            fontSize: 9,
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
                      Container(
                          color: const Color(0xFFF7F8FA), child: _headRow()),
                      for (final c in rows) _row(c),
                      if (rows.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              Text(
                                CaseStore.cases.isEmpty
                                    ? 'No complaints have been filed yet.'
                                    : 'No cases match these filters.',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.muted),
                              ),
                              if (CaseStore.cases.isEmpty) ...[
                                const SizedBox(height: 12),
                                AppButton(
                                  'File the first complaint',
                                  onPressed: () => go(context, '/complaint'),
                                ),
                              ],
                            ],
                          ),
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
