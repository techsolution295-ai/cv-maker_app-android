class CoverLetter {
  final String id;
  final String userId;
  final String resumeId;
  final String companyName;
  final String jobTitle;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  CoverLetter({
    required this.id,
    required this.userId,
    required this.resumeId,
    required this.companyName,
    required this.jobTitle,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'resumeId': resumeId,
    'companyName': companyName,
    'jobTitle': jobTitle,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory CoverLetter.fromMap(Map<String, dynamic> map) => CoverLetter(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    resumeId: map['resumeId'] ?? '',
    companyName: map['companyName'] ?? '',
    jobTitle: map['jobTitle'] ?? '',
    content: map['content'] ?? '',
    createdAt: _parseDate(map['createdAt']),
    updatedAt: _parseDate(map['updatedAt']),
  );

  CoverLetter copyWith({
    String? id,
    String? userId,
    String? resumeId,
    String? companyName,
    String? jobTitle,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CoverLetter(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    resumeId: resumeId ?? this.resumeId,
    companyName: companyName ?? this.companyName,
    jobTitle: jobTitle ?? this.jobTitle,
    content: content ?? this.content,
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
