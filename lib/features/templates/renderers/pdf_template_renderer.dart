import 'dart:io';
import 'dart:typed_data';

import 'package:cv_ganerator/features/templates/models/resume_template.dart';
import 'package:cv_ganerator/features/templates/registry/template_registry.dart';
import 'package:cv_ganerator/features/templates/style/resolved_theme.dart';
import 'package:cv_ganerator/models/resume_data.dart';
import 'package:flutter/material.dart' show Color;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfTemplateRenderer {
  Future<Uint8List> build({
    required ResumeData data,
    required String templateId,
    TemplateCustomization? customization,
  }) async {
    final definition = TemplateRegistry.getById(templateId);
    final theme = ResolvedTemplateTheme.resolve(
      definition: definition,
      data: data,
      customization: customization,
    );
    pw.MemoryImage? photo;
    if (theme.showPhoto && data.hasPhoto && !data.photoUrl.startsWith('http')) {
      try {
        final path = data.photoUrl.replaceFirst('file://', '');
        final bytes = await File(path).readAsBytes();
        if (bytes.isNotEmpty) photo = pw.MemoryImage(bytes);
      } catch (_) {}
    }

    final pageFormat = theme.pageSize == PageSizeOption.usLetter
        ? PdfPageFormat.letter
        : PdfPageFormat.a4;
    final ctx = _PdfCtx(theme: theme, data: data, photo: photo);
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.all(theme.spacing.pageMargin),
        build: (_) => [
          _headerForLayout(ctx),
          pw.SizedBox(height: theme.spacing.headerSpacing),
          ..._sections(ctx),
        ],
      ),
    );
    return doc.save();
  }

  pw.Widget _headerForLayout(_PdfCtx ctx) {
    final layout = ctx.theme.definition.layoutType;
    if (layout == TemplateLayoutType.headerBand ||
        layout == TemplateLayoutType.creativeGradient ||
        layout == TemplateLayoutType.modernSidebar ||
        layout == TemplateLayoutType.rightSidebar) {
      return pw.Container(
        width: double.infinity,
        color: layout == TemplateLayoutType.modernSidebar ||
                layout == TemplateLayoutType.rightSidebar
            ? _pdf(ctx.theme.colors.sidebar)
            : ctx.primary,
        padding: const pw.EdgeInsets.all(16),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (ctx.photo != null) ...[
              _photo(ctx, 64),
              pw.SizedBox(width: 12),
            ],
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(ctx.name, style: ctx.nameStyle(PdfColors.white)),
                  pw.Text(ctx.job, style: ctx.jobStyle(PdfColors.white)),
                  pw.SizedBox(height: 6),
                  pw.Text(ctx.contactLine, style: ctx.mutedStyle(PdfColors.white)),
                ],
              ),
            ),
          ],
        ),
      );
    }
    if (layout == TemplateLayoutType.executiveCenter ||
        layout == TemplateLayoutType.elegantSerif) {
      return pw.Column(
        children: [
          if (ctx.photo != null) _photo(ctx, 70),
          pw.Text(ctx.name, style: ctx.nameStyle(), textAlign: pw.TextAlign.center),
          pw.SizedBox(height: 4),
          pw.Text(ctx.job, style: ctx.jobStyle(), textAlign: pw.TextAlign.center),
          pw.SizedBox(height: 8),
          pw.Divider(color: ctx.primary, thickness: 1),
          pw.SizedBox(height: 8),
          pw.Text(
            ctx.contactLine,
            style: ctx.mutedStyle(),
            textAlign: pw.TextAlign.center,
          ),
        ],
      );
    }
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(ctx.name, style: ctx.nameStyle()),
              pw.Text(ctx.job, style: ctx.jobStyle()),
              pw.SizedBox(height: 6),
              pw.Text(ctx.contactLine, style: ctx.mutedStyle()),
            ],
          ),
        ),
        if (ctx.photo != null) _photo(ctx, 70),
      ],
    );
  }

  pw.Widget _photo(_PdfCtx ctx, double size) {
    final image = ctx.photo!;
    final style = ctx.theme.photoStyle;
    if (style == PhotoStyle.circle) {
      return pw.ClipOval(
        child: pw.Image(image, width: size, height: size, fit: pw.BoxFit.cover),
      );
    }
    return pw.ClipRRect(
      child: pw.Image(
        image,
        width: style == PhotoStyle.rectangle ? size * 0.82 : size,
        height: size,
        fit: pw.BoxFit.cover,
      ),
    );
  }

  List<pw.Widget> _sections(_PdfCtx ctx) {
    final ids = ctx.theme.sectionOrder
        .where((id) => ctx.theme.isVisible(ctx.data, id))
        .toList();
    final widgets = <pw.Widget>[];
    for (final id in ids) {
      widgets.addAll(_section(ctx, id));
      widgets.add(pw.SizedBox(height: ctx.theme.spacing.sectionSpacing));
    }
    return widgets;
  }

  List<pw.Widget> _section(_PdfCtx ctx, String id) {
    final title = ctx.theme.titleFor(ctx.data, id).toUpperCase();
    return [
      pw.Text(title, style: ctx.headingStyle(ctx.primary)),
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 3, bottom: 6),
        height: 1.2,
        width: 46,
        color: ctx.primary,
      ),
      ..._sectionBody(ctx, id, ctx.text),
    ];
  }

  List<pw.Widget> _sectionBody(_PdfCtx ctx, String id, PdfColor color) {
    final data = ctx.data;
    switch (id) {
      case ResumeSectionIds.summary:
        return [pw.Text(data.summary, style: ctx.bodyStyle(color))];
      case ResumeSectionIds.experience:
        return data.experience.where((item) => item.hasContent).map((item) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(item.title, style: ctx.bodyStyle(color, bold: true)),
                pw.Text(
                  _join([item.company, item.displayDuration, item.location]),
                  style: ctx.mutedStyle(color),
                ),
                ...item.bullets.map(
                  (bullet) => pw.Text('- $bullet', style: ctx.bodyStyle(color)),
                ),
              ],
            ),
          );
        }).toList();
      case ResumeSectionIds.education:
        return data.education
            .where((item) => item.hasContent)
            .map(
              (item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Text(
                  _join([
                    item.displayDegree,
                    item.school,
                    item.displayYear,
                    item.grade,
                  ]),
                  style: ctx.bodyStyle(color),
                ),
              ),
            )
            .toList();
      case ResumeSectionIds.skills:
        final skills = data.skills
            .map(SkillItem.parse)
            .where((item) => item.name.isNotEmpty)
            .map((item) => item.name)
            .toList();
        if (ctx.theme.definition.skillStyle == SkillStyle.commaList) {
          return [pw.Text(skills.join(' | '), style: ctx.bodyStyle(color))];
        }
        return [
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            children: skills
                .map(
                  (skill) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: color),
                    ),
                    child: pw.Text(skill, style: ctx.bodyStyle(color)),
                  ),
                )
                .toList(),
          ),
        ];
      case ResumeSectionIds.languages:
        return [
          pw.Text(
            data.languages
                .map(LanguageItem.parse)
                .map((item) => item.display)
                .join(' | '),
            style: ctx.bodyStyle(color),
          ),
        ];
      case ResumeSectionIds.projects:
        return data.projects.where((item) => item.hasContent).map((item) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(item.name, style: ctx.bodyStyle(color, bold: true)),
                if (item.description.isNotEmpty)
                  pw.Text(item.description, style: ctx.bodyStyle(color)),
              ],
            ),
          );
        }).toList();
      case ResumeSectionIds.certifications:
        return data.certifications
            .where((item) => item.hasContent)
            .map(
              (item) => pw.Text(
                _join([item.name, item.organization, item.date]),
                style: ctx.bodyStyle(color),
              ),
            )
            .toList();
      case ResumeSectionIds.awards:
        return data.awards
            .where((item) => item.hasContent)
            .map(
              (item) => pw.Text(
                _join([item.title, item.organization, item.date]),
                style: ctx.bodyStyle(color),
              ),
            )
            .toList();
      case ResumeSectionIds.volunteer:
        return data.volunteer
            .where((item) => item.hasContent)
            .map(
              (item) => pw.Text(
                _join([item.role, item.organization, item.duration]),
                style: ctx.bodyStyle(color),
              ),
            )
            .toList();
      case ResumeSectionIds.publications:
        return data.publications
            .where((item) => item.hasContent)
            .map(
              (item) => pw.Text(
                _join([item.title, item.publisher, item.date]),
                style: ctx.bodyStyle(color),
              ),
            )
            .toList();
      case ResumeSectionIds.references:
        return data.references
            .map((item) => pw.Text('- $item', style: ctx.bodyStyle(color)))
            .toList();
      case ResumeSectionIds.interests:
        return [pw.Text(data.interests.join(' | '), style: ctx.bodyStyle(color))];
      default:
        CustomSection? custom;
        for (final item in data.customSections) {
          if (item.id == id) custom = item;
        }
        if (custom == null) return const [];
        return [
          if (custom.content.isNotEmpty)
            pw.Text(custom.content, style: ctx.bodyStyle(color)),
          ...custom.bullets.map(
            (item) => pw.Text('- $item', style: ctx.bodyStyle(color)),
          ),
        ];
    }
  }

  static String _join(Iterable<String> parts) {
    return parts.where((item) => item.trim().isNotEmpty).join(' | ');
  }
}

