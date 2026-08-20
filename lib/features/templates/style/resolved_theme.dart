import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cv_ganerator/features/templates/models/resume_template.dart';
import 'package:cv_ganerator/models/resume_data.dart';

class TemplateFonts {
  static TextStyle style(
    String family, {
    double size = 12,
    FontWeight weight = FontWeight.w400,
    Color color = const Color(0xFF1F2937),
    double height = 1.35,
    double letterSpacing = 0,
    FontStyle fontStyle = FontStyle.normal,
    bool bundledOnly = false,
  }) {
    final base = TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      fontFamily: bundledOnly ? 'SpaceGrotesk' : null,
    );
    if (bundledOnly) return base;
    try {
      switch (family) {
        case 'Roboto':
          return GoogleFonts.roboto(textStyle: base);
        case 'Open Sans':
          return GoogleFonts.openSans(textStyle: base);
        case 'Lato':
          return GoogleFonts.lato(textStyle: base);
        case 'Montserrat':
          return GoogleFonts.montserrat(textStyle: base);
        case 'Poppins':
          return GoogleFonts.poppins(textStyle: base);
        case 'Merriweather':
          return GoogleFonts.merriweather(textStyle: base);
        case 'Source Sans':
          return GoogleFonts.sourceSans3(textStyle: base);
        case 'Noto Sans':
          return GoogleFonts.notoSans(textStyle: base);
        case 'Inter':
        default:
          return GoogleFonts.inter(textStyle: base);
      }
    } catch (_) {
      return base.copyWith(fontFamily: 'SpaceGrotesk');
    }
  }
}

class ResolvedTemplateTheme {
  final ResumeTemplate definition;
  final TemplateColors colors;
  final TemplateTypography typography;
  final TemplateSpacing spacing;
  final PageSizeOption pageSize;
  final PhotoStyle photoStyle;
  final bool showPhoto;
  final List<String> sectionOrder;
  final Map<String, bool> sectionVisibility;
  final Map<String, String> sectionTitles;
  final bool bundledFonts;

  const ResolvedTemplateTheme({
    required this.definition,
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.pageSize,
    required this.photoStyle,
    required this.showPhoto,
    required this.sectionOrder,
    required this.sectionVisibility,
    required this.sectionTitles,
    this.bundledFonts = false,
  });

  Size get pageSizePx {
    switch (pageSize) {
      case PageSizeOption.usLetter:
        return const Size(816, 1056);
      case PageSizeOption.a4:
        return const Size(794, 1123);
    }
  }

  TextStyle nameStyle() => TemplateFonts.style(
        typography.headingFont,
        size: typography.nameSize,
        weight: FontWeight.w700,
        color: colors.text,
        height: 1.15,
        letterSpacing: typography.letterSpacing,
        bundledOnly: bundledFonts,
      );

  TextStyle jobStyle() => TemplateFonts.style(
        typography.bodyFont,
        size: typography.bodySize + 1.5,
        weight: FontWeight.w500,
        color: colors.primary,
        height: typography.lineHeight,
        bundledOnly: bundledFonts,
      );

  TextStyle headingStyle() => TemplateFonts.style(
        typography.headingFont,
        size: typography.headingSize,
        weight: FontWeight.w700,
        color: definition.accentTargets.contains('headers')
            ? colors.primary
            : colors.text,
        height: 1.2,
        letterSpacing: 0.8,
        bundledOnly: bundledFonts,
      );

  TextStyle bodyStyle() => TemplateFonts.style(
        typography.bodyFont,
        size: typography.bodySize,
        color: colors.text,
        height: typography.lineHeight,
        bundledOnly: bundledFonts,
      );

  TextStyle mutedStyle() => TemplateFonts.style(
        typography.bodyFont,
        size: typography.bodySize - 0.5,
        color: colors.muted,
        height: typography.lineHeight,
        bundledOnly: bundledFonts,
      );

