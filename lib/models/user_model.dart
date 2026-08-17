class User {
  final String id;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? profileImageUrl;
  final bool isGuest;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    this.email,
    this.fullName,
    this.phone,
    this.profileImageUrl,
    this.isGuest = false,
    this.isPremium = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'phone': phone,
    'profileImageUrl': profileImageUrl,
    'isGuest': isGuest,
    'isPremium': isPremium,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'] ?? '',
    email: map['email'],
    fullName: map['fullName'],
    phone: map['phone'],
    profileImageUrl: map['profileImageUrl'],
    isGuest: map['isGuest'] ?? false,
    isPremium: map['isPremium'] ?? false,
    createdAt: _parseDate(map['createdAt']),
    updatedAt: _parseDate(map['updatedAt']),
  );

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? profileImageUrl,
    bool? isGuest,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    fullName: fullName ?? this.fullName,
    phone: phone ?? this.phone,
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    isGuest: isGuest ?? this.isGuest,
    isPremium: isPremium ?? this.isPremium,
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
