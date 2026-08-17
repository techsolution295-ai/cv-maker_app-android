import 'package:flutter/material.dart';
import 'package:cv_ganerator/config/theme.dart';
import 'package:cv_ganerator/constants/dimensions.dart';
import 'package:cv_ganerator/constants/strings.dart';
import 'package:cv_ganerator/models/resume_data.dart';
import 'package:cv_ganerator/models/saved_resume.dart';
import 'package:cv_ganerator/services/local_storage_service.dart';
import 'package:cv_ganerator/services/ad_service.dart';
import 'package:cv_ganerator/utils/ad_navigation.dart';
import 'package:cv_ganerator/widgets/resume_templates.dart';
import 'package:cv_ganerator/widgets/app_widgets.dart';
import 'package:cv_ganerator/widgets/banner_ad_widget.dart';
import 'package:cv_ganerator/screens/resume_preview_screen.dart';

class TemplateScreen extends StatelessWidget {
  final bool showAppBar;

  const TemplateScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final localTemplates = ResumeTemplateKind.values;
    return Scaffold(
      appBar: showAppBar ? AppAppBar(title: AppStrings.templates) : null,
      body: Column(
        children: [
          BannerAdWidget(
            adUnitId: AdService.bannerAdUnitId,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          ),
          Expanded(child: _TemplateGallery(localTemplates: localTemplates)),
        ],
      ),
    );
  }
}

class _TemplateGallery extends StatelessWidget {
  final List<ResumeTemplateKind> localTemplates;

  const _TemplateGallery({required this.localTemplates});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF7F3EC),
            AppTheme.backgroundColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                    vertical: AppDimensions.paddingLarge * 1.5,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientBackground,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppDimensions.paddingMedium),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.style_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${localTemplates.length} professional templates',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      Text(
                        'Fill Your Info to Create a CV',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Text(
                        'Your details will automatically apply to any template you choose.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge),
                      PrimaryButton(
                        label: AppStrings.createNewResume,
                        onPressed: () => AdNavigation.openCreateResume(context),
                        icon: Icons.edit_outlined,
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                    ],
                  ),
                ),
                // Decorative circles
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.paddingSmall),
                  Text(
                    'Choose your style',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pick a layout and start customizing instantly.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.textLight),
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = 2;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: AppDimensions.paddingLarge,
                        crossAxisSpacing: AppDimensions.paddingLarge,
                        childAspectRatio: 0.7, // Adjusted for A4 resume shape
                        children: List.generate(localTemplates.length, (index) {
                          final template = localTemplates[index];
                          return _EntryAnimation(
                            index: index,
                            child: _TemplateShowcaseCard(
                              kind: template,
                              name: _templateName(template),
                              onTap: () =>
                                  _openLocalTemplate(context, template),
                              imagePath: _templateImagePath(template),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLocalTemplate(BuildContext context, ResumeTemplateKind kind) {
    AdService.instance.showInterstitialThen(() {
      final savedResumes = LocalStorageService.instance.getSavedResumes();
      savedResumes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final SavedResume? latest =
          savedResumes.isNotEmpty ? savedResumes.first : null;
      final ResumeData data = latest?.data ?? _sampleData();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResumePreviewScreen(
            resumeTitle:
                data.fullName.isEmpty ? AppStrings.resumeTitle : data.fullName,
            resumeData: data,
            allowEditing: true,
            initialTemplate: kind,
          ),
        ),
      );
    });
  }

  String _templateName(ResumeTemplateKind kind) {
    switch (kind) {
      case ResumeTemplateKind.travis:
        return 'Classic';
      case ResumeTemplateKind.jeff:
        return 'Modern';
      case ResumeTemplateKind.jack:
        return 'Professional';
      case ResumeTemplateKind.alice:
        return 'Elegant';
      case ResumeTemplateKind.matthew:
        return 'Minimal';
      case ResumeTemplateKind.edward:
        return 'Executive';
      case ResumeTemplateKind.patMash:
        return 'Creative';
      case ResumeTemplateKind.patricia:
        return 'Bold';
      case ResumeTemplateKind.daniel:
        return 'Compact';
    }
  }

  String _templateImagePath(ResumeTemplateKind kind) {
    switch (kind) {
      case ResumeTemplateKind.travis:
        return 'assets/images/template1.jpg';
      case ResumeTemplateKind.jeff:
        return 'assets/images/template2.jpg';
      case ResumeTemplateKind.jack:
        return 'assets/images/template3.jpg';
      case ResumeTemplateKind.alice:
        return 'assets/images/template4.jpg';
      case ResumeTemplateKind.matthew:
        return 'assets/images/template5.jpg';
      case ResumeTemplateKind.edward:
        return 'assets/images/template6.jpg';
      case ResumeTemplateKind.patMash:
        return 'assets/images/template7.jpg';
      case ResumeTemplateKind.patricia:
        return 'assets/images/template8.jpg';
      case ResumeTemplateKind.daniel:
        return 'assets/images/template9.jpg';
    }
  }

  ResumeData _sampleData() {
    return const ResumeData(
      fullName: 'John Doe',
      jobTitle: 'Software Engineer',
      email: 'john@example.com',
      phone: '+1 (555) 123-4567',
      location: 'New York, USA',
      summary: 'Experienced engineer with a focus on mobile and web apps.',
      skills: ['Flutter', 'Dart', 'REST APIs'],
      experience: [
        ExperienceItem(
          title: 'Senior Developer',
          company: 'Tech Company ABC',
          duration: 'Jan 2021 - Present',
          description: 'Led development of key features.',
        ),
      ],
      education: [
        EducationItem(
          degree: 'BSc in Computer Science',
          school: 'University of Technology',
          year: '2019',
        ),
      ],
    );
  }
}

class _TemplateShowcaseCard extends StatelessWidget {
  final ResumeTemplateKind kind;
  final String name;
  final VoidCallback onTap;
  final String imagePath;

  const _TemplateShowcaseCard({
    required this.kind,
    required this.name,
    required this.onTap,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: Colors.white,
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryAnimation extends StatefulWidget {
  final int index;
  final Widget child;

  const _EntryAnimation({required this.index, required this.child});

  @override
  State<_EntryAnimation> createState() => _EntryAnimationState();
}

class _EntryAnimationState extends State<_EntryAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2), // Start slightly below
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Stagger the animation based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
