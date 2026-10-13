import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Widget _eyebrow(String t) => Text(t,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.primary));

  Widget _h2(String t) => Text(t,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink));

  Widget _sub(String t) => Text(t,
      textAlign: TextAlign.center, style: const TextStyle(fontSize: 11.5, height: 1.5, color: AppColors.muted));

  Widget _bullets(List<String> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final i in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6, right: 8),
                    child: Icon(Icons.circle, size: 4, color: AppColors.body),
                  ),
                  Expanded(child: Text(i, style: const TextStyle(fontSize: 11.5, height: 1.5, color: AppColors.body))),
                ],
              ),
            ),
        ],
      );

  Widget _disputeColumn(String title, String intro, List<String> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 8),
          Text(intro, style: const TextStyle(fontSize: 11.5, height: 1.55, color: AppColors.body)),
          const SizedBox(height: 12),
          _bullets(items),
        ],
      );

  Widget _org(int n, String title, String tag, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Text('$n', style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      Text(tag,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(text, style: const TextStyle(fontSize: 11.5, height: 1.55, color: AppColors.body)),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);
    final hp = narrow ? 20.0 : 40.0;

    final hero = Padding(
      padding: EdgeInsets.fromLTRB(hp, 56, hp, 48),
      child: Boxed(
        maxWidth: 760,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFEAF0FB), borderRadius: BorderRadius.circular(3)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_outlined, size: 12, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text('INSTITUTIONAL REFERENCE',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('About the D.A.N.I.E.L.D.G.U.L.L.A',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: narrow ? 26 : 34, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 14),
            const Text(
              "This page provides a formal overview of the portal's institutional scope, legal basis, and organizational structure for barangay dispute resolution under the Katarungang Pambarangay system.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, height: 1.55, color: AppColors.body),
            ),
          ],
        ),
      ),
    );

    final covered = _disputeColumn(
      'Covered Disputes',
      'The portal is intended for local disputes that are subject to mandatory conciliation under the Katarungang Pambarangay system. Covered disputes generally include:',
      const [
        'Noise and disturbance complaints between neighbors',
        'Boundary disputes and minor property encroachments',
        'Minor property damage and small-value civil claims',
        'Community nuisance and neighborhood conflicts',
      ],
    );
    final excluded = _disputeColumn(
      'Excluded Disputes',
      'The following disputes are excluded from mandatory barangay conciliation and may require direct referral to law enforcement, courts, or other competent authorities:',
      const [
        'Serious offenses punishable by imprisonment of more than one year',
        'Other exclusions expressly provided by statute, subject to officer verification',
        'Disputes outside the applicable residence and venue requirements',
        'Matters requiring referral to another competent authority',
      ],
    );

    final scope = Padding(
      padding: EdgeInsets.symmetric(horizontal: hp, vertical: 48),
      child: Boxed(
        maxWidth: 900,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _eyebrow('JURISDICTION & SCOPE'),
            const SizedBox(height: 8),
            _h2('Covered and Excluded Disputes'),
            const SizedBox(height: 8),
            _sub('The portal supports the barangay justice process by distinguishing between disputes subject to mandatory conciliation and those that are excluded by statute.'),
            const SizedBox(height: 30),
            if (narrow)
              Column(children: [covered, const SizedBox(height: 26), excluded])
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: covered), const SizedBox(width: 48), Expanded(child: excluded)],
              ),
          ],
        ),
      ),
    );

    final org = Container(
      color: const Color(0xFFF7F8FA),
      padding: EdgeInsets.symmetric(horizontal: hp, vertical: 48),
      child: Boxed(
        maxWidth: 760,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _eyebrow('INSTITUTIONAL FRAMEWORK'),
            const SizedBox(height: 8),
            _h2('Organizational Structure'),
            const SizedBox(height: 8),
            _sub('Local dispute mediation follows a three-tier hierarchy from intake through conciliation and council review.'),
            const SizedBox(height: 30),
            _org(1, 'Punong Barangay', 'EXECUTIVE INTAKE',
                'Executive intake and initial assessment. The Punong Barangay receives complaints, verifies residency and venue, and determines whether a dispute falls within the barangay justice process.'),
            _org(2, 'Lupon Tagapamayapa', 'FULL COUNCIL',
                'Full council review and conciliation oversight. The Lupon Tagapamayapa reviews officer findings, determines jurisdiction, and assigns cases for the conciliation process.'),
            _org(3, 'Pangkat Tagapagkasundo', '3-MEMBER CONCILIATION PANEL',
                'Three-member conciliation panel. The Pangkat Tagapagkasundo conducts mediation sessions, facilitates settlement, and prepares the Certificate of Conciliation or Certificate to File Action as required.'),
          ],
        ),
      ),
    );

    final statute = Padding(
      padding: EdgeInsets.symmetric(horizontal: hp, vertical: 48),
      child: Boxed(
        maxWidth: 760,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _eyebrow('LEGAL BASIS'),
            const SizedBox(height: 8),
            _h2('Statutory Authority'),
            const SizedBox(height: 8),
            _sub('The portal operates under the Local Government Code of 1991 and supports the barangay justice process through structured intake, review, and conciliation.'),
            const SizedBox(height: 26),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 6,
                    children: const [
                      Pill('RA 7160', bg: AppColors.primary, fg: AppColors.white, fontSize: 10),
                      Text('Republic Act No. 7160 (Local Government Code of 1991), Sections 399–422',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'The portal supports the barangay justice process by distinguishing between disputes subject to mandatory conciliation and those that fall outside barangay jurisdiction. Coverage is determined by residency, venue, and statutory exceptions, and designated officers verify eligibility before proceeding.',
                    style: TextStyle(fontSize: 11.5, height: 1.55, color: AppColors.body),
                  ),
                  const SizedBox(height: 12),
                  _bullets(const [
                    'Mandatory conciliation applies to local disputes that meet the residency and venue requirements under the Katarungang Pambarangay system.',
                    'Excluded disputes include offenses punishable by imprisonment of more than one year, alongside other statutory exceptions.',
                    'Coverage must be assessed case by case. The dispute topic alone does not determine eligibility for barangay proceedings.',
                  ]),
                  const SizedBox(height: 8),
                  const Text(
                    'Legal reminder: residency, venue, and statutory exceptions determine coverage. Designated officers verify eligibility before proceeding, and the portal does not categorically exclude all violence or property disputes from barangay conciliation.',
                    style: TextStyle(fontSize: 10.5, height: 1.5, fontStyle: FontStyle.italic, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return PublicScaffold(
      active: '/about',
      footerBlurb:
          'A digital portal for barangay dispute intake, routing, and Katarungang Pambarangay case management. Operated under RA 7160 by trained barangay officers and Lupon Tagapamayapa members.',
      child: Column(children: [hero, scope, org, statute]),
    );
  }
}
