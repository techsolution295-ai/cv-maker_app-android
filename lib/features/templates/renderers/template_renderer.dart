import 'package:flutter/material.dart';
import 'package:cv_ganerator/features/templates/components/resume_components.dart';
import 'package:cv_ganerator/features/templates/models/resume_template.dart';
import 'package:cv_ganerator/features/templates/registry/template_registry.dart';
import 'package:cv_ganerator/features/templates/style/resolved_theme.dart';
import 'package:cv_ganerator/models/resume_data.dart';

class TemplateRenderer extends StatelessWidget {
  final ResumeData resumeData;
  final String templateId;
  final TemplateCustomization? customization;
  final bool thumbnail;

  const TemplateRenderer({
    super.key,
    required this.resumeData,
    required this.templateId,
    this.customization,
    this.thumbnail = false,
  });

  @override
  Widget build(BuildContext context) {
    final definition = TemplateRegistry.getById(templateId);
    final theme = ResolvedTemplateTheme.resolve(
      definition: definition,
      data: resumeData,
      customization: customization,
      thumbnail: thumbnail,
    );
    final content = DefaultTextStyle(
      style: theme.bodyStyle(),
      child: _LayoutHost(
        data: resumeData,
        theme: theme,
      ),
    );
    final size = theme.pageSizePx;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : size.width;
        final height = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : size.height;
        return SizedBox(
          width: width,
          height: height,
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Colors.white),
            child: content,
          ),
        );
      },
    );
  }
}

class _LayoutHost extends StatelessWidget {
  final ResumeData data;
  final ResolvedTemplateTheme theme;

  const _LayoutHost({
    required this.data,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final type = theme.definition.layoutType;
    final Widget layout;
    switch (type) {
      case TemplateLayoutType.modernSidebar:
        layout = _SidebarLayout(data: data, theme: theme, left: true);
      case TemplateLayoutType.rightSidebar:
        layout = _SidebarLayout(data: data, theme: theme, left: false);
      case TemplateLayoutType.headerBand:
      case TemplateLayoutType.creativeGradient:
        layout = _HeaderBandLayout(
          data: data,
          theme: theme,
          gradient: type == TemplateLayoutType.creativeGradient,
        );
      case TemplateLayoutType.twoColumn:
      case TemplateLayoutType.techGrid:
        layout = _TwoColumnLayout(
          data: data,
          theme: theme,
          skillsFirst: type == TemplateLayoutType.techGrid,
        );
      case TemplateLayoutType.modernSplit:
        layout = _SplitHeaderLayout(data: data, theme: theme);
      case TemplateLayoutType.modernTimeline:
        layout = _TimelineLayout(data: data, theme: theme);
      case TemplateLayoutType.executiveCenter:
      case TemplateLayoutType.elegantSerif:
        layout = _CenteredLayout(data: data, theme: theme);
      case TemplateLayoutType.creativeAsymmetric:
        layout = _AsymmetricLayout(data: data, theme: theme);
      case TemplateLayoutType.international:
        layout = _InternationalLayout(data: data, theme: theme);
      case TemplateLayoutType.compact:
        layout = _SingleColumnLayout(data: data, theme: theme, compact: true);
      case TemplateLayoutType.academic:
        layout = _SingleColumnLayout(data: data, theme: theme, academic: true);
      case TemplateLayoutType.atsSingle:
        layout = _SingleColumnLayout(data: data, theme: theme, numbered: true);
      case TemplateLayoutType.atsClean:
        layout = _SingleColumnLayout(data: data, theme: theme);
    }
    final split = type == TemplateLayoutType.modernSidebar ||
        type == TemplateLayoutType.rightSidebar ||
        type == TemplateLayoutType.creativeAsymmetric;
    return split ? layout : _ClipOverflow(child: layout);
  }
}

class _ClipOverflow extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry alignment;

  const _ClipOverflow({
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipBehavior: Clip.hardEdge,
      child: OverflowBox(
        alignment: alignment,
        minHeight: 0,
        maxHeight: double.infinity,
        child: child,
      ),
    );
  }
}

class _SingleColumnLayout extends StatelessWidget {
  final ResumeData data;
  final ResolvedTemplateTheme theme;
  final bool numbered;
  final bool compact;
  final bool academic;

