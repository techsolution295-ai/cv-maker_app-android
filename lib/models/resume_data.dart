class ResumeData {
  final String fullName;
  final String jobTitle;
  final String email;
  final String phone;
  final String location;
  final String address;
  final String city;
  final String country;
  final String summary;
  final List<String> skills;
  final List<ExperienceItem> experience;
  final List<EducationItem> education;
  final String photoUrl;
  final List<String> languages;
  final List<String> references;
  final String website;
  final String linkedin;
  final String github;
  final List<ProjectItem> projects;
  final List<CertificationItem> certifications;
  final List<AwardItem> awards;
  final List<VolunteerItem> volunteer;
  final List<PublicationItem> publications;
  final List<String> interests;
  final List<CustomSection> customSections;
  final List<String> sectionOrder;
  final Map<String, bool> sectionVisibility;
  final Map<String, String> sectionTitles;

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
    this.github = '',
    this.address = '',
    this.city = '',
    this.country = '',
    this.projects = const [],
    this.certifications = const [],
    this.awards = const [],
    this.volunteer = const [],
    this.publications = const [],
    this.interests = const [],
    this.customSections = const [],
    this.sectionOrder = const [],
    this.sectionVisibility = const {},
    this.sectionTitles = const {},
  });

  String get professionalSummary => summary;
  String get profileImage => photoUrl;

  String get displayLocation {
    final parts = <String>[
      if (city.trim().isNotEmpty) city.trim(),
      if (country.trim().isNotEmpty) country.trim(),
    ];
    if (parts.isNotEmpty) return parts.join(', ');
    if (address.trim().isNotEmpty) return address.trim();
    return location.trim();
  }

  String get displayAddress {
    if (address.trim().isNotEmpty) return address.trim();
    return displayLocation;
  }

  bool get hasPhoto => photoUrl.trim().isNotEmpty;

  ResumeData copyWith({
    String? fullName,
    String? jobTitle,
    String? email,
    String? phone,
    String? location,
    String? address,
    String? city,
    String? country,
    String? summary,
    List<String>? skills,
    List<ExperienceItem>? experience,
    List<EducationItem>? education,
    String? photoUrl,
    List<String>? languages,
    List<String>? references,
    String? website,
    String? linkedin,
    String? github,
    List<ProjectItem>? projects,
    List<CertificationItem>? certifications,
    List<AwardItem>? awards,
    List<VolunteerItem>? volunteer,
    List<PublicationItem>? publications,
    List<String>? interests,
    List<CustomSection>? customSections,
    List<String>? sectionOrder,
    Map<String, bool>? sectionVisibility,
    Map<String, String>? sectionTitles,
  }) {
    return ResumeData(
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      summary: summary ?? this.summary,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      photoUrl: photoUrl ?? this.photoUrl,
      languages: languages ?? this.languages,
      references: references ?? this.references,
      website: website ?? this.website,
      linkedin: linkedin ?? this.linkedin,
      github: github ?? this.github,
      projects: projects ?? this.projects,
      certifications: certifications ?? this.certifications,
      awards: awards ?? this.awards,
      volunteer: volunteer ?? this.volunteer,
      publications: publications ?? this.publications,
      interests: interests ?? this.interests,
      customSections: customSections ?? this.customSections,
      sectionOrder: sectionOrder ?? this.sectionOrder,
      sectionVisibility: sectionVisibility ?? this.sectionVisibility,
      sectionTitles: sectionTitles ?? this.sectionTitles,
    );
  }

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'jobTitle': jobTitle,
        'email': email,
        'phone': phone,
        'location': location,
        'address': address,
        'city': city,
        'country': country,
        'summary': summary,
        'skills': skills,
        'experience': experience.map((item) => item.toMap()).toList(),
        'education': education.map((item) => item.toMap()).toList(),
        'photoUrl': photoUrl,
        'languages': languages,
        'references': references,
        'website': website,
        'linkedin': linkedin,
        'github': github,
        'projects': projects.map((item) => item.toMap()).toList(),
        'certifications': certifications.map((item) => item.toMap()).toList(),
        'awards': awards.map((item) => item.toMap()).toList(),
        'volunteer': volunteer.map((item) => item.toMap()).toList(),
        'publications': publications.map((item) => item.toMap()).toList(),
        'interests': interests,
        'customSections': customSections.map((item) => item.toMap()).toList(),
        'sectionOrder': sectionOrder,
        'sectionVisibility': sectionVisibility,
        'sectionTitles': sectionTitles,
      };

  factory ResumeData.fromMap(Map<String, dynamic> map) => ResumeData(
        fullName: map['fullName'] ?? '',
        jobTitle: map['jobTitle'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        location: map['location'] ?? '',
        address: map['address'] ?? '',
        city: map['city'] ?? '',
        country: map['country'] ?? '',
        summary: map['summary'] ?? map['professionalSummary'] ?? '',
        skills: _stringList(map['skills']),
        experience: _objectList(map['experience'], ExperienceItem.fromMap),
        education: _objectList(map['education'], EducationItem.fromMap),
        photoUrl: map['photoUrl'] ?? map['profileImage'] ?? '',
        languages: _stringList(map['languages']),
        references: _stringList(map['references']),
        website: map['website'] ?? '',
        linkedin: map['linkedin'] ?? '',
        github: map['github'] ?? '',
        projects: _objectList(map['projects'], ProjectItem.fromMap),
        certifications:
            _objectList(map['certifications'], CertificationItem.fromMap),
        awards: _objectList(map['awards'], AwardItem.fromMap),
        volunteer: _objectList(map['volunteer'], VolunteerItem.fromMap),
        publications:
            _objectList(map['publications'], PublicationItem.fromMap),
        interests: _stringList(map['interests']),
        customSections:
            _objectList(map['customSections'], CustomSection.fromMap),
        sectionOrder: _stringList(map['sectionOrder']),
        sectionVisibility: _boolMap(map['sectionVisibility']),
        sectionTitles: _stringMap(map['sectionTitles']),
      );

  bool isSectionVisible(String id) {
    if (sectionVisibility.containsKey(id)) {
      return sectionVisibility[id] == true;
    }
    return sectionHasContent(id);
  }

  bool sectionHasContent(String id) {
    switch (id) {
      case ResumeSectionIds.summary:
        return summary.trim().isNotEmpty;
      case ResumeSectionIds.experience:
        return experience.any((item) => item.hasContent);
      case ResumeSectionIds.education:
        return education.any((item) => item.hasContent);
      case ResumeSectionIds.skills:
        return skills.any((item) => item.trim().isNotEmpty);
      case ResumeSectionIds.projects:
        return projects.any((item) => item.hasContent);
      case ResumeSectionIds.certifications:
        return certifications.any((item) => item.hasContent);
      case ResumeSectionIds.languages:
        return languages.any((item) => item.trim().isNotEmpty);
      case ResumeSectionIds.awards:
        return awards.any((item) => item.hasContent);
      case ResumeSectionIds.volunteer:
        return volunteer.any((item) => item.hasContent);
      case ResumeSectionIds.publications:
        return publications.any((item) => item.hasContent);
      case ResumeSectionIds.references:
        return references.any((item) => item.trim().isNotEmpty);
      case ResumeSectionIds.interests:
        return interests.any((item) => item.trim().isNotEmpty);
      default:
        return customSections.any(
          (section) => section.id == id && section.hasContent,
        );
    }
  }

  String titleForSection(String id, [String? fallback]) {
    final custom = sectionTitles[id];
    if (custom != null && custom.trim().isNotEmpty) return custom.trim();
    if (fallback != null && fallback.trim().isNotEmpty) return fallback;
    return ResumeSectionIds.defaultTitle(id);
  }
}

