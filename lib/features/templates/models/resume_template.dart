import 'package:flutter/material.dart';

enum TemplateCategory {
  ats,
  modern,
  executive,
  creative,
  tech,
  academic,
  elegant,
  additional,
}

enum TemplateLayoutType {
  atsSingle,
  atsClean,
  modernSplit,
  modernSidebar,
  modernTimeline,
  twoColumn,
  rightSidebar,
  headerBand,
  executiveCenter,
  creativeAsymmetric,
  creativeGradient,
  techGrid,
  academic,
  elegantSerif,
  compact,
  international,
}

enum HeaderStyle { left, center, banner, split, stacked, sidebar }

enum PhotoStyle { none, circle, square, rectangle }

enum SkillStyle { chips, bars, list, columns, commaList, boxed }

enum ExperienceStyle { classic, timeline, boxed, compact, datedLeft }

enum EducationStyle { classic, compact, twoCol }

enum DividerStyle { none, thin, thick, accent, doubleLine, dashed }

enum SectionTitleStyle { uppercase, underline, boxed, sidebarBar, numbered, minimal }

enum PageSizeOption { a4, usLetter }

enum PhotoMode { auto, show, hide }

class TemplateColors {
  final Color primary;
  final Color secondary;
  final Color text;
  final Color muted;
  final Color surface;
  final Color sidebar;
  final Color onSidebar;
  final Color rule;

  const TemplateColors({
    required this.primary,
    this.secondary = const Color(0xFF334155),
    this.text = const Color(0xFF1F2937),
    this.muted = const Color(0xFF6B7280),
    this.surface = const Color(0xFFF8FAFC),
    this.sidebar = const Color(0xFF0F172A),
    this.onSidebar = const Color(0xFFF8FAFC),
    this.rule = const Color(0xFFD1D5DB),
  });

  TemplateColors copyWith({
    Color? primary,
    Color? secondary,
    Color? text,
    Color? muted,
    Color? surface,
    Color? sidebar,
    Color? onSidebar,
    Color? rule,
  }) {
    return TemplateColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      surface: surface ?? this.surface,
      sidebar: sidebar ?? this.sidebar,
      onSidebar: onSidebar ?? this.onSidebar,
      rule: rule ?? this.rule,
    );
  }
}

class TemplateSpacing {
  final double pageMargin;
  final double sectionSpacing;
  final double columnSpacing;
  final double headerSpacing;
  final double itemSpacing;

  const TemplateSpacing({
    this.pageMargin = 28,
    this.sectionSpacing = 16,
    this.columnSpacing = 18,
    this.headerSpacing = 14,
    this.itemSpacing = 10,
  });

  TemplateSpacing copyWith({
    double? pageMargin,
    double? sectionSpacing,
    double? columnSpacing,
    double? headerSpacing,
    double? itemSpacing,
  }) {
    return TemplateSpacing(
      pageMargin: pageMargin ?? this.pageMargin,
      sectionSpacing: sectionSpacing ?? this.sectionSpacing,
      columnSpacing: columnSpacing ?? this.columnSpacing,
      headerSpacing: headerSpacing ?? this.headerSpacing,
      itemSpacing: itemSpacing ?? this.itemSpacing,
    );
  }
}

class TemplateTypography {
  final String headingFont;
  final String bodyFont;
  final double nameSize;
  final double headingSize;
  final double bodySize;
  final double lineHeight;
  final double letterSpacing;

  const TemplateTypography({
    this.headingFont = 'Inter',
    this.bodyFont = 'Inter',
    this.nameSize = 26,
    this.headingSize = 12,
    this.bodySize = 10.5,
    this.lineHeight = 1.35,
    this.letterSpacing = 0.2,
  });

  TemplateTypography copyWith({
    String? headingFont,
    String? bodyFont,
    double? nameSize,
    double? headingSize,
    double? bodySize,
    double? lineHeight,
    double? letterSpacing,
  }) {
    return TemplateTypography(
      headingFont: headingFont ?? this.headingFont,
      bodyFont: bodyFont ?? this.bodyFont,
      nameSize: nameSize ?? this.nameSize,
      headingSize: headingSize ?? this.headingSize,
      bodySize: bodySize ?? this.bodySize,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
    );
  }
}