  const _SingleColumnLayout({
    required this.data,
    required this.theme,
    this.numbered = false,
    this.compact = false,
    this.academic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(theme.spacing.pageMargin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderBlock(
            data: data,
            theme: theme,
            centered: theme.definition.headerStyle == HeaderStyle.center,
          ),
          SizedBox(height: theme.spacing.headerSpacing),
          _SectionList(
            data: data,
            theme: theme,
            numbered: numbered,
            dense: compact,
          ),
        ],
      ),
    );
  }
}

class _CenteredLayout extends StatelessWidget {
  final ResumeData data;
  final ResolvedTemplateTheme theme;

  const _CenteredLayout({required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(theme.spacing.pageMargin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (theme.showPhoto) ...[
            ProfilePhoto(data: data, theme: theme, size: 78),
            const SizedBox(height: 10),
          ],
          Text(
            data.fullName.trim().isEmpty ? 'Your Name' : data.fullName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.nameStyle(),
          ),
          const SizedBox(height: 4),
          Text(
            data.jobTitle.trim().isEmpty ? 'Job Title' : data.jobTitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.jobStyle(),
          ),
          const SizedBox(height: 8),
          ResumeRule(theme: theme),
          const SizedBox(height: 8),
          ContactRow(
            data: data,
            theme: theme,
            alignment: WrapAlignment.center,
            icons: false,
          ),
          SizedBox(height: theme.spacing.headerSpacing),
          Align(
            alignment: Alignment.centerLeft,
            child: _SectionList(data: data, theme: theme),
          ),
        ],
      ),
    );
  }
}

class _HeaderBandLayout extends StatelessWidget {
  final ResumeData data;
  final ResolvedTemplateTheme theme;
  final bool gradient;

  const _HeaderBandLayout({
    required this.data,
    required this.theme,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            theme.spacing.pageMargin,
            theme.spacing.pageMargin,
            theme.spacing.pageMargin,
            theme.spacing.headerSpacing + 6,
          ),
          decoration: BoxDecoration(
            color: gradient ? null : theme.colors.primary,
            gradient: gradient
                ? LinearGradient(
                    colors: [
                      theme.colors.primary,
                      theme.colors.primary.withValues(alpha: 0.75),
                    ],
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (theme.showPhoto) ...[
                ProfilePhoto(data: data, theme: theme, size: 74),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.fullName.trim().isEmpty ? 'Your Name' : data.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.nameStyle().copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.jobTitle.trim().isEmpty ? 'Job Title' : data.jobTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.jobStyle().copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    ContactRow(
                      data: data,
                      theme: theme,
                      color: Colors.white,
                      compact: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(theme.spacing.pageMargin),
          child: _SectionList(data: data, theme: theme),
        ),
      ],
    );
  }
}

class _SplitHeaderLayout extends StatelessWidget {
  final ResumeData data;
  final ResolvedTemplateTheme theme;

  const _SplitHeaderLayout({required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(theme.spacing.pageMargin),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.fullName.trim().isEmpty ? 'Your Name' : data.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.nameStyle(),
                    ),
                    Text(
                      data.jobTitle.trim().isEmpty ? 'Job Title' : data.jobTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.jobStyle(),
                    ),
                    const SizedBox(height: 8),
                    ContactRow(data: data, theme: theme, compact: true),
                  ],
                ),
              ),
              if (theme.showPhoto)
                ProfilePhoto(data: data, theme: theme, size: 82),
            ],
          ),
          SizedBox(height: theme.spacing.headerSpacing),
          ResumeRule(theme: theme),
          SizedBox(height: theme.spacing.sectionSpacing),
          _SectionList(data: data, theme: theme),
        ],
      ),
    );
  }
}

class _SidebarLayout extends StatelessWidget {
  final ResumeData data;
  final ResolvedTemplateTheme theme;
  final bool left;

