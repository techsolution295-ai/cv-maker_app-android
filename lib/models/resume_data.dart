class ResumeData {
  final String fullName;
  final String jobTitle;
  final String email;
  final String phone;
  final String location;
  final String summary;
  final List<String> skills;
  final List<ExperienceItem> experience;
  final List<EducationItem> education;
  final String photoUrl;
  final List<String> languages;
  final List<String> references;
  final String website;
  final String linkedin;

  const ResumeData({
    required this.fullName,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.location,
    required this.summary,
    required this.skills,
    required this.experience,
    required this.education,
    this.photoUrl = '',
    this.languages = const [],
    this.references = const [],
    this.website = '',
    this.linkedin = '',
  });

  ResumeData copyWith({
    String? fullName,
    String? jobTitle,
    String? email,
    String? phone,
    String? location,
    String? summary,
    List<String>? skills,
    List<ExperienceItem>? experience,
    List<EducationItem>? education,
    String? photoUrl,
    List<String>? languages,
    List<String>? references,
    String? website,
    String? linkedin,
  }) {
    return ResumeData(
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      summary: summary ?? this.summary,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      photoUrl: photoUrl ?? this.photoUrl,
      languages: languages ?? this.languages,
      references: references ?? this.references,
      website: website ?? this.website,
      linkedin: linkedin ?? this.linkedin,
    );
  }

  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'jobTitle': jobTitle,
    'email': email,
    'phone': phone,
    'location': location,
    'summary': summary,
    'skills': skills,
    'experience': experience.map((item) => item.toMap()).toList(),
    'education': education.map((item) => item.toMap()).toList(),
    'photoUrl': photoUrl,
    'languages': languages,
    'references': references,
    'website': website,
    'linkedin': linkedin,
  };

  factory ResumeData.fromMap(Map<String, dynamic> map) => ResumeData(
    fullName: map['fullName'] ?? '',
    jobTitle: map['jobTitle'] ?? '',
    email: map['email'] ?? '',
    phone: map['phone'] ?? '',
    location: map['location'] ?? '',
    summary: map['summary'] ?? '',
    skills: (map['skills'] as List<dynamic>?)?.cast<String>() ?? [],
    experience:
        (map['experience'] as List<dynamic>?)
            ?.map((item) => ExperienceItem.fromMap(item as Map<String, dynamic>))
            .toList() ??
        [],
    education:
        (map['education'] as List<dynamic>?)
            ?.map((item) => EducationItem.fromMap(item as Map<String, dynamic>))
            .toList() ??
        [],
    photoUrl: map['photoUrl'] ?? '',
    languages: (map['languages'] as List<dynamic>?)?.cast<String>() ?? [],
    references: (map['references'] as List<dynamic>?)?.cast<String>() ?? [],
    website: map['website'] ?? '',
    linkedin: map['linkedin'] ?? '',
  );
}

class ExperienceItem {
  final String title;
  final String company;
  final String duration;
  final String description;

  const ExperienceItem({
    required this.title,
    required this.company,
    required this.duration,
    required this.description,
  });

  ExperienceItem copyWith({
    String? title,
    String? company,
    String? duration,
    String? description,
  }) {
    return ExperienceItem(
      title: title ?? this.title,
      company: company ?? this.company,
      duration: duration ?? this.duration,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'company': company,
    'duration': duration,
    'description': description,
  };

  factory ExperienceItem.fromMap(Map<String, dynamic> map) => ExperienceItem(
    title: map['title'] ?? '',
    company: map['company'] ?? '',
    duration: map['duration'] ?? '',
    description: map['description'] ?? '',
  );
}

class EducationItem {
  final String degree;
  final String school;
  final String year;

  const EducationItem({
    required this.degree,
    required this.school,
    required this.year,
  });

  EducationItem copyWith({
    String? degree,
    String? school,
    String? year,
  }) {
    return EducationItem(
      degree: degree ?? this.degree,
      school: school ?? this.school,
      year: year ?? this.year,
    );
  }

  Map<String, dynamic> toMap() => {
    'degree': degree,
    'school': school,
    'year': year,
  };

  factory EducationItem.fromMap(Map<String, dynamic> map) => EducationItem(
    degree: map['degree'] ?? '',
    school: map['school'] ?? '',
    year: map['year'] ?? '',
  );
}
