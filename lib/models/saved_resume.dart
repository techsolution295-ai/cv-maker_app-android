import 'package:cv_ganerator/models/resume_data.dart';

class SavedResume {
  final String id;
  final String title;
  final ResumeData data;
  final DateTime updatedAt;

  SavedResume({
    required this.id,
    required this.title,
    required this.data,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'data': data.toMap(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory SavedResume.fromMap(Map<String, dynamic> map) => SavedResume(
    id: map['id'] ?? '',
    title: map['title'] ?? 'Untitled Resume',
    data: ResumeData.fromMap(map['data'] as Map<String, dynamic>? ?? {}),
    updatedAt: _parseDate(map['updatedAt']),
  );
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
