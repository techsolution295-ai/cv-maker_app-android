import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cv_ganerator/features/templates/models/resume_template.dart';
import 'package:cv_ganerator/features/templates/style/resolved_theme.dart';
import 'package:cv_ganerator/models/resume_data.dart';

class ProfilePhoto extends StatelessWidget {
  final ResumeData data;
  final ResolvedTemplateTheme theme;
  final double size;

  const ProfilePhoto({
    super.key,
    required this.data,
    required this.theme,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    if (!theme.showPhoto) return const SizedBox.shrink();
    final child = data.hasPhoto
        ? Image(
            image: _provider(data.photoUrl),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initials(),
          )
        : _initials();

    switch (theme.photoStyle) {
      case PhotoStyle.square:
        return SizedBox(
          width: size,
          height: size,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.definition.borders.radius),
            child: child,
          ),
        );
      case PhotoStyle.rectangle:
        return SizedBox(
          width: size * 0.82,
          height: size,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.definition.borders.radius),
            child: child,
          ),
        );
      case PhotoStyle.circle:
        return ClipOval(
          child: SizedBox(width: size, height: size, child: child),
        );
      case PhotoStyle.none:
        return const SizedBox.shrink();
    }
  }

  Widget _initials() {
    final parts = data.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return ColoredBox(
      color: theme.colors.surface,
      child: Center(
        child: Text(
          parts.isEmpty ? 'CV' : parts,
          style: theme.headingStyle().copyWith(fontSize: size * 0.28),
        ),
      ),
    );
  }

  static ImageProvider _provider(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    if (path.startsWith('file://')) {
      return FileImage(File(path.replaceFirst('file://', '')));
    }
    return FileImage(File(path));
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final ResolvedTemplateTheme theme;
  final bool light;

  const SectionTitle({
    super.key,
    required this.title,
    required this.theme,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = light ? theme.colors.onSidebar : null;
    final label = theme.definition.sectionTitleStyle == SectionTitleStyle.uppercase
        ? title.toUpperCase()
        : title;
    final text = Text(
      label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.headingStyle().copyWith(
            color: color ?? theme.headingStyle().color,
            fontSize: theme.typography.headingSize,
          ),
    );

    switch (theme.definition.sectionTitleStyle) {
      case SectionTitleStyle.underline:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text,
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: 42,
              color: light ? theme.colors.onSidebar : theme.colors.primary,
            ),
          ],
        );
      case SectionTitleStyle.boxed:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: (light ? theme.colors.onSidebar : theme.colors.primary)
              .withValues(alpha: light ? 0.15 : 0.12),
          child: text,
        );
      case SectionTitleStyle.sidebarBar:
        return Row(
          children: [
            Container(
              width: 3,
              height: 14,
              color: light ? theme.colors.onSidebar : theme.colors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(child: text),
          ],
        );
      case SectionTitleStyle.numbered:
        return text;
      case SectionTitleStyle.minimal:
        return text;
      case SectionTitleStyle.uppercase:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text,
            if (theme.definition.dividerStyle != DividerStyle.none) ...[
              const SizedBox(height: 4),
              ResumeRule(theme: theme, light: light),
            ],
          ],
        );
    }
  }
}

class ResumeRule extends StatelessWidget {
  final ResolvedTemplateTheme theme;
  final bool light;

  const ResumeRule({super.key, required this.theme, this.light = false});

  @override
  Widget build(BuildContext context) {
    final color = light ? theme.colors.onSidebar.withValues(alpha: 0.35) : theme.colors.primary;
    switch (theme.definition.dividerStyle) {
      case DividerStyle.none:
        return const SizedBox.shrink();
      case DividerStyle.thick:
        return Container(height: 2.4, color: color);
      case DividerStyle.accent:
        return Container(height: 1.6, color: color);
      case DividerStyle.doubleLine:
        return Column(
          children: [
            Container(height: 1, color: color),
            const SizedBox(height: 2),
            Container(height: 1, color: color.withValues(alpha: 0.5)),
          ],
        );
      case DividerStyle.dashed:
        return LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, 1),
              painter: _DashPainter(color: color),
            );
          },
        );
      case DividerStyle.thin:
        return Container(
          height: 1,
          color: light ? color : theme.colors.rule,
        );
    }
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  _DashPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), paint);
      x += 8;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ContactRow extends StatelessWidget {
  final ResumeData data;
  final ResolvedTemplateTheme theme;
  final bool compact;
  final Color? color;
  final bool icons;
  final WrapAlignment alignment;

  const ContactRow({
    super.key,
    required this.data,
    required this.theme,
    this.compact = false,
    this.color,
    this.icons = true,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String)>[
      if (data.email.trim().isNotEmpty) (Icons.mail_outline, data.email),
      if (data.phone.trim().isNotEmpty) (Icons.phone_outlined, data.phone),
      if (data.displayLocation.isNotEmpty)
        (Icons.location_on_outlined, data.displayLocation),
      if (data.website.trim().isNotEmpty) (Icons.language, data.website),
      if (data.linkedin.trim().isNotEmpty) (Icons.link, data.linkedin),
      if (data.github.trim().isNotEmpty) (Icons.code, data.github),
    ];
    final style = theme.mutedStyle().copyWith(color: color ?? theme.colors.muted);
    return Column(
      crossAxisAlignment: alignment == WrapAlignment.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              children: [
                if (icons) ...[
                  Icon(item.$1, size: 11, color: color ?? theme.colors.primary),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    item.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: alignment == WrapAlignment.center
                        ? TextAlign.center
                        : TextAlign.start,
                    style: style,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class SkillBlock extends StatelessWidget {
  final ResumeData data;
  final ResolvedTemplateTheme theme;
  final bool light;

  const SkillBlock({
    super.key,
    required this.data,
    required this.theme,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    final skills = data.skills
        .map(SkillItem.parse)
        .where((item) => item.name.isNotEmpty)
        .toList();
    if (skills.isEmpty) return const SizedBox.shrink();
    final color = light ? theme.colors.onSidebar : theme.colors.primary;
    final textColor = light ? theme.colors.onSidebar : theme.colors.text;

    switch (theme.definition.skillStyle) {
      case SkillStyle.commaList:
        return Text(
          skills.map((item) => item.name).join(' • '),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: theme.bodyStyle().copyWith(color: textColor),
        );
      case SkillStyle.list:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: skills
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    '• ${item.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodyStyle().copyWith(color: textColor),
                  ),
                ),
              )
              .toList(),
        );
      case SkillStyle.columns:
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.isFinite
                ? (constraints.maxWidth / 2).clamp(72.0, 140.0)
                : 120.0;
            return Wrap(
              spacing: 8,
              runSpacing: 4,
              children: skills
                  .map(
                    (item) => SizedBox(
                      width: width,
                      child: Text(
                        '• ${item.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodyStyle().copyWith(color: textColor),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        );
      case SkillStyle.chips:
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxChip = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : 200.0;
            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children: skills
                  .map(
                    (item) => ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxChip),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: color.withValues(alpha: 0.45)),
                          borderRadius: BorderRadius.circular(
                              theme.definition.borders.radius),
                          color: color.withValues(alpha: light ? 0.12 : 0.08),
                        ),
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodyStyle().copyWith(
                                color: textColor,
                                fontSize: theme.typography.bodySize - 0.5,
                              ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        );
      case SkillStyle.boxed:
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxChip = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : 200.0;
            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children: skills
                  .map(
                    (item) => ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxChip),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: light ? 0.16 : 0.1),
                          borderRadius: BorderRadius.circular(
                              theme.definition.borders.radius),
                        ),
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodyStyle().copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        );
      case SkillStyle.bars:
        return Column(
          children: skills
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: SkillBar(
                    name: item.name,
                    level: item.level,
                    theme: theme,
                    light: light,
                  ),
                ),
              )
              .toList(),
        );
    }
  }
}

