import 'package:flutter/material.dart';
import 'package:cv_ganerator/config/theme.dart';
import 'package:cv_ganerator/constants/dimensions.dart';
import 'package:cv_ganerator/constants/strings.dart';
import 'package:cv_ganerator/models/cover_letter_model.dart';
import 'package:cv_ganerator/models/saved_resume.dart';
import 'package:cv_ganerator/screens/cover_letter_screen.dart';
import 'package:cv_ganerator/screens/cover_letter_preview_screen.dart';
import 'package:cv_ganerator/screens/resume_preview_screen.dart';
import 'package:cv_ganerator/services/local_storage_service.dart';
import 'package:cv_ganerator/services/ad_service.dart';
import 'package:cv_ganerator/utils/ad_navigation.dart';
import 'package:cv_ganerator/widgets/app_widgets.dart';
import 'package:cv_ganerator/widgets/banner_ad_widget.dart';
import 'package:cv_ganerator/widgets/common_widgets.dart';

class MyDocumentsScreen extends StatefulWidget {
  const MyDocumentsScreen({super.key});

  @override
  State<MyDocumentsScreen> createState() => _MyDocumentsScreenState();
}

class _MyDocumentsScreenState extends State<MyDocumentsScreen> {
  List<SavedResume> _resumes = [];
  List<CoverLetter> _letters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final storage = LocalStorageService.instance;
    setState(() {
      _resumes = storage.getSavedResumes();
      _letters = storage.getCoverLetters();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: AppStrings.myResumes),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: AppStrings.myResumes,
                    subtitle: 'Your resumes and cover letters',
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_resumes.isEmpty && _letters.isEmpty)
                    CustomCard(
                      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                      child: Column(
                        children: [
                          Icon(
                            Icons.folder_open_outlined,
                            size: 56,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: AppDimensions.paddingMedium),
                          Text(
                            'No documents yet',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.paddingXSmall),
                          Text(
                            'Create a resume or cover letter and they will show up here.',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.paddingLarge),
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  label: AppStrings.createNewResume,
                                  onPressed: () {
                                    AdNavigation.openCreateResume(
                                      context,
                                      onReturn: _loadDocuments,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingMedium),
                              Expanded(
                                child: SecondaryButton(
                                  label: AppStrings.coverLetterGenerator,
                                  onPressed: () {
                                    AdService.instance.showInterstitialThen(() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const CoverLetterScreen(),
                                        ),
                                      ).then((_) => _loadDocuments());
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else ...[
                    if (_resumes.isNotEmpty) ...[
                      SectionHeader(
                        title: AppStrings.myResumes,
                        subtitle: '${_resumes.length} saved',
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                    ],
                    for (final resume in _resumes) ...[
                      _DocumentCard(
                        title: resume.title,
                        subtitle: 'Resume • ${_formatDate(resume.updatedAt)}',
                        icon: Icons.description_outlined,
                        accent: AppTheme.primaryColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResumePreviewScreen(
                                resumeTitle: resume.title,
                                resumeData: resume.data,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                    ],
                    if (_letters.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.paddingSmall),
                      SectionHeader(
                        title: AppStrings.coverLetterGenerator,
                        subtitle: '${_letters.length} saved',
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                    ],
                    for (final letter in _letters) ...[
                      _DocumentCard(
                        title: letter.companyName,
                        subtitle:
                            'Cover Letter • ${_formatDate(letter.updatedAt)}',
                        icon: Icons.mail_outline,
                        accent: AppTheme.secondaryColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CoverLetterPreviewScreen(letter: letter),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                    ],
                  ],
                ],
              ),
            ),
          ),
          BannerAdWidget(adUnitId: AdService.bannerAdUnitId),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _DocumentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      child: CustomCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusMedium,
                ),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppDimensions.paddingXSmall),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
