import 'package:flutter/material.dart';

import 'screens/about.dart';
import 'screens/complaint_detail.dart';
import 'screens/complaint_form.dart';
import 'screens/dashboard.dart';
import 'screens/landing.dart';
import 'screens/track.dart';
import 'theme.dart';

void main() => runApp(const DanielApp());

class DanielApp extends StatelessWidget {
  const DanielApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D.A.N.I.E.L.D.G.U.L.L.A',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final path = Uri.parse(settings.name ?? '/').path;
        final args = settings.arguments;
        Widget page;
        switch (path) {
          case '/complaint':
            page = const ComplaintFormPage();
            break;
          case '/track':
            page = TrackPage(initialId: args is String ? args : null);
            break;
          case '/about':
            page = const AboutPage();
            break;
          case '/officer':
            page = const DashboardPage();
            break;
          case '/officer/complaint':
            page = ComplaintDetailPage(caseId: args is String ? args : 'KP-2026-004');
            break;
          default:
            page = const LandingPage();
        }
        return PageRouteBuilder<void>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
      },
    );
  }
}
