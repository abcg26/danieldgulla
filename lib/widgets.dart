import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'theme.dart';

bool isNarrow(BuildContext c) => MediaQuery.of(c).size.width < 860;

void go(BuildContext c, String route, {Object? args}) {
  Navigator.of(c).pushReplacementNamed(route, arguments: args);
}

void toast(BuildContext c, String message) {
  ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(message)));
}

const List<String> _serifFallback = ['Times New Roman', 'Georgia', 'serif'];

// ---------------------------------------------------------------- layout

class Boxed extends StatelessWidget {
  final double maxWidth;
  final EdgeInsets padding;
  final Widget child;
  const Boxed({
    super.key,
    this.maxWidth = 1200,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = AppColors.white,
    this.borderColor = AppColors.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final double fontSize;
  const Pill(this.text, {super.key, required this.bg, required this.fg, this.fontSize = 9.5});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(3)),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: fontSize, fontWeight: FontWeight.w700, letterSpacing: 0.3),
      ),
    );
  }
}

Widget urgencyPill(String u) {
  switch (u) {
    case 'HIGH':
      return const Pill('HIGH', bg: Color(0xFFFDE2E2), fg: Color(0xFFB42318));
    case 'MEDIUM':
      return const Pill('MEDIUM', bg: Color(0xFFFEF3C7), fg: Color(0xFF92400E));
    default:
      return const Pill('LOW', bg: Color(0xFFDCFCE7), fg: Color(0xFF166534));
  }
}

Widget statusPill(String s) {
  switch (s) {
    case 'RESOLVED':
      return const Pill('RESOLVED', bg: Color(0xFFDCFCE7), fg: Color(0xFF166534));
    case 'UNDER REVIEW':
      return const Pill('UNDER REVIEW', bg: Color(0xFFFEF3C7), fg: Color(0xFF92400E));
    case 'IN PROGRESS':
      return const Pill('IN PROGRESS', bg: Color(0xFFFDE2E2), fg: Color(0xFFB42318));
    case 'ESCALATED':
      return const Pill('ESCALATED', bg: Color(0xFFFFE4E6), fg: Color(0xFFBE123C));
    default:
      return const Pill('NEW', bg: Color(0xFFFDE2E2), fg: Color(0xFFB42318));
  }
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final Color color;
  final EdgeInsets padding;
  final double fontSize;
  const AppButton(
    this.label, {
    super.key,
    this.onPressed,
    this.outlined = false,
    this.color = AppColors.primary,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(2));
    final text = TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700);
    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: AppColors.white,
          side: BorderSide(color: color),
          shape: shape,
          padding: padding,
          textStyle: text,
        ),
        child: Text(label),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: shape,
        padding: padding,
        textStyle: text,
      ),
      child: Text(label),
    );
  }
}

InputDecoration inputDec({String? hint}) {
  OutlineInputBorder b(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide(color: c),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
    isDense: true,
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: b(AppColors.border),
    enabledBorder: b(AppColors.border),
    focusedBorder: b(AppColors.primary),
    errorBorder: b(AppColors.danger),
    focusedErrorBorder: b(AppColors.danger),
    errorStyle: const TextStyle(fontSize: 10),
  );
}

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)),
      );
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  DashedRectPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4)));
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, math.min(d + 5, metric.length)), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) => oldDelegate.color != color;
}

// ---------------------------------------------------------------- public chrome

