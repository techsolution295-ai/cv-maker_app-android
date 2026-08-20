import 'package:flutter/material.dart';
import 'package:cv_ganerator/config/theme.dart';
import 'package:cv_ganerator/constants/strings.dart';
import 'package:cv_ganerator/features/templates/models/resume_template.dart';
import 'package:cv_ganerator/features/templates/previews/template_thumbnail.dart';
import 'package:cv_ganerator/features/templates/registry/template_registry.dart';
import 'package:cv_ganerator/features/templates/sample/sample_resume_data.dart';
import 'package:cv_ganerator/models/resume_data.dart';
import 'package:cv_ganerator/models/saved_resume.dart';
import 'package:cv_ganerator/screens/template_preview_screen.dart';
import 'package:cv_ganerator/services/ad_service.dart';
import 'package:cv_ganerator/services/local_storage_service.dart';
import 'package:cv_ganerator/widgets/app_widgets.dart';
import 'package:cv_ganerator/widgets/banner_ad_widget.dart';
import 'package:cv_ganerator/widgets/common_widgets.dart';

class TemplateScreen extends StatefulWidget {
  final bool showAppBar;

  const TemplateScreen({super.key, this.showAppBar = true});

  @override
  State<TemplateScreen> createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen>
    with SingleTickerProviderStateMixin {
  TemplateCategory? _category;
  bool _favoritesOnly = false;
  List<String> _favorites = [];
  List<String> _recents = [];
  late ResumeData _previewData;
  late final AnimationController _pageIn;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _previewData = _loadResumeData();
    _reloadPrefs();
    _pageIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..forward();
  }

  @override
  void dispose() {
    _pageIn.dispose();
    super.dispose();
  }

  void _reloadPrefs() {
    final storage = LocalStorageService.instance;
    setState(() {
      _favorites = storage.getFavoriteTemplateIds();
      _recents = storage.getRecentTemplateIds();
    });
  }

  ResumeData _loadResumeData() {
    final saved = LocalStorageService.instance.getSavedResumes()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return SampleResumeData.forPreview(saved.isNotEmpty ? saved.first.data : null);
  }

  ResumeData _resumeData() => _previewData;

  SavedResume? _latestSaved() {
    final saved = LocalStorageService.instance.getSavedResumes()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return saved.isNotEmpty ? saved.first : null;
  }

  List<ResumeTemplate> get _filtered => TemplateRegistry.filter(
        category: _category,
        favoritesOnly: _favoritesOnly,
        favoriteIds: _favorites.toSet(),
      );