  static ResolvedTemplateTheme resolve({
    required ResumeTemplate definition,
    required ResumeData data,
    TemplateCustomization? customization,
    bool thumbnail = false,
  }) {
    final custom = customization ?? const TemplateCustomization();
    var colors = definition.colors;
    if (custom.accentColor != null) {
      final accent = custom.accentColor!;
      colors = colors.copyWith(
        primary: definition.accentTargets.contains('headers') ||
                definition.accentTargets.contains('lines') ||
                definition.accentTargets.contains('icons')
            ? accent
            : colors.primary,
        sidebar: definition.accentTargets.contains('sidebar')
            ? accent
            : colors.sidebar,
      );
    }

    final font = custom.fontFamily;
    final typography = definition.typography.copyWith(
      headingFont: font ?? definition.typography.headingFont,
      bodyFont: font ?? definition.typography.bodyFont,
      nameSize: custom.nameSize ?? definition.typography.nameSize,
      headingSize: custom.headingSize ?? definition.typography.headingSize,
      bodySize: custom.bodySize ?? definition.typography.bodySize,
      lineHeight: custom.lineHeight ?? definition.typography.lineHeight,
      letterSpacing: custom.letterSpacing ?? definition.typography.letterSpacing,
    );

    final spacing = definition.spacing.copyWith(
      pageMargin: custom.pageMargin ?? definition.spacing.pageMargin,
      sectionSpacing: custom.sectionSpacing ?? definition.spacing.sectionSpacing,
      columnSpacing: custom.columnSpacing ?? definition.spacing.columnSpacing,
      headerSpacing: custom.headerSpacing ?? definition.spacing.headerSpacing,
    );

    PhotoStyle photoStyle = definition.photoStyle;
    var showPhoto = photoStyle != PhotoStyle.none;
    switch (custom.photoMode) {
      case PhotoMode.hide:
        showPhoto = false;
        photoStyle = PhotoStyle.none;
        break;
      case PhotoMode.show:
        showPhoto = true;
        if (photoStyle == PhotoStyle.none) photoStyle = PhotoStyle.circle;
        break;
      case PhotoMode.auto:
        break;
    }

    var resolvedTypography = typography;
    var resolvedSpacing = spacing;
    if (thumbnail) {
      showPhoto = false;
      const scale = 240 / 794;
      resolvedTypography = typography.copyWith(
        nameSize: typography.nameSize * scale,
        headingSize: typography.headingSize * scale,
        bodySize: (typography.bodySize * scale).clamp(5.0, 8.0),
        lineHeight: 1.2,
      );
      resolvedSpacing = spacing.copyWith(
        pageMargin: (spacing.pageMargin * scale).clamp(6.0, 14.0),
        sectionSpacing: (spacing.sectionSpacing * scale).clamp(4.0, 10.0),
        headerSpacing: (spacing.headerSpacing * scale).clamp(4.0, 8.0),
        itemSpacing: (spacing.itemSpacing * scale).clamp(3.0, 6.0),
        columnSpacing: (spacing.columnSpacing * scale).clamp(4.0, 10.0),
      );
    }

    final order = [
      ...custom.sectionOrder,
      ...data.sectionOrder,
      ...definition.defaultSectionOrder,
      ...data.customSections.map((section) => section.id),
    ];
    final seen = <String>{};
    final sectionOrder = <String>[];
    for (final id in order) {
      if (id.trim().isEmpty || seen.contains(id)) continue;
      seen.add(id);
      sectionOrder.add(id);
    }

    return ResolvedTemplateTheme(
      definition: definition,
      colors: colors,
      typography: resolvedTypography,
      spacing: resolvedSpacing,
      pageSize: custom.pageSize,
      photoStyle: thumbnail ? PhotoStyle.none : photoStyle,
      showPhoto: thumbnail ? false : showPhoto,
      sectionOrder: sectionOrder,
      sectionVisibility: {
        ...data.sectionVisibility,
        ...custom.sectionVisibility,
      },
      sectionTitles: {
        ...data.sectionTitles,
        ...custom.sectionTitles,
      },
      bundledFonts: thumbnail,
    );
  }

  bool isVisible(ResumeData data, String id) {
    if (sectionVisibility.containsKey(id)) return sectionVisibility[id] == true;
    return data.sectionHasContent(id);
  }

  String titleFor(ResumeData data, String id) {
    return sectionTitles[id] ?? data.titleForSection(id);
  }
}