class ResumeSectionIds {
  static const summary = 'summary';
  static const experience = 'experience';
  static const education = 'education';
  static const skills = 'skills';
  static const projects = 'projects';
  static const certifications = 'certifications';
  static const languages = 'languages';
  static const awards = 'awards';
  static const volunteer = 'volunteer';
  static const publications = 'publications';
  static const references = 'references';
  static const interests = 'interests';

  static const builtIn = [
    summary,
    experience,
    education,
    skills,
    projects,
    certifications,
    languages,
    awards,
    volunteer,
    publications,
    references,
    interests,
  ];

  static String defaultTitle(String id) {
    switch (id) {
      case summary:
        return 'Professional Summary';
      case experience:
        return 'Experience';
      case education:
        return 'Education';
      case skills:
        return 'Skills';
      case projects:
        return 'Projects';
      case certifications:
        return 'Certifications';
      case languages:
        return 'Languages';
      case awards:
        return 'Awards';
      case volunteer:
        return 'Volunteer Experience';
      case publications:
        return 'Publications';
      case references:
        return 'References';
      case interests:
        return 'Interests';
      default:
        return 'Custom Section';
    }
  }
}

class ExperienceItem {
  final String title;
  final String company;
  final String duration;
  final String description;
  final String location;
  final String startDate;
  final String endDate;
  final bool currentlyWorking;
  final List<String> achievements;

  const ExperienceItem({
    required this.title,
    required this.company,
    required this.duration,
    required this.description,
    this.location = '',
    this.startDate = '',
    this.endDate = '',
    this.currentlyWorking = false,
    this.achievements = const [],
  });

  bool get hasContent =>
      title.trim().isNotEmpty ||
      company.trim().isNotEmpty ||
      description.trim().isNotEmpty ||
      achievements.any((item) => item.trim().isNotEmpty);