  const _SidebarLayout({
    required this.data,
    required this.theme,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    final sidebar = ColoredBox(
      color: theme.colors.sidebar,
      child: _ClipOverflow(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.pageMargin * 0.75),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (theme.showPhoto) ...[
                Center(child: ProfilePhoto(data: data, theme: theme, size: 86)),
                const SizedBox(height: 16),
              ],
              Text(
                'CONTACT',
                style: theme.headingStyle().copyWith(color: theme.colors.onSidebar),
              ),
              const SizedBox(height: 8),
              ContactRow(
                data: data,
                theme: theme,
                color: theme.colors.onSidebar,
                compact: true,
              ),
              const SizedBox(height: 18),
              _SectionList(
                data: data,
                theme: theme,
                light: true,
                only: const [
                  ResumeSectionIds.skills,
                  ResumeSectionIds.languages,
                  ResumeSectionIds.interests,
                  ResumeSectionIds.certifications,
                ],
              ),
            ],
          ),
        ),
      ),
    );
    final main = ColoredBox(
      color: Colors.white,
      child: _ClipOverflow(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.pageMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.fullName.trim().isEmpty ? 'Your Name' : data.fullName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.nameStyle(),
              ),
              Text(
                data.jobTitle.trim().isEmpty ? 'Job Title' : data.jobTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.jobStyle(),
              ),
              SizedBox(height: theme.spacing.headerSpacing),
              _SectionList(
                data: data,
                theme: theme,
                except: const [
                  ResumeSectionIds.skills,
                  ResumeSectionIds.languages,
                  ResumeSectionIds.interests,
                  ResumeSectionIds.certifications,
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: left
          ? [
              Expanded(flex: 34, child: sidebar),
              Expanded(flex: 66, child: main),
            ]
          : [
              Expanded(flex: 66, child: main),
              Expanded(flex: 34, child: sidebar),
            ],
    );
  }
}

class _TwoColumnLayout extends StatelessWidget {
  final ResumeData data;
  final ResolvedTemplateTheme theme;
  final bool skillsFirst;

  const _TwoColumnLayout({
    required this.data,
    required this.theme,
    required this.skillsFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(theme.spacing.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderBlock(data: data, theme: theme),
          SizedBox(height: theme.spacing.headerSpacing),
          if (skillsFirst && theme.isVisible(data, ResumeSectionIds.skills)) ...[
            SectionTitle(
              title: theme.titleFor(data, ResumeSectionIds.skills),
              theme: theme,
            ),
            const SizedBox(height: 8),
            SkillBlock(data: data, theme: theme),
            SizedBox(height: theme.spacing.sectionSpacing),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 35,
                child: _SectionList(
                  data: data,
                  theme: theme,
                  only: [
                    if (!skillsFirst) ResumeSectionIds.skills,
                    ResumeSectionIds.education,
                    ResumeSectionIds.languages,
                    ResumeSectionIds.certifications,
                    ResumeSectionIds.interests,
                    ResumeSectionIds.awards,
                  ],
                ),
              ),
              SizedBox(width: theme.spacing.columnSpacing),
              Expanded(
                flex: 65,
                child: _SectionList(
                  data: data,
                  theme: theme,
                  except: const [
                    ResumeSectionIds.skills,
                    ResumeSectionIds.education,
                    ResumeSectionIds.languages,
                    ResumeSectionIds.certifications,
                    ResumeSectionIds.interests,
                    ResumeSectionIds.awards,
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineLayout extends StatelessWidget {
  final ResumeData data;
  final ResolvedTemplateTheme theme;

  const _TimelineLayout({required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(theme.spacing.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderBlock(data: data, theme: theme),
          SizedBox(height: theme.spacing.headerSpacing),
          _SectionList(data: data, theme: theme),
        ],
      ),
    );
  }
}

class _AsymmetricLayout extends StatelessWidget {
  final ResumeData data;
  final ResolvedTemplateTheme theme;

  const _AsymmetricLayout({required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredBox(
          color: theme.colors.primary,
          child: const SizedBox(width: 10),
        ),
        Expanded(
          child: _ClipOverflow(
            alignment: Alignment.topLeft,
            child: Padding(
            padding: EdgeInsets.all(theme.spacing.pageMargin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.fullName.trim().isEmpty
                                ? 'Your Name'
                                : data.fullName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.nameStyle(),
                          ),
                          Text(
                            data.jobTitle.trim().isEmpty
                                ? 'Job Title'
                                : data.jobTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.jobStyle(),
                          ),
                        ],
                      ),
                    ),
                    if (theme.showPhoto)
                      ProfilePhoto(data: data, theme: theme, size: 76),
                  ],
                ),
                const SizedBox(height: 8),
                ContactRow(data: data, theme: theme),
                SizedBox(height: theme.spacing.headerSpacing),
                _SectionList(data: data, theme: theme),
              ],
            ),
          ),
          ),
        ),
      ],
    );
  }
}

