import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cv_ganerator/config/theme.dart';
import 'package:cv_ganerator/constants/dimensions.dart';
import 'package:cv_ganerator/models/resume_data.dart';

enum ResumeTemplateKind {
  travis,
  jeff,
  jack,
  alice,
  matthew,
  edward,
  patMash,
  patricia,
  daniel,
}

class ResumeTemplateSwitcher extends StatelessWidget {
  final ResumeData data;
  final ResumeTemplateKind kind;

  const ResumeTemplateSwitcher({
    super.key,
    required this.data,
    required this.kind,
  });

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case ResumeTemplateKind.travis:
        return _TravisTemplate(data: data);
      case ResumeTemplateKind.jeff:
        return _JeffTemplate(data: data);
      case ResumeTemplateKind.jack:
        return _JackTemplate(data: data);
      case ResumeTemplateKind.alice:
        return _AliceTemplate(data: data);
      case ResumeTemplateKind.matthew:
        return _MatthewTemplate(data: data);
      case ResumeTemplateKind.edward:
        return _EdwardTemplate(data: data);
      case ResumeTemplateKind.patMash:
        return _PatMashTemplate(data: data);
      case ResumeTemplateKind.patricia:
        return _PatriciaTemplate(data: data);
      case ResumeTemplateKind.daniel:
        return _DanielTemplate(data: data);
    }
  }
}

class _SkillLevel {
  final String name;
  final double level;

  const _SkillLevel(this.name, this.level);
}

List<_SkillLevel> _parseLevels(List<String> raw) {
  if (raw.isEmpty) {
    return const [];
  }
  return raw.map((item) {
    final parts = item.split('|');
    if (parts.length == 2) {
      final value = double.tryParse(parts[1].trim()) ?? 0.7;
      return _SkillLevel(parts[0].trim(), value.clamp(0.0, 1.0));
    }
    return _SkillLevel(item, 0.75);
  }).toList();
}

String _initials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return 'CV';
  }
  final parts =
      trimmed.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}

Widget _sectionTitle(BuildContext context, String title,
    {Color? color, bool underline = true}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color ?? AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
      ),
      if (underline)
        Container(
          margin: const EdgeInsets.only(top: 6),
          height: 2,
          width: 56,
          color: color ?? AppTheme.primaryColor,
        ),
    ],
  );
}

Widget _bulletText(BuildContext context, String text,
    {Color? color, double size = 4}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        margin: const EdgeInsets.only(top: 6),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? AppTheme.textDark,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: color ?? AppTheme.textDark),
        ),
      ),
    ],
  );
}

ImageProvider _getImageProvider(String path) {
  if (path.startsWith('http')) {
    return NetworkImage(path);
  } else if (path.startsWith('file://')) {
    // Manually strip 'file://' to avoid Uri parsing issues with empty hosts
    return FileImage(File(path.replaceFirst('file://', '')));
  } else {
    return FileImage(File(path));
  }
}

