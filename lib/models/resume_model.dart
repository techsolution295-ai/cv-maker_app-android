class Experience {
  final String id;
  final String jobTitle;
  final String company;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String description;

  Experience({
    required this.id,
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    required this.description,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'jobTitle': jobTitle,
    'company': company,
    'location': location,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'isCurrent': isCurrent,
    'description': description,
  };

  factory Experience.fromMap(Map<String, dynamic> map) => Experience(
    id: map['id'] ?? '',
    jobTitle: map['jobTitle'] ?? '',
    company: map['company'] ?? '',
    location: map['location'] ?? '',
    startDate: _parseDate(map['startDate']),
    endDate: _parseNullableDate(map['endDate']),
    isCurrent: map['isCurrent'] ?? false,
    description: map['description'] ?? '',
  );

  Experience copyWith({
    String? id,
    String? jobTitle,
    String? company,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    String? description,
  }) => Experience(
    id: id ?? this.id,
    jobTitle: jobTitle ?? this.jobTitle,
    company: company ?? this.company,
    location: location ?? this.location,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    isCurrent: isCurrent ?? this.isCurrent,
    description: description ?? this.description,
  );
}

class Education {
  final String id;
  final String school;
  final String degree;
  final String field;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String? grade;
  final String? description;

  Education({
    required this.id,
    required this.school,
    required this.degree,
    required this.field,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.grade,
    this.description,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'school': school,
    'degree': degree,
    'field': field,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'isCurrent': isCurrent,
    'grade': grade,
    'description': description,
  };

  factory Education.fromMap(Map<String, dynamic> map) => Education(
    id: map['id'] ?? '',
    school: map['school'] ?? '',
    degree: map['degree'] ?? '',
    field: map['field'] ?? '',
    startDate: _parseDate(map['startDate']),
    endDate: _parseNullableDate(map['endDate']),
    isCurrent: map['isCurrent'] ?? false,
    grade: map['grade'],
    description: map['description'],
  );

  Education copyWith({
    String? id,
    String? school,
    String? degree,
    String? field,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    String? grade,
    String? description,
  }) => Education(
    id: id ?? this.id,
    school: school ?? this.school,
    degree: degree ?? this.degree,
    field: field ?? this.field,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    isCurrent: isCurrent ?? this.isCurrent,
    grade: grade ?? this.grade,
    description: description ?? this.description,
  );
}

class Resume {
  final String id;
  final String userId;
  final String title;
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final String jobTitle;
  final String summary;
  final List<Experience> experiences;
  final List<Education> education;
  final List<String> skills;
  final String templateId;
  final bool isFavorite;
  final int atsScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  Resume({
    required this.id,
    required this.userId,
    required this.title,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    required this.jobTitle,
    required this.summary,
    required this.experiences,
    required this.education,
    required this.skills,
    this.templateId = 'template_1',
    this.isFavorite = false,
    this.atsScore = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'location': location,
    'jobTitle': jobTitle,
    'summary': summary,
    'experiences': experiences.map((e) => e.toMap()).toList(),
    'education': education.map((e) => e.toMap()).toList(),
    'skills': skills,
    'templateId': templateId,
    'isFavorite': isFavorite,
    'atsScore': atsScore,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Resume.fromMap(Map<String, dynamic> map) => Resume(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    title: map['title'] ?? 'Untitled Resume',
    fullName: map['fullName'] ?? '',
    email: map['email'] ?? '',
    phone: map['phone'] ?? '',
    location: map['location'] ?? '',
    jobTitle: map['jobTitle'] ?? '',
    summary: map['summary'] ?? '',
    experiences:
        (map['experiences'] as List<dynamic>?)
            ?.map((e) => Experience.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [],
    education:
        (map['education'] as List<dynamic>?)
            ?.map((e) => Education.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [],
    skills: (map['skills'] as List<dynamic>?)?.cast<String>() ?? [],
    templateId: map['templateId'] ?? 'template_1',
    isFavorite: map['isFavorite'] ?? false,
    atsScore: map['atsScore'] ?? 0,
    createdAt: _parseDate(map['createdAt']),
    updatedAt: _parseDate(map['updatedAt']),
  );

  Resume copyWith({
    String? id,
    String? userId,
    String? title,
    String? fullName,
    String? email,
    String? phone,
    String? location,
    String? jobTitle,
    String? summary,
    List<Experience>? experiences,
    List<Education>? education,
    List<String>? skills,
    String? templateId,
    bool? isFavorite,
    int? atsScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Resume(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    location: location ?? this.location,
    jobTitle: jobTitle ?? this.jobTitle,
    summary: summary ?? this.summary,
    experiences: experiences ?? this.experiences,
    education: education ?? this.education,
    skills: skills ?? this.skills,
    templateId: templateId ?? this.templateId,
    isFavorite: isFavorite ?? this.isFavorite,
    atsScore: atsScore ?? this.atsScore,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
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

DateTime? _parseNullableDate(dynamic value) {
  if (value == null) return null;
  return _parseDate(value);
}
