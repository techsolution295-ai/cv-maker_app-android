import 'package:flutter/material.dart';
import 'package:cv_ganerator/features/templates/models/resume_template.dart';
import 'package:cv_ganerator/features/templates/renderers/template_renderer.dart';
import 'package:cv_ganerator/models/resume_data.dart';

enum ResumeTemplateKind {
  travis,
  jeff,
  jack,
  alice,
  matthew,
  edward,
  patMash,
  patricia,
  daniel,
}

const Map<ResumeTemplateKind, String> kLegacyTemplateIds = {
  ResumeTemplateKind.travis: 'ats_classic',
  ResumeTemplateKind.jeff: 'modern_blue',
  ResumeTemplateKind.jack: 'ats_professional',
  ResumeTemplateKind.alice: 'elegant',
  ResumeTemplateKind.matthew: 'ats_minimal',
  ResumeTemplateKind.edward: 'executive_classic',
  ResumeTemplateKind.patMash: 'creative_portfolio',
  ResumeTemplateKind.patricia: 'creative_bold',
  ResumeTemplateKind.daniel: 'compact_professional',
};

class ResumeTemplateSwitcher extends StatelessWidget {
  final ResumeData data;
  final ResumeTemplateKind kind;
  final String? templateId;
  final TemplateCustomization? customization;

  const ResumeTemplateSwitcher({
    super.key,
    required this.data,
    required this.kind,
    this.templateId,
    this.customization,
  });

  @override
  Widget build(BuildContext context) {
    return TemplateRenderer(
      resumeData: data,
      templateId: templateId ?? kLegacyTemplateIds[kind] ?? 'ats_classic',
      customization: customization,
    );
  }
}