class TemplateBorders {
  final double radius;
  final double width;

  const TemplateBorders({this.radius = 4, this.width = 1});
}

class ResumeTemplate {
  final String id;
  final String name;
  final TemplateCategory category;
  final String description;
  final List<String> tags;
  final List<String> bestFor;
  final List<String> features;
  final bool atsFriendly;
  final bool featured;
  final bool popular;
  final TemplateLayoutType layoutType;
  final HeaderStyle headerStyle;
  final PhotoStyle photoStyle;
  final SkillStyle skillStyle;
  final ExperienceStyle experienceStyle;
  final EducationStyle educationStyle;
  final DividerStyle dividerStyle;
  final SectionTitleStyle sectionTitleStyle;
  final TemplateColors colors;
  final TemplateTypography typography;
  final TemplateSpacing spacing;
  final TemplateBorders borders;
  final double sidebarRatio;
  final List<String> defaultSectionOrder;
  final Set<String> accentTargets;
  final int pageCount;

  const ResumeTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.tags,
    required this.bestFor,
    required this.layoutType,
    required this.colors,
    this.features = const ['A4', 'US Letter'],
    this.atsFriendly = false,
    this.featured = false,
    this.popular = false,
    this.headerStyle = HeaderStyle.left,
    this.photoStyle = PhotoStyle.none,
    this.skillStyle = SkillStyle.list,
    this.experienceStyle = ExperienceStyle.classic,
    this.educationStyle = EducationStyle.classic,
    this.dividerStyle = DividerStyle.thin,
    this.sectionTitleStyle = SectionTitleStyle.uppercase,
    this.typography = const TemplateTypography(),
    this.spacing = const TemplateSpacing(),
    this.borders = const TemplateBorders(),
    this.sidebarRatio = 0.34,
    this.defaultSectionOrder = const [
      'summary',
      'experience',
      'education',
      'skills',
      'projects',
      'certifications',
      'languages',
      'awards',
      'volunteer',
      'publications',
      'references',
      'interests',
    ],
    this.accentTargets = const {'headers', 'lines', 'icons'},
    this.pageCount = 1,
  });

  String get pageCountLabel => pageCount <= 1 ? '1 Page' : '$pageCount Pages';

  String get categoryLabel {
    switch (category) {
      case TemplateCategory.ats:
        return 'ATS';
      case TemplateCategory.modern:
        return 'Modern';
      case TemplateCategory.executive:
        return 'Executive';
      case TemplateCategory.creative:
        return 'Creative';
      case TemplateCategory.tech:
        return 'Tech';
      case TemplateCategory.academic:
        return 'Academic';
      case TemplateCategory.elegant:
        return 'Elegant';
      case TemplateCategory.additional:
        return 'Professional';
    }
  }
}

class TemplateCustomization {
  final Color? accentColor;
  final String? fontFamily;
  final double? nameSize;
  final double? headingSize;
  final double? bodySize;
  final double? lineHeight;
  final double? letterSpacing;
  final double? pageMargin;
  final double? sectionSpacing;
  final double? columnSpacing;
  final double? headerSpacing;
  final PageSizeOption pageSize;
  final PhotoMode photoMode;
  final List<String> sectionOrder;
  final Map<String, bool> sectionVisibility;
  final Map<String, String> sectionTitles;

  const TemplateCustomization({
    this.accentColor,
    this.fontFamily,
    this.nameSize,
    this.headingSize,
    this.bodySize,
    this.lineHeight,
    this.letterSpacing,
    this.pageMargin,
    this.sectionSpacing,
    this.columnSpacing,
    this.headerSpacing,
    this.pageSize = PageSizeOption.a4,
    this.photoMode = PhotoMode.auto,
    this.sectionOrder = const [],
    this.sectionVisibility = const {},
    this.sectionTitles = const {},
  });