class BrandLogo extends StatelessWidget {
  final String subtitle;
  final bool serif;
  final double titleSize;
  const BrandLogo({super.key, required this.subtitle, this.serif = false, this.titleSize = 14});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => go(context, '/'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
            child: const Icon(Icons.balance, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'D.A.N.I.E.L.D.G.U.L.L.A.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: titleSize,
                    fontFamily: serif ? 'Georgia' : null,
                    fontFamilyFallback: serif ? _serifFallback : null,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.white, fontSize: 8.5, fontWeight: FontWeight.w600, letterSpacing: 0.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PublicHeader extends StatelessWidget {
  final String active;
  final String subtitle;
  final bool serif;
  const PublicHeader({super.key, required this.active, required this.subtitle, this.serif = false});

  static const List<List<String>> links = [
    ['Home', '/'],
    ['File a Complaint', '/complaint'],
    ['Track Complaint', '/track'],
    ['About', '/about'],
  ];

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.symmetric(horizontal: narrow ? 12 : 32, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: BrandLogo(subtitle: subtitle, serif: serif)),
          if (narrow)
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: AppColors.white),
              onSelected: (r) => go(context, r),
              itemBuilder: (_) => [
                for (final l in links) PopupMenuItem<String>(value: l[1], child: Text(l[0])),
                const PopupMenuItem<String>(value: '/officer', child: Text('Officer Portal')),
              ],
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final l in links) _NavLink(label: l[0], route: l[1], active: l[1] == active),
                const SizedBox(width: 14),
                InkWell(
                  onTap: () => go(context, '/officer'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(2)),
                    child: const Text('Officer Portal',
                        style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final String route;
  final bool active;
  const _NavLink({required this.label, required this.route, required this.active});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => go(context, route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    color: AppColors.white, fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
            const SizedBox(height: 3),
            Container(height: 2, width: 18, color: active ? AppColors.white : const Color(0x00FFFFFF)),
          ],
        ),
      ),
    );
  }
}

class PublicFooter extends StatelessWidget {
  final bool light;
  final String? blurb;
  const PublicFooter({super.key, this.light = false, this.blurb});

