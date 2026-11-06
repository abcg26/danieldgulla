import 'package:flutter/material.dart';

import 'data.dart';
import 'screens/about.dart';
import 'screens/complaint_detail.dart';
import 'screens/complaint_form.dart';
import 'screens/dashboard.dart';
import 'screens/landing.dart';
import 'screens/track.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? storageError;
  try {
    await CaseStore.initialize();
  } catch (error) {
    storageError = error;
  }
  runApp(DanielApp(storageError: storageError));
}

class DanielApp extends StatelessWidget {
  final Object? storageError;
  const DanielApp({super.key, this.storageError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D.A.N.I.E.L.D.G.U.L.L.A',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: storageError == null
          ? null
          : _StorageErrorPage(error: storageError.toString()),
      initialRoute: '/',
      onGenerateRoute: storageError != null
          ? null
          : (settings) {
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
                  page =
                      ComplaintDetailPage(caseId: args is String ? args : '');
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

class _StorageErrorPage extends StatelessWidget {
  final String error;
  const _StorageErrorPage({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Could not load saved cases',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              SelectableText(error, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