class SkillBar extends StatelessWidget {
  final String name;
  final double level;
  final ResolvedTemplateTheme theme;
  final bool light;

  const SkillBar({
    super.key,
    required this.name,
    required this.level,
    required this.theme,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    final track = light
        ? theme.colors.onSidebar.withValues(alpha: 0.2)
        : theme.colors.rule;
    final fill = light ? theme.colors.onSidebar : theme.colors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.bodyStyle().copyWith(
                color: light ? theme.colors.onSidebar : theme.colors.text,
                fontSize: theme.typography.bodySize - 0.5,
              ),
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: level.clamp(0.15, 1),
            minHeight: 5,
            color: fill,
            backgroundColor: track,
          ),
        ),
      ],
    );
  }
}

class ExperienceItemView extends StatelessWidget {
  final ExperienceItem item;
  final ResolvedTemplateTheme theme;
  final bool compact;

  const ExperienceItemView({
    super.key,
    required this.item,
    required this.theme,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bullets = item.bullets;
    final style = theme.definition.experienceStyle;
    if (style == ExperienceStyle.datedLeft && !compact) {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.maxWidth.isFinite || constraints.maxWidth < 200) {
            return _body(bullets);
          }
          final dateWidth = (constraints.maxWidth * 0.28).clamp(56.0, 88.0);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: dateWidth,
                child: Text(
                  item.displayDuration,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.mutedStyle(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _body(bullets)),
            ],
          );
        },
      );
    }
    if (style == ExperienceStyle.timeline) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: _body(bullets)),
        ],
      );
    }
    if (style == ExperienceStyle.boxed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.rule),
          borderRadius: BorderRadius.circular(theme.definition.borders.radius),
        ),
        child: _body(bullets),
      );
    }
    return _body(bullets);
  }

  Widget _body(List<String> bullets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title.isEmpty ? 'Role' : item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.bodyStyle().copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          [
            if (item.company.trim().isNotEmpty) item.company,
            if (item.displayDuration.isNotEmpty) item.displayDuration,
            if (item.location.trim().isNotEmpty) item.location,
          ].join('  •  '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.mutedStyle(),
        ),
        if (bullets.isNotEmpty) ...[
          const SizedBox(height: 4),
          ...bullets.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: theme.bodyStyle()),
                  Expanded(
                    child: Text(
                      bullet,
                      style: theme.bodyStyle(),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class EducationItemView extends StatelessWidget {
  final EducationItem item;
  final ResolvedTemplateTheme theme;

  const EducationItemView({
    super.key,
    required this.item,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.displayDegree.isEmpty ? 'Degree' : item.displayDegree,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.bodyStyle().copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          [
            if (item.school.trim().isNotEmpty) item.school,
            if (item.displayYear.isNotEmpty) item.displayYear,
            if (item.grade.trim().isNotEmpty) item.grade,
          ].join('  •  '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.mutedStyle(),
        ),
        if (item.description.trim().isNotEmpty)
          Text(
            item.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.bodyStyle(),
          ),
      ],
    );
  }
}

class LanguageBlock extends StatelessWidget {
  final ResumeData data;
  final ResolvedTemplateTheme theme;
  final bool light;

  const LanguageBlock({
    super.key,
    required this.data,
    required this.theme,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = data.languages
        .map(LanguageItem.parse)
        .where((item) => item.language.isNotEmpty)
        .toList();
    final color = light ? theme.colors.onSidebar : theme.colors.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                item.display,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.bodyStyle().copyWith(color: color),
              ),
            ),
          )
          .toList(),
    );
  }
}
