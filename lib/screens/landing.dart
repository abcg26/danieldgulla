import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  Widget _heroImage() {
    return AspectRatio(
      aspectRatio: 1.38,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Image.asset(
          'assets/images/hero.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD9C9A8), Color(0xFF8E7B5A)],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_outlined, size: 56, color: Color(0xCCFFFFFF)),
                  SizedBox(height: 10),
                  Text('Barangay Hall', style: TextStyle(color: Color(0xE6FFFFFF), fontSize: 14, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Add assets/images/hero.jpg to show a photo',
                      style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);

    final heroText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(border: Border.all(color: AppColors.ink)),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('BARANGAY CASE WORKSPACE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.ink)),
              SizedBox(height: 3),
              Text('Powered by Advanced Analytics and\nLegal Guidelines',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: AppColors.body)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Case Triage for Katarungang Pambarangay',
            style: TextStyle(
                fontSize: narrow ? 30 : 42, height: 1.15, fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(height: 18),
        const Text(
          'File a barangay dispute, receive automated AI-assisted triage, and follow its status through the conciliation or referral workflow. Cases persist in this browser; this app is not an official government service.',
          style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.body),
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            AppButton('File a Complaint',
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                onPressed: () => go(context, '/complaint')),
            AppButton('Track Case',
                outlined: true,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                onPressed: () => go(context, '/track')),
          ],
        ),
      ],
    );

    final hero = Padding(
      padding: EdgeInsets.symmetric(horizontal: narrow ? 20 : 56, vertical: narrow ? 40 : 72),
      child: Boxed(
        padding: EdgeInsets.zero,
        child: narrow
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [heroText, const SizedBox(height: 32), _heroImage()])
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 11, child: heroText),
                  const SizedBox(width: 56),
                  Expanded(flex: 9, child: _heroImage()),
                ],
              ),
      ),
    );

    Widget card(IconData icon, String title, String text) => AppCard(
          padding: const EdgeInsets.all(22),
          borderColor: const Color(0x00000000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(3)),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 8),
              Text(text, style: const TextStyle(fontSize: 11.5, height: 1.55, color: AppColors.body)),
            ],
          ),
        );

    final cards = [
      card(Icons.description_outlined, 'GUIDED CASE INTAKE',
          'Submit your grievance with guided input and receive automated case analysis based on RA 7160 standards.'),
      card(Icons.memory, 'Automated Case Analysis',
          'Receive automated case analysis based on RA 7160 standards and monitor your case progress through to mediation and resolution.'),
      card(Icons.show_chart, 'Case Progress Updates',
          'Get transparent live timeline updates. Know when the Lupon Tagapamayapa appoints conciliators or schedules mediation sessions.'),
    ];

    final workflow = Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: narrow ? 20 : 56, vertical: 56),
      child: Boxed(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            const Text('PUBLIC SERVICE WORKFLOW',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.primary)),
            const SizedBox(height: 10),
            Text('How the D.A.N.I.E.L.D.G.U.L.L.A Works',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: narrow ? 20 : 24, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 32),
            if (narrow)
              Column(children: [for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: 14), child: c)])
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 20),
                    Expanded(child: cards[i]),
                  ],
                ],
              ),
          ],
        ),
      ),
    );

    return PublicScaffold(
      active: '/',
      subtitle: 'ELECTRONIC TRIAGE AND NAVIGATION PORTAL',
      serifLogo: true,
      footerBlurb:
          'Supports the barangay justice system under RA 7160. This portal provides guided public service, officer-reviewed case intake, and transparent updates for citizens navigating the Katarungang Pambarangay process.',
      child: Column(children: [hero, workflow]),
    );
  }
}
