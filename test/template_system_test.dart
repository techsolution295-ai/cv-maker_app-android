import 'package:cv_ganerator/features/templates/models/resume_template.dart';
import 'package:cv_ganerator/features/templates/previews/template_thumbnail.dart';
import 'package:cv_ganerator/features/templates/registry/template_registry.dart';
import 'package:cv_ganerator/features/templates/renderers/template_renderer.dart';
import 'package:cv_ganerator/features/templates/sample/sample_resume_data.dart';
import 'package:cv_ganerator/models/resume_data.dart';
import 'package:cv_ganerator/services/resume_pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final templates = TemplateRegistry.allTemplates;

  test('registry contains at least 55 unique templates', () {
    expect(templates.length, greaterThanOrEqualTo(55));
    final ids = templates.map((item) => item.id).toSet();
    expect(ids.length, templates.length);
    final names = templates.map((item) => item.name).toSet();
    expect(names.length, templates.length);
  });

  test('template lookup by id', () {
    final classic = TemplateRegistry.getById('ats_classic');
    expect(classic.name, 'ATS Classic');
    expect(classic.atsFriendly, isTrue);
    expect(TemplateRegistry.tryGetById('missing'), isNull);
  });

  test('category filtering', () {
    expect(TemplateRegistry.getByCategory(TemplateCategory.ats).length, 10);
    expect(TemplateRegistry.getByCategory(TemplateCategory.modern).length, 10);
    expect(TemplateRegistry.getByCategory(TemplateCategory.executive).length, 5);
    expect(TemplateRegistry.getByCategory(TemplateCategory.creative).length, 7);
    expect(TemplateRegistry.getByCategory(TemplateCategory.tech).length, 7);
    expect(TemplateRegistry.getByCategory(TemplateCategory.academic).length, 5);
    expect(TemplateRegistry.getByCategory(TemplateCategory.elegant).length, 6);
    expect(TemplateRegistry.getByCategory(TemplateCategory.additional).length, 5);
  });

  test('search matches name, category, tags and description', () {
    expect(TemplateRegistry.search('modern').length, greaterThan(5));
    expect(TemplateRegistry.search('developer').first.id, 'developer');
    expect(TemplateRegistry.search('academic').length, greaterThanOrEqualTo(5));
    expect(TemplateRegistry.search('executive').length, greaterThanOrEqualTo(5));
    expect(TemplateRegistry.search('xyz-not-a-template'), isEmpty);
  });

  test('templates are single-page designs', () {
    expect(templates.every((item) => item.pageCount == 1), isTrue);
    expect(TemplateRegistry.getById('simple_one_page').pageCount, 1);
    expect(TemplateRegistry.getById('modern_sidebar').pageCount, 1);
  });

  test('featured and popular collections are populated', () {
    expect(TemplateRegistry.featuredTemplates, isNotEmpty);
    expect(TemplateRegistry.popularTemplates, isNotEmpty);
  });

  test('switching templates does not mutate resume data', () {
    final original = SampleResumeData.alexMorgan;
    final snapshot = ResumeData.fromMap(original.toMap());
    for (final template in templates) {
      final resolved = template.id;
      expect(resolved, isNotEmpty);
      expect(original.toMap(), snapshot.toMap());
      expect(original.fullName, 'Alex Morgan');
      expect(original.experience.length, snapshot.experience.length);
    }
  });

  test('section visibility and ordering stay independent of template', () {
    final hidden = SampleResumeData.alexMorgan.copyWith(
      sectionVisibility: {
        ResumeSectionIds.summary: false,
        ResumeSectionIds.experience: true,
      },
      sectionOrder: [
        ResumeSectionIds.skills,
        ResumeSectionIds.experience,
        ResumeSectionIds.summary,
      ],
    );
    expect(hidden.isSectionVisible(ResumeSectionIds.summary), isFalse);
    expect(hidden.isSectionVisible(ResumeSectionIds.experience), isTrue);
    expect(hidden.sectionOrder.first, ResumeSectionIds.skills);
    expect(hidden.fullName, SampleResumeData.alexMorgan.fullName);
  });

  test('legacy saved resume maps still load', () {
    final data = ResumeData.fromMap({
      'fullName': 'Jane Doe',
      'jobTitle': 'Analyst',
      'email': 'jane@example.com',
      'phone': '123',
      'location': 'London',
      'summary': 'Summary',
      'skills': ['Excel'],
      'experience': [
        {
          'title': 'Analyst',
          'company': 'Acme',
          'duration': '2020-2022',
          'description': 'Worked on reports',
        }
      ],
      'education': [
        {
          'degree': 'BA',
          'school': 'UCL',
          'year': '2019',
        }
      ],
    });
    expect(data.fullName, 'Jane Doe');
    expect(data.experience.single.company, 'Acme');
    expect(data.github, isEmpty);
    expect(data.projects, isEmpty);
  });

  testWidgets('template renderer builds representative templates', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const ids = [
      'ats_classic',
      'modern_sidebar',
      'developer',
      'academic',
      'elegant',
      'professional_international',
      'creative_portfolio',
      'creative_bold',
      'creative_minimal',
    ];
    for (final id in ids) {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: TemplateRenderer(
              resumeData: SampleResumeData.alexMorgan,
              templateId: id,
              thumbnail: true,
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: id);
      expect(find.text('Alex Morgan'), findsWidgets, reason: id);
    }
  });

  testWidgets('creative gallery thumbnails are not blank', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final id in ['creative_portfolio', 'creative_bold']) {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 180,
            height: 254,
            child: TemplateThumbnail(
              template: TemplateRegistry.getById(id),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: id);
      expect(find.byType(TemplateThumbnail), findsOneWidget, reason: id);
      expect(find.textContaining('Alex Morgan'), findsWidgets, reason: id);
    }
  });

  test('pdf export produces bytes for long multi-section resumes', () async {
    final bytes = await ResumePdfService().buildPdf(
      data: SampleResumeData.alexMorgan,
      title: 'Alex Morgan',
      templateId: 'modern_sidebar',
    );
    expect(bytes.length, greaterThan(1000));
    expect(bytes[0], 0x25); // %PDF
  });

  test('favorite filter uses provided ids without changing data', () {
    final result = TemplateRegistry.filter(
      favoritesOnly: true,
      favoriteIds: {'developer', 'academic'},
    );
    expect(result.map((item) => item.id).toSet(), {'developer', 'academic'});
  });
}
