import 'dart:typed_data';

import 'package:cv_ganerator/models/resume_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ResumePdfService {
  Future<Uint8List> buildPdf({
    required ResumeData data,
    required String title,
  }) async {
    final document = pw.Document();
    final isFreshDeveloper = _isFreshDeveloper(data);
    final maxPages = isFreshDeveloper ? 1 : 2;
    const marginInPoints = 40.0; // ~0.55 inch
    const bodyFontSize = 10.5;
    const headingFontSize = 12.0;

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(marginInPoints),
        maxPages: maxPages,
        build: (context) => [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: bodyFontSize,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            data.fullName.isEmpty ? 'Your Name' : data.fullName,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            data.jobTitle.isEmpty ? 'Job Title' : data.jobTitle,
            style: const pw.TextStyle(fontSize: headingFontSize),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            [
              if (data.email.isNotEmpty) data.email,
              if (data.phone.isNotEmpty) data.phone,
              if (data.location.isNotEmpty) data.location,
              if (data.website.isNotEmpty) data.website,
              if (data.linkedin.isNotEmpty) data.linkedin,
            ].join('  |  '),
            style: const pw.TextStyle(fontSize: bodyFontSize),
          ),
          pw.SizedBox(height: 20),
          _sectionTitle('Profile'),
          pw.SizedBox(height: 6),
          pw.Text(
            data.summary.isEmpty ? 'No summary provided.' : data.summary,
            style: const pw.TextStyle(fontSize: bodyFontSize),
          ),
          pw.SizedBox(height: 14),
          _sectionTitle('Skills'),
          pw.SizedBox(height: 6),
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            children: data.skills
                .where((skill) => skill.trim().isNotEmpty)
                .map(
                  (skill) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(skill),
                  ),
                )
                .toList(),
          ),
          pw.SizedBox(height: 14),
          _sectionTitle('Experience'),
          pw.SizedBox(height: 6),
          ...data.experience.map(
            (item) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    item.title,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: headingFontSize,
                    ),
                  ),
                  pw.Text(
                    '${item.company} | ${item.duration}',
                    style: const pw.TextStyle(fontSize: bodyFontSize),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    item.description,
                    style: const pw.TextStyle(fontSize: bodyFontSize),
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 14),
          _sectionTitle('Education'),
          pw.SizedBox(height: 6),
          ...data.education.map(
            (item) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                '${item.degree} - ${item.school} (${item.year})',
                style: const pw.TextStyle(fontSize: bodyFontSize),
              ),
            ),
          ),
          if (data.languages.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            _sectionTitle('Languages'),
            pw.SizedBox(height: 6),
            pw.Text(
              data.languages.join(', '),
              style: const pw.TextStyle(fontSize: bodyFontSize),
            ),
          ],
          if (data.references.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            _sectionTitle('References'),
            pw.SizedBox(height: 6),
            ...data.references.map(
              (ref) => pw.Text(
                '- $ref',
                style: const pw.TextStyle(fontSize: bodyFontSize),
              ),
            ),
          ],
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }

  bool _isFreshDeveloper(ResumeData data) {
    // Heuristic: no experience or only one short entry => fresh profile.
    final hasNoExperience = data.experience.isEmpty;
    final singleShortExperience = data.experience.length == 1 &&
        data.experience.first.description.trim().split(RegExp(r'\s+')).length <
            35;
    return hasNoExperience || singleShortExperience;
  }
}
