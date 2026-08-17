class Template {
  final String id;
  final String name;
  final String thumbnail;
  final String preview;
  final bool isPremium;
  final String category;
  final int usageCount;

  Template({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.preview,
    this.isPremium = false,
    this.category = 'Modern',
    this.usageCount = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'thumbnail': thumbnail,
    'preview': preview,
    'isPremium': isPremium,
    'category': category,
    'usageCount': usageCount,
  };

  factory Template.fromMap(Map<String, dynamic> map) => Template(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    thumbnail: map['thumbnail'] ?? '',
    preview: map['preview'] ?? '',
    isPremium: map['isPremium'] ?? false,
    category: map['category'] ?? 'Modern',
    usageCount: map['usageCount'] ?? 0,
  );

  Template copyWith({
    String? id,
    String? name,
    String? thumbnail,
    String? preview,
    bool? isPremium,
    String? category,
    int? usageCount,
  }) => Template(
    id: id ?? this.id,
    name: name ?? this.name,
    thumbnail: thumbnail ?? this.thumbnail,
    preview: preview ?? this.preview,
    isPremium: isPremium ?? this.isPremium,
    category: category ?? this.category,
    usageCount: usageCount ?? this.usageCount,
  );
}