  @override
  Widget build(BuildContext context) {
    final templates = _filtered;
    final recents = _recents
        .map(TemplateRegistry.tryGetById)
        .whereType<ResumeTemplate>()
        .toList();
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: widget.showAppBar ? const AppAppBar(title: AppStrings.templates) : null,
      body: Column(
        children: [
          BannerAdWidget(
            adUnitId: AdService.bannerAdUnitId,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          ),
          _StickyFilters(chips: _filterChips()),
          Expanded(
            child: ThumbnailScrollScope(
              isScrolling: _isScrolling,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _pageIn,
                  curve: Curves.easeOutCubic,
                ),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollStartNotification) {
                      if (!_isScrolling) setState(() => _isScrolling = true);
                    } else if (notification is ScrollEndNotification) {
                      if (_isScrolling) setState(() => _isScrolling = false);
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                slivers: [
                  if (recents.isNotEmpty &&
                      _category == null &&
                      !_favoritesOnly)
                    SliverToBoxAdapter(child: _recentRow(recents)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;
                        final count = width >= 900 ? 4 : width >= 600 ? 3 : 2;
                        return SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: count,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.707,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final template = templates[index];
                              return _TemplateCard(
                                key: ValueKey(template.id),
                                index: index,
                                template: template,
                                resumeData: _previewData,
                                isFavorite: _favorites.contains(template.id),
                                onFavorite: () => _toggleFavorite(template),
                                onTap: () => _openPreview(template),
                              );
                            },
                            childCount: templates.length,
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _filterChips() {
    return [
      _chip(
        'All',
        _category == null && !_favoritesOnly,
        () {
          setState(() {
            _category = null;
            _favoritesOnly = false;
          });
        },
      ),
      _chip(
        'Favorites',
        _favoritesOnly,
        () {
          setState(() {
            _favoritesOnly = true;
            _category = null;
          });
        },
        icon: Icons.favorite_rounded,
      ),
      for (final category in TemplateCategory.values)
        _chip(
          _label(category),
          _category == category && !_favoritesOnly,
          () {
            setState(() {
              _category = category;
              _favoritesOnly = false;
            });
          },
        ),
    ];
  }

  Widget _chip(
    String label,
    bool selected,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    final foreground = selected ? Colors.white : const Color(0xFF334155);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.fromLTRB(icon == null ? 16 : 12, 8, 16, 8),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: foreground),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recentRow(List<ResumeTemplate> recents) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recently Used',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 192,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              itemCount: recents.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final template = recents[index];
                return SizedBox(
                  width: 136,
                  child: _TemplateCard(
                    key: ValueKey('recent-${template.id}'),
                    index: index,
                    template: template,
                    resumeData: _previewData,
                    isFavorite: _favorites.contains(template.id),
                    onFavorite: () => _toggleFavorite(template),
                    onTap: () => _openPreview(template),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _label(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.ats:
        return 'ATS';
      case TemplateCategory.modern:
        return 'Modern';
      case TemplateCategory.executive:
        return 'Executive';
      case TemplateCategory.creative:
        return 'Creative';
      case TemplateCategory.tech:
        return 'Tech';
      case TemplateCategory.academic:
        return 'Academic';
      case TemplateCategory.elegant:
        return 'Elegant';
      case TemplateCategory.additional:
        return 'More';
    }
  }

  Future<void> _toggleFavorite(ResumeTemplate template) async {
    final value =
        await LocalStorageService.instance.toggleFavoriteTemplate(template.id);
    if (!mounted) return;
    setState(() => _favorites = LocalStorageService.instance.getFavoriteTemplateIds());
    AppSnackBar.success(
      context,
      value ? 'Template added to favorites' : 'Removed from favorites',
    );
  }

  Future<void> _openPreview(ResumeTemplate template) async {
    await Navigator.push(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => TemplatePreviewScreen(
          template: template,
          resumeData: _resumeData(),
          savedResume: _latestSaved(),
        ),
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        transitionsBuilder: (context, animation, secondary, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
    _reloadPrefs();
  }
}

class _TemplateCard extends StatefulWidget {
  final int index;
  final ResumeTemplate template;
  final ResumeData resumeData;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const _TemplateCard({
    super.key,
    required this.index,
    required this.template,
    required this.resumeData,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0x1F0F172A)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _pressed ? 0.05 : 0.10),
              blurRadius: _pressed ? 4 : 10,
              offset: Offset(0, _pressed ? 1 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            child: Stack(
              fit: StackFit.expand,
              children: [
                TemplateThumbnail(
                  template: widget.template,
                  resumeData: widget.resumeData,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: _CornerHeart(
                    isFavorite: widget.isFavorite,
                    onTap: widget.onFavorite,
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

class _StickyFilters extends StatelessWidget {
  final List<Widget> chips;

  const _StickyFilters({required this.chips});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.backgroundColor,
      child: SizedBox(
        height: 46,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 4, 12, 10),
          children: chips,
        ),
      ),
    );
  }
}

class _CornerHeart extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _CornerHeart({
    required this.isFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      elevation: 1,
      shadowColor: Colors.black26,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(6),
          bottomLeft: Radius.circular(10),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 16,
            color: isFavorite ? const Color(0xFFE11D48) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