class _PdfCtx {
  final ResolvedTemplateTheme theme;
  final ResumeData data;
  final pw.MemoryImage? photo;

  _PdfCtx({required this.theme, required this.data, required this.photo});

  String get name => data.fullName.isEmpty ? 'Your Name' : data.fullName;
  String get job => data.jobTitle.isEmpty ? 'Job Title' : data.jobTitle;
  String get contactLine => [
        data.email,
        data.phone,
        data.displayLocation,
        data.website,
        data.linkedin,
        data.github,
      ].where((item) => item.trim().isNotEmpty).join('  |  ');

  PdfColor get primary => _pdf(theme.colors.primary);
  PdfColor get text => _pdf(theme.colors.text);

  bool get serif =>
      theme.typography.headingFont == 'Merriweather' ||
      theme.typography.bodyFont == 'Merriweather';

  pw.TextStyle nameStyle([PdfColor? color]) => pw.TextStyle(
        fontSize: theme.typography.nameSize,
        fontWeight: pw.FontWeight.bold,
        color: color ?? text,
        font: serif ? pw.Font.timesBold() : pw.Font.helveticaBold(),
      );

  pw.TextStyle jobStyle([PdfColor? color]) => pw.TextStyle(
        fontSize: theme.typography.bodySize + 1,
        color: color ?? primary,
        font: serif ? pw.Font.times() : pw.Font.helvetica(),
      );

  pw.TextStyle headingStyle([PdfColor? color]) => pw.TextStyle(
        fontSize: theme.typography.headingSize,
        fontWeight: pw.FontWeight.bold,
        color: color ?? primary,
        letterSpacing: 0.6,
        font: serif ? pw.Font.timesBold() : pw.Font.helveticaBold(),
      );

  pw.TextStyle bodyStyle(PdfColor color, {bool bold = false}) => pw.TextStyle(
        fontSize: theme.typography.bodySize,
        color: color,
        height: theme.typography.lineHeight,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        font: bold
            ? (serif ? pw.Font.timesBold() : pw.Font.helveticaBold())
            : (serif ? pw.Font.times() : pw.Font.helvetica()),
      );

  pw.TextStyle mutedStyle([PdfColor? color]) => pw.TextStyle(
        fontSize: theme.typography.bodySize - 0.5,
        color: color ?? _pdf(theme.colors.muted),
        font: serif ? pw.Font.times() : pw.Font.helvetica(),
      );
}

PdfColor _pdf(Color color) {
  return PdfColor.fromInt(color.toARGB32());
}