class _InternationalLayout extends StatelessWidget {
  final ResumeData data;
  final ResolvedTemplateTheme theme;

  const _InternationalLayout({required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    Widget cell(String label, String value) {
      if (value.trim().isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.mutedStyle().copyWith(fontSize: 8.5, letterSpacing: 0.6),
              ),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.bodyStyle(),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(theme.spacing.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (theme.showPhoto) ...[
                ProfilePhoto(data: data, theme: theme, size: 92),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.fullName.trim().isEmpty ? 'Your Name' : data.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.nameStyle(),
                    ),
                    Text(
                      data.jobTitle.trim().isEmpty ? 'Job Title' : data.jobTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.jobStyle(),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 24,
                      runSpacing: 4,
                      children: [
                        cell('Email', data.email),
                        cell('Phone', data.phone),
                        cell('Location', data.displayLocation),
                        cell('Website', data.website),
                        cell('LinkedIn', data.linkedin),
                        cell('GitHub', data.github),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacing.headerSpacing),
          _SectionList(data: data, theme: theme),
        ],
      ),
    );
  }
}

class _HeaderBlock extends StatelessWidget {
  final ResumeData data;
  final ResolvedTemplateTheme theme;
  final bool centered;

  const _HeaderBlock({
    required this.data,
    required this.theme,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = Text(
      data.fullName.trim().isEmpty ? 'Your Name' : data.fullName,
      textAlign: centered ? TextAlign.center : TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.nameStyle(),
    );
    final job = Text(
      data.jobTitle.trim().isEmpty ? 'Job Title' : data.jobTitle,
      textAlign: centered ? TextAlign.center : TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.jobStyle(),
    );
    if (centered) {
      return Column(
        children: [
          if (theme.showPhoto) ProfilePhoto(data: data, theme: theme, size: 72),
          name,
          job,
          const SizedBox(height: 8),
          ContactRow(
            data: data,
            theme: theme,
            alignment: WrapAlignment.center,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [name, job],
              ),
            ),
            if (theme.showPhoto)
              ProfilePhoto(data: data, theme: theme, size: 70),
          ],
        ),
        const SizedBox(height: 8),
        ContactRow(data: data, theme: theme),
      ],
    );
  }
}

class _SectionList extends StatelessWidget {
  final ResumeData data;
  final ResolvedTemplateTheme theme;
  final List<String>? only;
  final List<String>? except;
  final bool light;
  final bool numbered;
  final bool dense;

  const _SectionList({
    required this.data,
    required this.theme,
    this.only,
    this.except,
    this.light = false,
    this.numbered = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final ids = theme.sectionOrder.where((id) {
      if (only != null && !only!.contains(id)) return false;
      if (except != null && except!.contains(id)) return false;
      return theme.isVisible(data, id);
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < ids.length; i++) ...[
          if (i > 0) SizedBox(height: dense ? 10 : theme.spacing.sectionSpacing),
          _section(ids[i], i),
        ],
      ],
    );
  }

  Widget _section(String id, int index) {
    final title = theme.titleFor(data, id);
    final heading = numbered
        ? Row(
            children: [
              Text(
                (index + 1).toString().padLeft(2, '0'),
                style: theme.headingStyle(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SectionTitle(title: title, theme: theme, light: light),
              ),
            ],
          )
        : SectionTitle(title: title, theme: theme, light: light);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading,
        const SizedBox(height: 8),
        _SectionBody(id: id, data: data, theme: theme, light: light, dense: dense),
      ],
    );
  }
}

class _SectionBody extends StatelessWidget {
  final String id;
  final ResumeData data;
  final ResolvedTemplateTheme theme;
  final bool light;
  final bool dense;

  const _SectionBody({
    required this.id,
    required this.data,
    required this.theme,
    required this.light,
    required this.dense,
  });