  TemplateCustomization copyWith({
    Color? accentColor,
    String? fontFamily,
    double? nameSize,
    double? headingSize,
    double? bodySize,
    double? lineHeight,
    double? letterSpacing,
    double? pageMargin,
    double? sectionSpacing,
    double? columnSpacing,
    double? headerSpacing,
    PageSizeOption? pageSize,
    PhotoMode? photoMode,
    List<String>? sectionOrder,
    Map<String, bool>? sectionVisibility,
    Map<String, String>? sectionTitles,
    bool clearAccent = false,
  }) {
    return TemplateCustomization(
      accentColor: clearAccent ? null : (accentColor ?? this.accentColor),
      fontFamily: fontFamily ?? this.fontFamily,
      nameSize: nameSize ?? this.nameSize,
      headingSize: headingSize ?? this.headingSize,
      bodySize: bodySize ?? this.bodySize,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      pageMargin: pageMargin ?? this.pageMargin,
      sectionSpacing: sectionSpacing ?? this.sectionSpacing,
      columnSpacing: columnSpacing ?? this.columnSpacing,
      headerSpacing: headerSpacing ?? this.headerSpacing,
      pageSize: pageSize ?? this.pageSize,
      photoMode: photoMode ?? this.photoMode,
      sectionOrder: sectionOrder ?? this.sectionOrder,
      sectionVisibility: sectionVisibility ?? this.sectionVisibility,
      sectionTitles: sectionTitles ?? this.sectionTitles,
    );
  }

  Map<String, dynamic> toMap() => {
        'accentColor': accentColor?.toARGB32(),
        'fontFamily': fontFamily,
        'nameSize': nameSize,
        'headingSize': headingSize,
        'bodySize': bodySize,
        'lineHeight': lineHeight,
        'letterSpacing': letterSpacing,
        'pageMargin': pageMargin,
        'sectionSpacing': sectionSpacing,
        'columnSpacing': columnSpacing,
        'headerSpacing': headerSpacing,
        'pageSize': pageSize.name,
        'photoMode': photoMode.name,
        'sectionOrder': sectionOrder,
        'sectionVisibility': sectionVisibility,
        'sectionTitles': sectionTitles,
      };

  factory TemplateCustomization.fromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return const TemplateCustomization();
    final accent = map['accentColor'];
    return TemplateCustomization(
      accentColor: accent is int ? Color(accent) : null,
      fontFamily: map['fontFamily'] as String?,
      nameSize: (map['nameSize'] as num?)?.toDouble(),
      headingSize: (map['headingSize'] as num?)?.toDouble(),
      bodySize: (map['bodySize'] as num?)?.toDouble(),
      lineHeight: (map['lineHeight'] as num?)?.toDouble(),
      letterSpacing: (map['letterSpacing'] as num?)?.toDouble(),
      pageMargin: (map['pageMargin'] as num?)?.toDouble(),
      sectionSpacing: (map['sectionSpacing'] as num?)?.toDouble(),
      columnSpacing: (map['columnSpacing'] as num?)?.toDouble(),
      headerSpacing: (map['headerSpacing'] as num?)?.toDouble(),
      pageSize: PageSizeOption.values.firstWhere(
        (value) => value.name == map['pageSize'],
        orElse: () => PageSizeOption.a4,
      ),
      photoMode: PhotoMode.values.firstWhere(
        (value) => value.name == map['photoMode'],
        orElse: () => PhotoMode.auto,
      ),
      sectionOrder: (map['sectionOrder'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      sectionVisibility: (map['sectionVisibility'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value == true),
          ) ??
          const {},
      sectionTitles: (map['sectionTitles'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
          ) ??
          const {},
    );
  }

  static const presetColors = <String, Color>{
    'Professional Blue': Color(0xFF1F5AA6),
    'Navy': Color(0xFF0A2540),
    'Teal': Color(0xFF0D9488),
    'Green': Color(0xFF15803D),
    'Purple': Color(0xFF6D28D9),
    'Indigo': Color(0xFF3730A3),
    'Black': Color(0xFF111827),
    'Gray': Color(0xFF4B5563),
    'Red': Color(0xFFB91C1C),
    'Orange': Color(0xFFC2410C),
  };

  static const fontOptions = [
    'Roboto',
    'Inter',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
    'Merriweather',
    'Source Sans',
    'Noto Sans',
  ];
}