  String get displayDuration {
    if (duration.trim().isNotEmpty) return duration.trim();
    final start = startDate.trim();
    final end = currentlyWorking
        ? 'Present'
        : (endDate.trim().isEmpty ? '' : endDate.trim());
    if (start.isEmpty && end.isEmpty) return '';
    if (end.isEmpty) return start;
    return '$start - $end';
  }

  List<String> get bullets {
    final items = achievements
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (items.isNotEmpty) return items;
    final text = description.trim();
    if (text.isEmpty) return const [];
    return text
        .split(RegExp(r'\n+|•'))
        .map((item) => item.trim().replaceFirst(RegExp(r'^[-–]\s*'), ''))
        .where((item) => item.isNotEmpty)
        .toList();
  }

  ExperienceItem copyWith({
    String? title,
    String? company,
    String? duration,
    String? description,
    String? location,
    String? startDate,
    String? endDate,
    bool? currentlyWorking,
    List<String>? achievements,
  }) {
    return ExperienceItem(
      title: title ?? this.title,
      company: company ?? this.company,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currentlyWorking: currentlyWorking ?? this.currentlyWorking,
      achievements: achievements ?? this.achievements,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'company': company,
        'duration': duration,
        'description': description,
        'location': location,
        'startDate': startDate,
        'endDate': endDate,
        'currentlyWorking': currentlyWorking,
        'achievements': achievements,
      };

  factory ExperienceItem.fromMap(Map<String, dynamic> map) => ExperienceItem(
        title: map['title'] ?? map['position'] ?? '',
        company: map['company'] ?? '',
        duration: map['duration'] ?? '',
        description: map['description'] ?? '',
        location: map['location'] ?? '',
        startDate: map['startDate'] ?? '',
        endDate: map['endDate'] ?? '',
        currentlyWorking: map['currentlyWorking'] == true,
        achievements: _stringList(map['achievements']),
      );
}

class EducationItem {
  final String degree;
  final String school;
  final String year;
  final String field;
  final String startDate;
  final String endDate;
  final String grade;
  final String description;

  const EducationItem({
    required this.degree,
    required this.school,
    required this.year,
    this.field = '',
    this.startDate = '',
    this.endDate = '',
    this.grade = '',
    this.description = '',
  });

  bool get hasContent =>
      degree.trim().isNotEmpty ||
      school.trim().isNotEmpty ||
      field.trim().isNotEmpty;

  String get institution => school;

  String get displayYear {
    if (year.trim().isNotEmpty) return year.trim();
    final start = startDate.trim();
    final end = endDate.trim();
    if (start.isEmpty && end.isEmpty) return '';
    if (end.isEmpty) return start;
    return '$start - $end';
  }

  String get displayDegree {
    if (field.trim().isEmpty) return degree;
    if (degree.trim().isEmpty) return field;
    if (degree.toLowerCase().contains(field.toLowerCase())) return degree;
    return '$degree, $field';
  }

  EducationItem copyWith({
    String? degree,
    String? school,
    String? year,
    String? field,
    String? startDate,
    String? endDate,
    String? grade,
    String? description,
  }) {
    return EducationItem(
      degree: degree ?? this.degree,
      school: school ?? this.school,
      year: year ?? this.year,
      field: field ?? this.field,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      grade: grade ?? this.grade,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() => {
        'degree': degree,
        'school': school,
        'year': year,
        'field': field,
        'startDate': startDate,
        'endDate': endDate,
        'grade': grade,
        'description': description,
      };

  factory EducationItem.fromMap(Map<String, dynamic> map) => EducationItem(
        degree: map['degree'] ?? '',
        school: map['school'] ?? map['institution'] ?? '',
        year: map['year'] ?? '',
        field: map['field'] ?? '',
        startDate: map['startDate'] ?? '',
        endDate: map['endDate'] ?? '',
        grade: map['grade'] ?? '',
        description: map['description'] ?? '',
      );
}

class SkillItem {
  final String name;
  final double level;
  final String category;

  const SkillItem({
    required this.name,
    this.level = 0.75,
    this.category = '',
  });

  static SkillItem parse(String raw) {
    final parts = raw.split('|');
    if (parts.length >= 2) {
      final value = double.tryParse(parts[1].trim());
      return SkillItem(
        name: parts[0].trim(),
        level: (value ?? 0.75).clamp(0.0, 1.0),
        category: parts.length > 2 ? parts[2].trim() : '',
      );
    }
    return SkillItem(name: raw.trim());
  }
}

class LanguageItem {
  final String language;
  final String proficiency;

  const LanguageItem({required this.language, this.proficiency = ''});

  static LanguageItem parse(String raw) {
    final parts = raw.split('|');
    if (parts.length >= 2) {
      return LanguageItem(
        language: parts[0].trim(),
        proficiency: parts[1].trim(),
      );
    }
    return LanguageItem(language: raw.trim());
  }

  String get display {
    if (proficiency.trim().isEmpty) return language;
    return '$language ($proficiency)';
  }
}

class ProjectItem {
  final String name;
  final String description;
  final List<String> technologies;
  final String url;
  final String date;

  const ProjectItem({
    required this.name,
    this.description = '',
    this.technologies = const [],
    this.url = '',
    this.date = '',
  });

  bool get hasContent => name.trim().isNotEmpty || description.trim().isNotEmpty;

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'technologies': technologies,
        'url': url,
        'date': date,
      };

  factory ProjectItem.fromMap(Map<String, dynamic> map) => ProjectItem(
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        technologies: _stringList(map['technologies']),
        url: map['url'] ?? '',
        date: map['date'] ?? '',
      );
}

class CertificationItem {
  final String name;
  final String organization;
  final String date;
  final String credentialUrl;

