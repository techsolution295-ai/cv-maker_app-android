import 'package:flutter/material.dart';
import 'package:cv_ganerator/config/theme.dart';
import 'package:cv_ganerator/constants/dimensions.dart';
import 'package:cv_ganerator/constants/strings.dart';
import 'package:cv_ganerator/models/saved_resume.dart';
import 'package:cv_ganerator/screens/ats_score_screen.dart';
import 'package:cv_ganerator/screens/cover_letter_screen.dart';
import 'package:cv_ganerator/screens/my_documents_screen.dart';
import 'package:cv_ganerator/screens/resume_preview_screen.dart';
import 'package:cv_ganerator/services/local_storage_service.dart';
import 'package:cv_ganerator/services/ad_service.dart';
import 'package:cv_ganerator/utils/ad_navigation.dart';
import 'package:cv_ganerator/widgets/app_widgets.dart';
import 'package:cv_ganerator/widgets/banner_ad_widget.dart';
import 'package:cv_ganerator/widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  final bool showAppBar;

  const HomeScreen({super.key, this.showAppBar = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SavedResume> _resumes = [];

  @override
  void initState() {
    super.initState();
    _reloadDocuments();
  }

  Future<void> _reloadDocuments() async {
    final storage = LocalStorageService.instance;
    setState(() {
      _resumes = storage.getSavedResumes();
    });
  }

  void _openCreateResume() {
    AdNavigation.openCreateResume(context, onReturn: _reloadDocuments);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final actionColumns = width < 700 ? 2 : 4;

    final recent = [..._resumes]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final recentTop = recent.take(3).toList();

    final body = RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: _reloadDocuments,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingLarge,
                AppDimensions.paddingLarge,
                AppDimensions.paddingLarge,
                AppDimensions.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  _buildAiBanner(theme),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  SectionHeader(
                    title: 'Quick Actions',
                    subtitle: 'Jump into your most used tools',
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  _buildQuickActions(actionColumns),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  SectionHeader(
                    title: 'Recent Documents',
                    subtitle: recentTop.isEmpty
                        ? 'Your latest work appears here'
                        : '${_resumes.length} saved',
                    actionLabel: recentTop.isEmpty ? null : 'See all',
                    onAction: recentTop.isEmpty
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyDocumentsScreen(),
                              ),
                            ).then((_) => _reloadDocuments()),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  if (recentTop.isEmpty)
                    _buildEmptyRecent(theme)
                  else
                    ...List.generate(recentTop.length, (index) {
                      final resume = recentTop[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == recentTop.length - 1
                              ? 0
                              : AppDimensions.paddingMedium,
                        ),
                        child: _RecentDocumentCard(
                          resume: resume,
                          accent: _accentForIndex(index),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResumePreviewScreen(
                                resumeTitle: resume.title,
                                resumeData: resume.data,
                              ),
                            ),
                          ).then((_) => _reloadDocuments()),
                        ),
                      );
                    }),
                  const SizedBox(height: AppDimensions.paddingMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (!widget.showAppBar) {
      return Column(
        children: [
          BannerAdWidget(
            adUnitId: AdService.bannerAdUnitId,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      appBar: AppAppBar(title: AppStrings.homeDashboardTitle),
      body: Column(
        children: [
          BannerAdWidget(
            adUnitId: AdService.bannerAdUnitId,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppDimensions.borderRadiusXLarge),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.gradientBackground,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.30),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(top: -36, right: -28, child: _decorCircle(140, 0.12)),
            Positioned(top: 48, right: 70, child: _decorCircle(34, 0.14)),
            Positioned(bottom: -44, left: -30, child: _decorCircle(130, 0.08)),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingLarge,
                AppDimensions.paddingMedium,
                AppDimensions.paddingLarge,
                AppDimensions.paddingLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Build a standout CV',
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                          ),
                        ),
                        child: const Icon(
                          Icons.description_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  Text(
                    'Pick a template, generate content with AI, and export instantly.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  _buildHeaderCta(theme),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  Wrap(
                    spacing: AppDimensions.paddingSmall,
                    runSpacing: AppDimensions.paddingSmall,
                    children: const [
                      _HeaderChip(label: 'ATS-friendly', icon: Icons.verified_outlined),
                      _HeaderChip(label: 'AI-powered', icon: Icons.auto_awesome),
                      _HeaderChip(label: 'Free templates', icon: Icons.style_outlined),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCta(ThemeData theme) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      child: InkWell(
        onTap: _openCreateResume,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: 14,
          ),
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: Text(
                  AppStrings.createNewResume,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  gradient: AppTheme.gradientBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Resume Score',
            value: '78%',
            subtitle: 'Good',
            icon: Icons.analytics_outlined,
            color: AppTheme.secondaryColor,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          child: _StatCard(
            title: 'Resumes',
            value: _resumes.length.toString(),
            subtitle: 'Saved',
            icon: Icons.folder_open_outlined,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAiBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.10),
            AppTheme.secondaryColor.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              gradient: AppTheme.gradientBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('AI Assistant', style: theme.textTheme.titleLarge),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Active',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Summary, experience, cover letters & ATS tips.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(int columns) {
    final actions = [
      _QuickActionCard(
        title: AppStrings.templates,
        subtitle: 'Browse designs',
        icon: Icons.dashboard_customize_outlined,
        color: AppTheme.accentColor,
        onTap: () => Navigator.pushNamed(context, '/templates'),
      ),
      _QuickActionCard(
        title: 'Cover Letter',
        subtitle: 'Generate with AI',
        icon: Icons.edit_note_outlined,
        color: AppTheme.secondaryColor,
        onTap: () => AdService.instance.showInterstitialThen(() {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CoverLetterScreen()),
          ).then((_) => _reloadDocuments());
        }),
      ),
      _QuickActionCard(
        title: AppStrings.atsScore,
        subtitle: 'Check compatibility',
        icon: Icons.analytics_outlined,
        color: AppTheme.primaryColor,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ATSScoreScreen()),
        ),
      ),
      _QuickActionCard(
        title: 'My Documents',
        subtitle: 'View & edit',
        icon: Icons.folder_open_outlined,
        color: AppTheme.warningColor,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyDocumentsScreen()),
        ).then((_) => _reloadDocuments()),
      ),
    ];

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppDimensions.paddingMedium,
        mainAxisSpacing: AppDimensions.paddingMedium,
        mainAxisExtent: 140,
      ),
      children: actions,
    );
  }

  Widget _buildEmptyRecent(ThemeData theme) {
    return CustomCard(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.note_add_outlined,
              color: AppTheme.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'No documents yet',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingXSmall),
          Text(
            'Create your first resume and it will show up here.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          PrimaryButton(
            label: AppStrings.createNewResume,
            onPressed: _openCreateResume,
            icon: Icons.add_rounded,
          ),
        ],
      ),
    );
  }

  Widget _decorCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Color _accentForIndex(int index) {
    const palette = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
    ];
    return palette[index % palette.length];
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _HeaderChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        child: Ink(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusLarge),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMedium),
                ),
                child: Icon(icon, color: color),
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMedium),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(title, style: theme.textTheme.titleLarge),
          Text(subtitle, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _RecentDocumentCard extends StatelessWidget {
  final SavedResume resume;
  final Color accent;
  final VoidCallback onTap;

  const _RecentDocumentCard({
    required this.resume,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobTitle = resume.data.jobTitle.trim();
    final name = resume.data.fullName.trim();
    final subtitle = jobTitle.isNotEmpty
        ? jobTitle
        : (name.isNotEmpty ? name : 'Resume');
    return Material(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        child: Ink(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusLarge),
            border: Border.all(color: AppTheme.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withOpacity(0.85),
                      accent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMedium),
                ),
                child: Text(
                  _initials(name),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      resume.title,
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _relativeDate(resume.updatedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: accent,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'CV';
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  String _relativeDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