  @override
  Widget build(BuildContext context) {
    switch (id) {
      case ResumeSectionIds.summary:
        return Text(
          data.summary,
          maxLines: dense ? 6 : 12,
          overflow: TextOverflow.ellipsis,
          style: theme.bodyStyle().copyWith(
                color: light ? theme.colors.onSidebar : theme.colors.text,
              ),
        );
      case ResumeSectionIds.experience:
        return Column(
          children: [
            for (final item in data.experience.where((item) => item.hasContent))
              Padding(
                padding: EdgeInsets.only(bottom: dense ? 6 : theme.spacing.itemSpacing),
                child: ExperienceItemView(
                  item: item,
                  theme: theme,
                  compact: dense,
                ),
              ),
          ],
        );
      case ResumeSectionIds.education:
        return Column(
          children: [
            for (final item in data.education.where((item) => item.hasContent))
              Padding(
                padding: EdgeInsets.only(bottom: dense ? 6 : theme.spacing.itemSpacing),
                child: EducationItemView(item: item, theme: theme),
              ),
          ],
        );
      case ResumeSectionIds.skills:
        return SkillBlock(data: data, theme: theme, light: light);
      case ResumeSectionIds.languages:
        return LanguageBlock(data: data, theme: theme, light: light);
      case ResumeSectionIds.projects:
        return Column(
          children: [
            for (final item in data.projects.where((item) => item.hasContent))
              _simpleItem(
                item.name,
                [
                  if (item.date.isNotEmpty) item.date,
                  if (item.technologies.isNotEmpty) item.technologies.join(', '),
                ].join('  •  '),
                item.description,
              ),
          ],
        );
      case ResumeSectionIds.certifications:
        return Column(
          children: [
            for (final item in data.certifications.where((item) => item.hasContent))
              _simpleItem(item.name, [item.organization, item.date].where((e) => e.isNotEmpty).join('  •  '), ''),
          ],
        );
      case ResumeSectionIds.awards:
        return Column(
          children: [
            for (final item in data.awards.where((item) => item.hasContent))
              _simpleItem(item.title, [item.organization, item.date].where((e) => e.isNotEmpty).join('  •  '), item.description),
          ],
        );
      case ResumeSectionIds.volunteer:
        return Column(
          children: [
            for (final item in data.volunteer.where((item) => item.hasContent))
              _simpleItem(item.role, [item.organization, item.duration].where((e) => e.isNotEmpty).join('  •  '), item.description),
          ],
        );
      case ResumeSectionIds.publications:
        return Column(
          children: [
            for (final item in data.publications.where((item) => item.hasContent))
              _simpleItem(item.title, [item.publisher, item.date].where((e) => e.isNotEmpty).join('  •  '), item.description),
          ],
        );
      case ResumeSectionIds.references:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.references
              .where((item) => item.trim().isNotEmpty)
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    '• $item',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodyStyle().copyWith(
                          color: light ? theme.colors.onSidebar : theme.colors.text,
                        ),
                  ),
                ),
              )
              .toList(),
        );
      case ResumeSectionIds.interests:
        return Text(
          data.interests.join('  •  '),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: theme.bodyStyle().copyWith(
                color: light ? theme.colors.onSidebar : theme.colors.text,
              ),
        );
      default:
        CustomSection? custom;
        for (final item in data.customSections) {
          if (item.id == id) custom = item;
        }
        if (custom == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (custom.content.trim().isNotEmpty)
              Text(
                custom.content,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: theme.bodyStyle().copyWith(
                      color: light ? theme.colors.onSidebar : theme.colors.text,
                    ),
              ),
            ...custom.bullets
                .where((item) => item.trim().isNotEmpty)
                .map(
                  (item) => Text(
                    '• $item',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodyStyle(),
                  ),
                ),
          ],
        );
    }
  }

  Widget _simpleItem(String title, String meta, String body) {
    return Padding(
      padding: EdgeInsets.only(bottom: dense ? 6 : theme.spacing.itemSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.bodyStyle().copyWith(
                  fontWeight: FontWeight.w700,
                  color: light ? theme.colors.onSidebar : theme.colors.text,
                ),
          ),
          if (meta.trim().isNotEmpty)
            Text(
              meta,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.mutedStyle().copyWith(
                    color: light ? theme.colors.onSidebar.withValues(alpha: 0.8) : theme.colors.muted,
                  ),
            ),
          if (body.trim().isNotEmpty)
            Text(
              body,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.bodyStyle().copyWith(
                    color: light ? theme.colors.onSidebar : theme.colors.text,
                  ),
            ),
        ],
      ),
    );
  }
}
