import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

class ComplaintFormPage extends StatefulWidget {
  const ComplaintFormPage({super.key});

  @override
  State<ComplaintFormPage> createState() => _ComplaintFormPageState();
}

class _ComplaintFormPageState extends State<ComplaintFormPage> {
  static const _barangays = [
    'Barangay San Lorenzo, Makati',
    'Barangay Poblacion, Makati',
    'Barangay Bel-Air, Makati',
    'Barangay Batasan Hills, Quezon City',
    'Barangay Commonwealth, Quezon City',
  ];
  static const _categories = [
    'Neighbor Dispute',
    'Noise Disturbance',
    'Property Boundary',
    'Infrastructure Damage',
    'Water Supply Dispute',
    'Pet Disturbance',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _narrative = TextEditingController();
  String _barangay = _barangays.first;
  String _category = _categories.first;
  bool _pwd = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _narrative.dispose();
    super.dispose();
  }

  void _clear() {
    _formKey.currentState?.reset();
    _name.clear();
    _phone.clear();
    _narrative.clear();
    setState(() {
      _barangay = _barangays.first;
      _category = _categories.first;
      _pwd = false;
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final id = CaseStore.nextId();
    CaseStore.cases.insert(
      0,
      CaseRecord(
        id: id,
        date: fmtDate(DateTime.now()),
        filedAt: 'Just now',
        name: _name.text.trim(),
        category: _category,
        aiCategory: 'Pending classification',
        urgency: 'MEDIUM',
        stage: 'Mediation',
        status: 'NEW',
        action: 'Issue Summons',
        narrative: _narrative.text.trim(),
        trackStep: 1,
        pwd: _pwd,
        accommodation: _pwd ? 'PWD / Senior Citizen priority conciliation requested.' : null,
        phone: _phone.text.trim().isEmpty ? '—' : _phone.text.trim(),
        barangay: _barangay.split(',').first.replaceFirst('Barangay', 'Brgy.'),
      ),
    );
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Grievance record submitted', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        content: Text('Your Case ID is $id.\nKeep this number to track your complaint. A Lupon officer will review your record.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              go(context, '/track', args: id);
            },
            child: const Text('Track Case'),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String label, List<String> items, String value, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        InputDecorator(
          decoration: inputDec(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              style: const TextStyle(fontSize: 12, color: AppColors.ink),
              items: [for (final e in items) DropdownMenuItem<String>(value: e, child: Text(e, overflow: TextOverflow.ellipsis))],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrow(context);
    const helper = TextStyle(fontSize: 10, color: AppColors.muted);
    const sectionStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink);

    final brgyField = _dropdown('Barangay Location', _barangays, _barangay, (v) => setState(() => _barangay = v));
    final catField = _dropdown('Complaint Category', _categories, _category, (v) => setState(() => _category = v));

    final upload = InkWell(
      onTap: () => toast(context, 'File selection is not available in this prototype.'),
      child: CustomPaint(
        painter: DashedRectPainter(const Color(0xFFC9CED6)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30),
          color: const Color(0xFFFAFAFB),
          child: const Column(
            children: [
              Icon(Icons.cloud_upload_outlined, size: 24, color: AppColors.muted),
              SizedBox(height: 8),
              Text('Click to upload or drag & drop files',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)),
              SizedBox(height: 3),
              Text('MP4, MP3, WAV, JPG or PNG up to 25MB', style: TextStyle(fontSize: 9.5, color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );

    final form = Form(
      key: _formKey,
      child: AppCard(
        padding: EdgeInsets.all(narrow ? 18 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1. Personal Information', style: sectionStyle),
            const SizedBox(height: 16),
            const FieldLabel('Full Name (Complainant)'),
            TextFormField(
              controller: _name,
              style: const TextStyle(fontSize: 12),
              decoration: inputDec(hint: 'e.g. Juan dela Cruz'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
            ),
            const SizedBox(height: 4),
            const Text('Enter legal name as indicated on your government-issued ID.', style: helper),
            const SizedBox(height: 16),
            const FieldLabel('Contact Number'),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 12),
              decoration: inputDec(hint: 'e.g. +63 917 123 4567'),
            ),
            const SizedBox(height: 22),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 22),
            const Text('2. Dispute Context', style: sectionStyle),
            const SizedBox(height: 16),
            if (narrow) ...[brgyField, const SizedBox(height: 14), catField] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: brgyField), const SizedBox(width: 16), Expanded(child: catField)],
              ),
            const SizedBox(height: 16),
            const FieldLabel('Detailed Complaint Narrative'),
            TextFormField(
              controller: _narrative,
              minLines: 4,
              maxLines: 6,
              style: const TextStyle(fontSize: 12),
              decoration: inputDec(hint: 'Describe what happened, who is involved, and when it occurred.'),
              validator: (v) => (v == null || v.trim().length < 10) ? 'Please describe the dispute (at least 10 characters)' : null,
            ),
            const SizedBox(height: 4),
            const Text('Provide specific dates, times, and prior attempts at peaceful resolution.', style: helper),
            const SizedBox(height: 16),
            const FieldLabel('Supporting Evidence (Videos, Audio, Photos)'),
            upload,
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.surface,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: _pwd,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _pwd = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Request PWD / Senior Citizen Priority Conciliation',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                        SizedBox(height: 2),
                        Text('Enable this for physical accessibility accommodations, sign language interpreters, or home visit audits.',
                            style: TextStyle(fontSize: 10, color: AppColors.body)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _clear,
                  child: const Text('Clear Form',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)),
                ),
                AppButton('Submit Grievance Record',
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16), onPressed: _submit),
              ],
            ),
          ],
        ),
      ),
    );

    final intro = AppCard(
      padding: EdgeInsets.all(narrow ? 18 : 28),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Submit a Dispute Record', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink)),
          SizedBox(height: 10),
          Text(
            'Please fill out all relevant sections completely. The D.A.N.I.E.L.D.G.U.L.L.A algorithm will evaluate whether this complaint falls directly under your local Barangay jurisdiction or requires LGU elevation.',
            style: TextStyle(fontSize: 11.5, height: 1.55, color: AppColors.body),
          ),
        ],
      ),
    );

    return PublicScaffold(
      active: '/complaint',
      background: AppColors.page,
      footerLight: true,
      child: Boxed(
        maxWidth: 720,
        padding: EdgeInsets.symmetric(horizontal: narrow ? 14 : 24, vertical: 36),
        child: Column(children: [intro, const SizedBox(height: 18), form]),
      ),
    );
  }
}