  const CertificationItem({
    required this.name,
    this.organization = '',
    this.date = '',
    this.credentialUrl = '',
  });

  bool get hasContent => name.trim().isNotEmpty;

  Map<String, dynamic> toMap() => {
        'name': name,
        'organization': organization,
        'date': date,
        'credentialUrl': credentialUrl,
      };

  factory CertificationItem.fromMap(Map<String, dynamic> map) =>
      CertificationItem(
        name: map['name'] ?? '',
        organization: map['organization'] ?? '',
        date: map['date'] ?? '',
        credentialUrl: map['credentialUrl'] ?? '',
      );
}

class AwardItem {
  final String title;
  final String organization;
  final String date;
  final String description;

  const AwardItem({
    required this.title,
    this.organization = '',
    this.date = '',
    this.description = '',
  });

  bool get hasContent => title.trim().isNotEmpty;

  Map<String, dynamic> toMap() => {
        'title': title,
        'organization': organization,
        'date': date,
        'description': description,
      };

  factory AwardItem.fromMap(Map<String, dynamic> map) => AwardItem(
        title: map['title'] ?? '',
        organization: map['organization'] ?? '',
        date: map['date'] ?? '',
        description: map['description'] ?? '',
      );
}

class VolunteerItem {
  final String role;
  final String organization;
  final String duration;
  final String description;

  const VolunteerItem({
    required this.role,
    this.organization = '',
    this.duration = '',
    this.description = '',
  });

  bool get hasContent =>
      role.trim().isNotEmpty || organization.trim().isNotEmpty;

  Map<String, dynamic> toMap() => {
        'role': role,
        'organization': organization,
        'duration': duration,
        'description': description,
      };

  factory VolunteerItem.fromMap(Map<String, dynamic> map) => VolunteerItem(
        role: map['role'] ?? map['title'] ?? '',
        organization: map['organization'] ?? '',
        duration: map['duration'] ?? '',
        description: map['description'] ?? '',
      );
}

class PublicationItem {
  final String title;
  final String publisher;
  final String date;
  final String url;
  final String description;

  const PublicationItem({
    required this.title,
    this.publisher = '',
    this.date = '',
    this.url = '',
    this.description = '',
  });

  bool get hasContent => title.trim().isNotEmpty;

  Map<String, dynamic> toMap() => {
        'title': title,
        'publisher': publisher,
        'date': date,
        'url': url,
        'description': description,
      };

  factory PublicationItem.fromMap(Map<String, dynamic> map) => PublicationItem(
        title: map['title'] ?? '',
        publisher: map['publisher'] ?? '',
        date: map['date'] ?? '',
        url: map['url'] ?? '',
        description: map['description'] ?? '',
      );
}

class CustomSection {
  final String id;
  final String title;
  final String content;
  final List<String> bullets;

  const CustomSection({
    required this.id,
    required this.title,
    this.content = '',
    this.bullets = const [],
  });

  bool get hasContent =>
      content.trim().isNotEmpty ||
      bullets.any((item) => item.trim().isNotEmpty);

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'bullets': bullets,
      };

  factory CustomSection.fromMap(Map<String, dynamic> map) => CustomSection(
        id: map['id'] ?? '',
        title: map['title'] ?? 'Custom Section',
        content: map['content'] ?? '',
        bullets: _stringList(map['bullets']),
      );
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) => item.toString())
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

List<T> _objectList<T>(
  dynamic value,
  T Function(Map<String, dynamic>) fromMap,
) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => fromMap(Map<String, dynamic>.from(item)))
      .toList();
}

Map<String, bool> _boolMap(dynamic value) {
  if (value is! Map) return const {};
  return value.map(
    (key, item) => MapEntry(key.toString(), item == true),
  );
}

Map<String, String> _stringMap(dynamic value) {
  if (value is! Map) return const {};
  return value.map(
    (key, item) => MapEntry(key.toString(), item?.toString() ?? ''),
  );
}
