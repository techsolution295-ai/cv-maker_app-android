import 'dart:typed_data';

import 'package:cv_ganerator/features/templates/models/resume_template.dart';
import 'package:cv_ganerator/features/templates/renderers/pdf_template_renderer.dart';
import 'package:cv_ganerator/models/resume_data.dart';

class ResumePdfService {
  final PdfTemplateRenderer _renderer = PdfTemplateRenderer();

  Future<Uint8List> buildPdf({
    required ResumeData data,
    required String title,
    String templateId = 'ats_classic',
    TemplateCustomization? customization,
  }) {
    return _renderer.build(
      data: data,
      templateId: templateId,
      customization: customization,
    );
  }
}