Widget _photoAvatar(ResumeData data, {double radius = 34}) {
  if (data.photoUrl.isNotEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: _getImageProvider(data.photoUrl),
      backgroundColor: Colors.grey.shade200,
    );
  }
  return CircleAvatar(
    radius: radius,
    backgroundColor: Colors.grey.shade300,
    child: Text(
      _initials(data.fullName),
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}

class _TravisTemplate extends StatelessWidget {
  final ResumeData data;

  const _TravisTemplate({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.fullName.isEmpty ? 'Your Name' : data.fullName,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              data.jobTitle.isEmpty ? 'Job Title' : data.jobTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _miniLabelValue('Address', data.location, context),
                _miniLabelValue('Phone', data.phone, context),
                _miniLabelValue('Email', data.email, context),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            _numberedSection(
              context,
              '01',
              'PROFILE',
              Text(
                data.summary.isEmpty ? 'Add a summary.' : data.summary,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              isCompact,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            _numberedSection(
              context,
              '02',
              'EMPLOYMENT HISTORY',
              Column(
                children: data.experience
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingMedium),
                        child: _historyRow(context, item),
                      ),
                    )
                    .toList(),
              ),
              isCompact,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            _numberedSection(
              context,
              '03',
              'EDUCATION',
              Column(
                children: data.education
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingMedium),
                        child: _educationRow(context, item),
                      ),
                    )
                    .toList(),
              ),
              isCompact,
            ),
          ],
        );
      },
    );
  }

  Widget _miniLabelValue(String label, String value, BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '—' : value,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _numberedSection(
    BuildContext context,
    String number,
    String title,
    Widget body,
    bool isCompact,
  ) {
    final header = Row(
      children: [
        Text(
          number,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _sectionTitle(context, title, underline: true)),
      ],
    );
    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: AppDimensions.paddingSmall),
          body,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 140, child: header),
        const SizedBox(width: AppDimensions.paddingLarge),
        Expanded(child: body),
      ],
    );
  }

  Widget _historyRow(BuildContext context, ExperienceItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child:
              Text(item.duration, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                item.company,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              _bulletText(context, item.description),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          data.location.isEmpty ? '' : data.location.split(',').last.trim(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _educationRow(BuildContext context, EducationItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(item.year, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.school,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(item.degree, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _JeffTemplate extends StatelessWidget {
  final ResumeData data;

  const _JeffTemplate({required this.data});

  @override
  Widget build(BuildContext context) {
    final skills = _parseLevels(data.skills);
    final languages =
        _parseLevels(data.languages.isEmpty ? data.skills : data.languages);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                data.fullName.isEmpty ? 'Your Name' : data.fullName,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            _photoAvatar(data, radius: 44),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                data.location.isEmpty ? 'Address' : data.location,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Expanded(
              child: Text(
                data.phone.isEmpty ? 'Phone' : data.phone,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Expanded(
              child: Text(
                data.email.isEmpty ? 'Email' : data.email,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Divider(color: AppTheme.borderColor),
        const SizedBox(height: AppDimensions.paddingMedium),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, 'Profile', underline: false),
                  const SizedBox(height: 8),
                  Text(
                    data.summary.isEmpty ? 'Add summary.' : data.summary,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.paddingLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, 'Skills', underline: false),
                  const SizedBox(height: 8),
                  ...skills.map((skill) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingXSmall),
                        child: Text(
                          '${skill.name}  -  ${(skill.level * 100).round()}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.paddingLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, 'Languages', underline: false),
                  const SizedBox(height: 8),
                  ...languages.map((language) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingXSmall),
                        child: Text(
                          language.name,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        _sectionTitle(context, 'Employment History'),
        const SizedBox(height: AppDimensions.paddingSmall),
        ...data.experience.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
            child: _historyCard(context, item),
          ),
        ),
      ],
    );
  }

  Widget _historyCard(BuildContext context, ExperienceItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(item.company, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Text(item.duration, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        _bulletText(context, item.description),
      ],
    );
  }
}

class _JackTemplate extends StatelessWidget {
  final ResumeData data;

  const _JackTemplate({required this.data});

  @override
  Widget build(BuildContext context) {
    final skills = _parseLevels(data.skills);
    final languages =
        _parseLevels(data.languages.isEmpty ? data.skills : data.languages);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                data.fullName.isEmpty ? 'Your Name' : data.fullName,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            _photoAvatar(data, radius: 42),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Text(
          data.jobTitle.isEmpty ? 'Job Title' : data.jobTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        Text(
          '${data.location}  •  ${data.phone}  •  ${data.email}'.trim(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        _sectionTitle(context, '1 PROFILE', underline: false),
        const SizedBox(height: 8),
        Text(
          data.summary.isEmpty ? 'Add summary.' : data.summary,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, '2 SKILLS', underline: false),
                  const SizedBox(height: 8),
                  ...skills.map((skill) => _dotRow(context, skill)),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.paddingLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, '3 LANGUAGES', underline: false),
                  const SizedBox(height: 8),
                  ...languages.map((language) => _dotRow(context, language)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        _sectionTitle(context, '4 EMPLOYMENT HISTORY', underline: false),
        const SizedBox(height: 8),
        ...data.experience.map((item) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
              child: _historyCard(context, item),
            )),
      ],
    );
  }

  Widget _dotRow(BuildContext context, _SkillLevel skill) {
    final dots = (skill.level * 5).round().clamp(1, 5);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingXSmall),
      child: Row(
        children: [
          Expanded(
            child:
                Text(skill.name, style: Theme.of(context).textTheme.bodySmall),
          ),
          Row(
            children: List.generate(
              5,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.textDark),
                  color: index < dots ? AppTheme.textDark : Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(BuildContext context, ExperienceItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(item.company, style: Theme.of(context).textTheme.bodySmall),
        Text(item.duration, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        _bulletText(context, item.description),
      ],
    );
  }
}

class _AliceTemplate extends StatelessWidget {
  final ResumeData data;

  const _AliceTemplate({required this.data});

  @override
  Widget build(BuildContext context) {
    final skills = data.skills;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        final rightColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'Address', underline: false),
            const SizedBox(height: 4),
            Text(data.location.isEmpty ? 'Address' : data.location,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppDimensions.paddingMedium),
            _sectionTitle(context, 'Email', underline: false),
            const SizedBox(height: 4),
            Text(data.email.isEmpty ? 'Email' : data.email,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppDimensions.paddingMedium),
            _sectionTitle(context, 'Phone', underline: false),
            const SizedBox(height: 4),
            Text(data.phone.isEmpty ? 'Phone' : data.phone,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppDimensions.paddingLarge),
            _sectionTitle(context, 'Skills', underline: false),
            const SizedBox(height: 8),
            ...skills.map((skill) => Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingXSmall),
                  child:
                      Text(skill, style: Theme.of(context).textTheme.bodySmall),
                )),
          ],
        );
        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              const SizedBox(height: AppDimensions.paddingLarge),
              rightColumn,
              const SizedBox(height: AppDimensions.paddingLarge),
              _mainContent(context),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _mainContent(context)),
            const SizedBox(width: AppDimensions.paddingLarge),
            Expanded(flex: 2, child: rightColumn),
          ],
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.fullName.isEmpty ? 'Your Name' : data.fullName,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: const Color(0xFFB57E3A),
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          data.jobTitle.isEmpty ? 'Job Title' : data.jobTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }

  Widget _mainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context),
        const SizedBox(height: AppDimensions.paddingLarge),
        _sectionTitle(context, 'Profile', underline: false),
        const SizedBox(height: 8),
        Text(
          data.summary.isEmpty ? 'Add summary.' : data.summary,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        _sectionTitle(context, 'Employment History', underline: false),
        const SizedBox(height: 8),
        ...data.experience.map((item) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
              child: _historyCard(context, item),
            )),
        const SizedBox(height: AppDimensions.paddingLarge),
        _sectionTitle(context, 'Education', underline: false),
        const SizedBox(height: 8),
        ...data.education.map((item) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
              child: _educationCard(context, item),
            )),
      ],
    );
  }

  Widget _historyCard(BuildContext context, ExperienceItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.company,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(item.title, style: Theme.of(context).textTheme.bodySmall),
        Text(item.duration, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        _bulletText(context, item.description, color: const Color(0xFFB57E3A)),
      ],
    );
  }

  Widget _educationCard(BuildContext context, EducationItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.school,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(item.degree, style: Theme.of(context).textTheme.bodySmall),
        Text(item.year, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _MatthewTemplate extends StatelessWidget {
  final ResumeData data;

  const _MatthewTemplate({required this.data});

  @override
  Widget build(BuildContext context) {
    final skills = _parseLevels(data.skills);
    final languages =
        _parseLevels(data.languages.isEmpty ? data.skills : data.languages);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        final side = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'Details', underline: false),
            const SizedBox(height: 8),
            Text(data.location, style: Theme.of(context).textTheme.bodySmall),
            Text(data.phone, style: Theme.of(context).textTheme.bodySmall),
            Text(data.email, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppDimensions.paddingLarge),
            _sectionTitle(context, 'Skills', underline: false),
            const SizedBox(height: 8),
            ...skills.map((skill) => _barRow(context, skill)),
            const SizedBox(height: AppDimensions.paddingLarge),
            _sectionTitle(context, 'Languages', underline: false),
            const SizedBox(height: 8),
            ...languages.map((lang) => _barRow(context, lang)),
          ],
        );
        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              const SizedBox(height: AppDimensions.paddingLarge),
              side,
              const SizedBox(height: AppDimensions.paddingLarge),
              _main(context),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _main(context)),
            const SizedBox(width: AppDimensions.paddingLarge),
            Expanded(flex: 2, child: side),
          ],
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        _photoAvatar(data, radius: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.fullName.isEmpty ? 'Your Name' : data.fullName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              data.jobTitle.isEmpty ? 'Job Title' : data.jobTitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _main(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context),
        const SizedBox(height: AppDimensions.paddingLarge),
        _sectionTitle(context, 'Profile', underline: false),
        const SizedBox(height: 8),
        Text(
          data.summary.isEmpty ? 'Add summary.' : data.summary,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        _sectionTitle(context, 'Employment History', underline: false),
        const SizedBox(height: 8),
        ...data.experience.map((item) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
              child: _historyCard(context, item),
            )),
        const SizedBox(height: AppDimensions.paddingLarge),
        _sectionTitle(context, 'Education', underline: false),
        const SizedBox(height: 8),
        ...data.education.map((item) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
              child: _educationCard(context, item),
            )),
        const SizedBox(height: AppDimensions.paddingLarge),
        _sectionTitle(context, 'References', underline: false),
        const SizedBox(height: 8),
        ...data.references.map(
          (ref) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.paddingXSmall),
            child: Text(ref, style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
      ],
    );
  }

  Widget _barRow(BuildContext context, _SkillLevel skill) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(skill.name, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 3,
                    width: constraints.maxWidth,
                    color: AppTheme.borderColor,
                  ),
                  Container(
                    height: 3,
                    width: constraints.maxWidth * skill.level,
                    color: AppTheme.primaryColor,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _historyCard(BuildContext context, ExperienceItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(item.company, style: Theme.of(context).textTheme.bodySmall),
        Text(item.duration, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        _bulletText(context, item.description),
      ],
    );
  }

  Widget _educationCard(BuildContext context, EducationItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.school,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(item.degree, style: Theme.of(context).textTheme.bodySmall),
        Text(item.year, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _EdwardTemplate extends StatelessWidget {
  final ResumeData data;

  const _EdwardTemplate({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _photoAvatar(data, radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data.fullName.isEmpty ? 'Your Name' : data.fullName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${data.location} | ${data.email} | ${data.phone}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Divider(color: AppTheme.borderColor),
        const SizedBox(height: AppDimensions.paddingMedium),
        _sectionTitle(context, 'Professional Summary', underline: false),
        const SizedBox(height: 8),
        Text(
          data.summary.isEmpty ? 'Add summary.' : data.summary,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        _sectionTitle(context, 'Professional Experience', underline: false),
        const SizedBox(height: 8),
        ...data.experience.map((item) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
              child: _experienceCard(context, item),
            )),
        const SizedBox(height: AppDimensions.paddingLarge),
        _sectionTitle(context, 'Education', underline: false),
        const SizedBox(height: 8),
        ...data.education.map((item) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
              child: _educationCard(context, item),
            )),
        const SizedBox(height: AppDimensions.paddingLarge),
        _sectionTitle(context, 'Expert-Level Skills', underline: false),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: data.skills
              .map(
                (skill) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      Text(skill, style: Theme.of(context).textTheme.bodySmall),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _experienceCard(BuildContext context, ExperienceItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.company,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(item.title, style: Theme.of(context).textTheme.bodySmall),
        Text(item.duration, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        _bulletText(context, item.description),
      ],
    );
  }

  Widget _educationCard(BuildContext context, EducationItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.school,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(item.degree, style: Theme.of(context).textTheme.bodySmall),
        Text(item.year, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _PatMashTemplate extends StatelessWidget {
  final ResumeData data;

  const _PatMashTemplate({required this.data});

  @override
  Widget build(BuildContext context) {
    final skills = _parseLevels(data.skills);
    final languages =
        _parseLevels(data.languages.isEmpty ? data.skills : data.languages);
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E4),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
              alignment: Alignment.center,
              child: _photoAvatar(data, radius: 32)),
          const SizedBox(height: AppDimensions.paddingSmall),
          Align(
            alignment: Alignment.center,
            child: Text(
              data.fullName.isEmpty ? 'Your Name' : data.fullName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              data.jobTitle.isEmpty ? 'Job Title' : data.jobTitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Center(
            child: Text(
              '${data.phone}  •  ${data.location}  •  ${data.email}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Divider(color: AppTheme.borderColor),
          const SizedBox(height: AppDimensions.paddingMedium),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(context, 'Skills', underline: false),
                    const SizedBox(height: 8),
                    ...skills
                        .map((skill) => _barRow(context, skill, Colors.brown)),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    _sectionTitle(context, 'Languages', underline: false),
                    const SizedBox(height: 8),
                    ...languages
                        .map((lang) => _barRow(context, lang, Colors.brown)),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.paddingLarge),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(context, 'Profile', underline: false),
                    const SizedBox(height: 8),
                    Text(
                      data.summary.isEmpty ? 'Add summary.' : data.summary,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),
                    _sectionTitle(context, 'Employment History',
                        underline: false),
                    const SizedBox(height: 8),
                    ...data.experience.map((item) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppDimensions.paddingMedium),
                          child: _historyCard(context, item),
                        )),
                    const SizedBox(height: AppDimensions.paddingLarge),
                    _sectionTitle(context, 'Education', underline: false),
                    const SizedBox(height: 8),
                    ...data.education.map((item) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppDimensions.paddingMedium),
                          child: _educationCard(context, item),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _barRow(BuildContext context, _SkillLevel skill, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(skill.name, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 3,
                    width: constraints.maxWidth,
                    color: color.withOpacity(0.2),
                  ),
                  Container(
                    height: 3,
                    width: constraints.maxWidth * skill.level,
                    color: color,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _historyCard(BuildContext context, ExperienceItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.company,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(item.title, style: Theme.of(context).textTheme.bodySmall),
        Text(item.duration, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        _bulletText(context, item.description, color: Colors.brown),
      ],
    );
  }

  Widget _educationCard(BuildContext context, EducationItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.school,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(item.degree, style: Theme.of(context).textTheme.bodySmall),
        Text(item.year, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _PatriciaTemplate extends StatelessWidget {
  final ResumeData data;

  const _PatriciaTemplate({required this.data});

  @override
  Widget build(BuildContext context) {
    final skills = _parseLevels(data.skills);
    final languages =
        _parseLevels(data.languages.isEmpty ? data.skills : data.languages);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          decoration: BoxDecoration(
            color: const Color(0xFF3FE0B3),
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusLarge),
          ),
          child: Row(
            children: [
              _photoAvatar(data, radius: 36),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.fullName.isEmpty ? 'Your Name' : data.fullName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      data.jobTitle.isEmpty ? 'Job Title' : data.jobTitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${data.location}  •  ${data.phone}  •  ${data.email}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, 'Skills', underline: false),
                  const SizedBox(height: 8),
                  ...skills.map((skill) => _barRow(context, skill)),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  _sectionTitle(context, 'Languages', underline: false),
                  const SizedBox(height: 8),
                  ...languages.map((language) => _barRow(context, language)),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.paddingLarge),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, 'Profile', underline: false),
                  const SizedBox(height: 8),
                  Text(
                    data.summary.isEmpty ? 'Add summary.' : data.summary,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  _sectionTitle(context, 'Employment History',
                      underline: false),
                  const SizedBox(height: 8),
                  ...data.experience.map((item) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingMedium),
                        child: _historyCard(context, item),
                      )),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  _sectionTitle(context, 'Education', underline: false),
                  const SizedBox(height: 8),
                  ...data.education.map((item) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingMedium),
                        child: _educationCard(context, item),
                      )),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _barRow(BuildContext context, _SkillLevel skill) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(skill.name, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 3,
                    width: constraints.maxWidth,
                    color: Colors.black12,
                  ),
                  Container(
                    height: 3,
                    width: constraints.maxWidth * skill.level,
                    color: Colors.black87,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _historyCard(BuildContext context, ExperienceItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(item.company, style: Theme.of(context).textTheme.bodySmall),
        Text(item.duration, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        _bulletText(context, item.description),
      ],
    );
  }

  Widget _educationCard(BuildContext context, EducationItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.school,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(item.degree, style: Theme.of(context).textTheme.bodySmall),
        Text(item.year, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _DanielTemplate extends StatelessWidget {
  final ResumeData data;

  const _DanielTemplate({required this.data});

  @override
  Widget build(BuildContext context) {
    final skills = _parseLevels(data.skills);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.fullName.isEmpty ? 'Your Name' : data.fullName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: const Color(0xFF0B3C7A),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    data.jobTitle.isEmpty ? 'Job Title' : data.jobTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF0B3C7A),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.summary.isEmpty ? 'Add summary.' : data.summary,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            _photoAvatar(data, radius: 40),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, 'Employment History',
                      color: const Color(0xFF0B3C7A)),
                  const SizedBox(height: 8),
                  ...data.experience.map((item) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingMedium),
                        child: _historyCard(context, item),
                      )),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  _sectionTitle(context, 'Education',
                      color: const Color(0xFF0B3C7A)),
                  const SizedBox(height: 8),
                  ...data.education.map((item) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingMedium),
                        child: _educationCard(context, item),
                      )),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.paddingLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, 'Details',
                      color: const Color(0xFF0B3C7A)),
                  const SizedBox(height: 8),
                  Text(data.location,
                      style: Theme.of(context).textTheme.bodySmall),
                  Text(data.phone,
                      style: Theme.of(context).textTheme.bodySmall),
                  Text(data.email,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  _sectionTitle(context, 'Skills',
                      color: const Color(0xFF0B3C7A)),
                  const SizedBox(height: 8),
                  ...skills.map((skill) => _barRow(context, skill)),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  _sectionTitle(context, 'References',
                      color: const Color(0xFF0B3C7A)),
                  const SizedBox(height: 8),
                  ...data.references.map(
                    (ref) => Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingXSmall),
                      child: Text(ref,
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _barRow(BuildContext context, _SkillLevel skill) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(skill.name, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 3,
                    width: constraints.maxWidth,
                    color: const Color(0xFF0B3C7A).withOpacity(0.2),
                  ),
                  Container(
                    height: 3,
                    width: constraints.maxWidth * skill.level,
                    color: const Color(0xFF0B3C7A),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _historyCard(BuildContext context, ExperienceItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(item.company, style: Theme.of(context).textTheme.bodySmall),
        Text(item.duration, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        _bulletText(context, item.description),
      ],
    );
  }

  Widget _educationCard(BuildContext context, EducationItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.school,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(item.degree, style: Theme.of(context).textTheme.bodySmall),
        Text(item.year, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