  Widget _col(String title, List<String> items, Color titleColor, Color linkColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: TextStyle(color: titleColor, fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        for (final i in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(i, style: TextStyle(color: linkColor, fontSize: 11)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);
    final fg = light ? AppColors.ink : AppColors.white;
    final link = light ? AppColors.primary : AppColors.white;

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (light) ...[
          const Text('D.A.N.I.E.L.D.G.U.L.L.A',
              style: TextStyle(color: AppColors.ink, fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('BARANGAY TRIAGE SYSTEM',
              style: TextStyle(color: AppColors.muted, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
        ] else ...[
          const BrandLogo(subtitle: 'BARANGAY TRIAGE SYSTEM', serif: true, titleSize: 15),
          if (blurb != null) ...[
            const SizedBox(height: 14),
            Text(blurb!, style: const TextStyle(color: AppColors.white, fontSize: 11, height: 1.55)),
          ],
        ],
      ],
    );

    final cols = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _col('RESOURCES', ['Filing Guide', 'LGU Referrals', 'Barangay Law'], fg, link),
        const SizedBox(width: 48),
        _col('GOVERNMENT LINKS', ['DILG Portal', 'Supreme Court (KP)', 'Official Gazette'], fg, link),
      ],
    );

    return Container(
      color: light ? AppColors.white : AppColors.primary,
      padding: EdgeInsets.fromLTRB(narrow ? 20 : 40, 36, narrow ? 20 : 40, 24),
      child: Boxed(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (narrow)
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [left, const SizedBox(height: 24), cols])
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 380), child: left)),
                  cols,
                ],
              ),
            const SizedBox(height: 28),
            Divider(height: 1, color: light ? AppColors.border : const Color(0x66FFFFFF)),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 8,
              children: [
                Text('© 2026 Republic of the Philippines. All rights reserved.',
                    style: TextStyle(color: light ? AppColors.muted : AppColors.white, fontSize: 10)),
                Text('Privacy Policy · Accessibility Statement', style: TextStyle(color: link, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PublicScaffold extends StatelessWidget {
  final String active;
  final String subtitle;
  final bool serifLogo;
  final bool footerLight;
  final String? footerBlurb;
  final Color background;
  final Widget child;
  const PublicScaffold({
    super.key,
    required this.active,
    required this.child,
    this.subtitle = 'BARANGAY TRIAGE SYSTEM',
    this.serifLogo = false,
    this.footerLight = false,
    this.footerBlurb,
    this.background = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PublicHeader(active: active, subtitle: subtitle, serif: serifLogo),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: math.max(0.0, h - 330)),
              child: child,
            ),
            PublicFooter(light: footerLight, blurb: footerBlurb),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- officer chrome

class AdminShell extends StatelessWidget {
  final bool light;
  final String active;
  final Widget child;
  const AdminShell({super.key, required this.child, this.light = false, this.active = 'Dashboard'});

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);
    final sidebar = AdminSidebar(light: light, active: active);
    if (narrow) {
      return Scaffold(
        backgroundColor: AppColors.page,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          title: const Text('Lupon Tagapamayapa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        drawer: Drawer(width: 260, child: sidebar),
        body: SingleChildScrollView(padding: const EdgeInsets.all(14), child: child),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.page,
      body: Row(
        children: [
          SizedBox(width: 240, child: sidebar),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: child),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideItem {
  final String label;
  final IconData icon;
  final String? route;
  const _SideItem(this.label, this.icon, [this.route]);
}

class AdminSidebar extends StatelessWidget {
  final bool light;
  final String active;
  const AdminSidebar({super.key, required this.light, required this.active});

  @override
  Widget build(BuildContext context) {
    final bg = light ? AppColors.sidebarLight : AppColors.primary;
    final fg = light ? AppColors.body : AppColors.white;

    Widget item(_SideItem i) {
      final isActive = i.label == active;
      final activeBg = light ? AppColors.white : const Color(0x26FFFFFF);
      final activeFg = light ? AppColors.primary : AppColors.white;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: InkWell(
          onTap: () {
            if (i.route != null) {
              go(context, i.route!);
            } else {
              toast(context, '${i.label} is not part of this prototype.');
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? activeBg : const Color(0x00000000),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: isActive && !light ? const Color(0x55FFFFFF) : const Color(0x00000000)),
              boxShadow: isActive && light
                  ? const [BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1))]
                  : null,
            ),
            child: Row(
              children: [
                Icon(i.icon, size: 16, color: isActive ? activeFg : fg),
                const SizedBox(width: 10),
                Text(i.label,
                    style: TextStyle(
                        fontSize: 12, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? activeFg : fg)),
              ],
            ),
          ),
        ),
      );
    }

    Widget section(String title, List<_SideItem> items) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
              child: Text(title,
                  style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: light ? AppColors.muted : const Color(0xB3FFFFFF))),
            ),
            for (final i in items) item(i),
          ],
        );

    final header = light
        ? Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(3)),
                child: const Icon(Icons.shield_outlined, size: 16, color: AppColors.white),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('D.A.N.I.E.L.D.G.U.L.L.A',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    Text('BARANGAY TRIAGE SYSTEM', style: TextStyle(fontSize: 7.5, color: AppColors.muted, letterSpacing: 0.4)),
                  ],
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0x99FFFFFF)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.balance, size: 18, color: AppColors.white),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lupon Tagapamayapa',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.white)),
                        Text('BRGY. SAN LORENZO · KP PORTAL',
                            style: TextStyle(fontSize: 8, color: Color(0xCCFFFFFF), letterSpacing: 0.3)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Officer J. Cruz · Lupon Secretary', style: TextStyle(fontSize: 10, color: Color(0xCCFFFFFF))),
            ],
          );

    final List<Widget> nav = light
        ? [
            const SizedBox(height: 18),
            item(const _SideItem('Dashboard', Icons.grid_view, '/officer')),
            item(const _SideItem('Complaints', Icons.description_outlined, '/officer/complaint')),
            item(const _SideItem('Reports', Icons.bar_chart)),
            item(const _SideItem('Settings', Icons.settings_outlined)),
          ]
        : [
            section('DOCKETS AND CASES', const [
              _SideItem('Dashboard', Icons.grid_view, '/officer'),
              _SideItem('Complaints', Icons.description_outlined, '/officer'),
              _SideItem('Active Dockets', Icons.folder_open_outlined, '/officer'),
            ]),
            section('LUPON SCHEDULE', const [
              _SideItem('Schedule', Icons.calendar_today_outlined),
              _SideItem('Hearings', Icons.gavel_outlined),
            ]),
            section('KP FORMS LIBRARY', const [
              _SideItem('Forms', Icons.article_outlined),
              _SideItem('Reports', Icons.bar_chart),
            ]),
            section('SYSTEM SETTINGS', const [
              _SideItem('Settings', Icons.settings_outlined),
            ]),
          ];

    final profileName = light ? 'Officer A. Guzman' : 'Officer J. Cruz';

    return Container(
      color: bg,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [header, ...nav]),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: light ? AppColors.white : const Color(0x26FFFFFF),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: light ? AppColors.border : const Color(0x33FFFFFF)),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: light ? const Color(0xFFDCE6F8) : AppColors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text('CO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profileName,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: light ? AppColors.ink : AppColors.white)),
                      Text('Lupon Secretary',
                          style: TextStyle(fontSize: 9.5, color: light ? AppColors.muted : const Color(0xCCFFFFFF))),
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
}
