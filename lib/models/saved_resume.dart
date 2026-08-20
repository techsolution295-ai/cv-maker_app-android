import 'package:cv_ganerator/models/resume_data.dart';
import 'package:cv_ganerator/features/templates/models/resume_template.dart';

class SavedResume {
  final String id;
  final String title;
  final ResumeData data;
  final DateTime updatedAt;
  final String templateId;
  final TemplateCustomization customization;

  SavedResume({
    required this.id,
    required this.title,
    required this.data,
    required this.updatedAt,
    this.templateId = 'ats_classic',
    this.customization = const TemplateCustomization(),
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'data': data.toMap(),
        'updatedAt': updatedAt.toIso8601String(),
        'templateId': templateId,
        'customization': customization.toMap(),
      };

  factory SavedResume.fromMap(Map<String, dynamic> map) => SavedResume(
        id: map['id'] ?? '',
        title: map['title'] ?? 'Untitled Resume',
        data: ResumeData.fromMap(map['data'] as Map<String, dynamic>? ?? {}),
        updatedAt: _parseDate(map['updatedAt']),
        templateId: map['templateId'] ?? 'ats_classic',
        customization: TemplateCustomization.fromMap(
          map['customization'] is Map
              ? Map<String, dynamic>.from(map['customization'] as Map)
              : null,
        ),
      );

  SavedResume copyWith({
    String? id,
    String? title,
    ResumeData? data,
    DateTime? updatedAt,
    String? templateId,
    TemplateCustomization? customization,
  }) {
    return SavedResume(
      id: id ?? this.id,
      title: title ?? this.title,
      data: data ?? this.data,
      updatedAt: updatedAt ?? this.updatedAt,
      templateId: templateId ?? this.templateId,
      customization: customization ?? this.customization,
    );
  }
}

DateTime _parseDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}
