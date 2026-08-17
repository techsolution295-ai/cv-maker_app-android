import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cv_ganerator/config/theme.dart';
import 'package:cv_ganerator/constants/dimensions.dart';
import 'package:cv_ganerator/constants/strings.dart';
import 'package:cv_ganerator/models/resume_data.dart';
import 'package:cv_ganerator/models/saved_resume.dart';
import 'package:cv_ganerator/screens/resume_preview_screen.dart';
import 'package:cv_ganerator/services/local_storage_service.dart';
import 'package:cv_ganerator/services/resume_ai_assistant_service.dart';
import 'package:cv_ganerator/services/ad_service.dart';
import 'package:cv_ganerator/widgets/app_widgets.dart';
import 'package:cv_ganerator/widgets/banner_ad_widget.dart';
import 'package:cv_ganerator/widgets/common_widgets.dart';
import 'package:image_picker/image_picker.dart';

class ResumeCreationScreen extends StatefulWidget {
  const ResumeCreationScreen({super.key});

  @override
  State<ResumeCreationScreen> createState() => _ResumeCreationScreenState();
}

class _ResumeCreationScreenState extends State<ResumeCreationScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _isInitialized = false;

  // Controllers
  final _nameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _summaryController = TextEditingController();
  final _websiteController = TextEditingController();
  final _linkedinController = TextEditingController();

  // Lists for dynamic content
  final List<ExperienceItem> _experienceItems = [];
  final List<EducationItem> _educationItems = [];
  final List<String> _skills = [];
  final List<String> _languages = [];
  final List<String> _references = [];

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final ResumeAiAssistantService _aiAssistant = ResumeAiAssistantService();
  bool _isGeneratingSummary = false;
  late final VoidCallback _autoSaveListener;

  final List<String> _stepTitles = [
    'Personal',
    'Experience',
    'Education',
    'Skills & More',
    'Summary & Photo',
  ];

  @override
  void initState() {
    super.initState();
    _attachAutoSave();
  }

  void _attachAutoSave() {
    _autoSaveListener = _saveDraft;
    _nameController.addListener(_autoSaveListener);
    _jobTitleController.addListener(_autoSaveListener);
    _emailController.addListener(_autoSaveListener);
    _phoneController.addListener(_autoSaveListener);
    _locationController.addListener(_autoSaveListener);
    _summaryController.addListener(_autoSaveListener);
    _websiteController.addListener(_autoSaveListener);
    _linkedinController.addListener(_autoSaveListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadDraft();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_autoSaveListener);
    _jobTitleController.removeListener(_autoSaveListener);
    _emailController.removeListener(_autoSaveListener);
    _phoneController.removeListener(_autoSaveListener);
    _locationController.removeListener(_autoSaveListener);
    _summaryController.removeListener(_autoSaveListener);
    _websiteController.removeListener(_autoSaveListener);
    _linkedinController.removeListener(_autoSaveListener);

    _nameController.dispose();
    _jobTitleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final draft = LocalStorageService.instance.getResumeDraft();
    Map<String, dynamic> content = {};
    if (draft != null) {
      content = draft['content'] as Map<String, dynamic>? ?? {};
    } else {
      final savedResumes = LocalStorageService.instance.getSavedResumes();
      if (savedResumes.isNotEmpty) {
        savedResumes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        content = savedResumes.first.data.toMap();
      }
    }

    if (content.isNotEmpty) {
      setState(() {
        _nameController.text = content['fullName'] ?? '';
        _jobTitleController.text = content['jobTitle'] ?? '';
        _emailController.text = content['email'] ?? '';
        _phoneController.text = content['phone'] ?? '';
        _locationController.text = content['location'] ?? '';
        _summaryController.text = content['summary'] ?? '';
        _websiteController.text = content['website'] ?? '';
        _linkedinController.text = content['linkedin'] ?? '';

        _skills.clear();
        _skills.addAll(
            (content['skills'] as List<dynamic>?)?.cast<String>() ?? []);

        _languages.clear();
        _languages.addAll(
            (content['languages'] as List<dynamic>?)?.cast<String>() ?? []);

        _references.clear();
        _references.addAll(
            (content['references'] as List<dynamic>?)?.cast<String>() ?? []);

        _experienceItems.clear();
        _experienceItems.addAll((content['experience'] as List<dynamic>?)
                ?.map((e) => ExperienceItem.fromMap(e as Map<String, dynamic>))
                .toList() ??
            []);

        _educationItems.clear();
        _educationItems.addAll((content['education'] as List<dynamic>?)
                ?.map((e) => EducationItem.fromMap(e as Map<String, dynamic>))
                .toList() ??
            []);

        final photoUrl = content['photoUrl'] ?? '';
        if (photoUrl.isNotEmpty && File(photoUrl).existsSync()) {
          _imageFile = XFile(photoUrl);
        }
      });
    }
  }

  Future<void> _saveDraft() async {
    final resume = _buildResumeData();
    final draft = {
      'currentStep': _currentStep,
      'content': resume.toMap(),
    };
    await LocalStorageService.instance.saveResumeDraft(draft);
  }

  ResumeData _buildResumeData() {
    return ResumeData(
      fullName: _nameController.text.trim(),
      jobTitle: _jobTitleController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      summary: _summaryController.text.trim(),
      skills: List<String>.from(_skills),
      experience: List<ExperienceItem>.from(_experienceItems),
      education: List<EducationItem>.from(_educationItems),
      photoUrl: _imageFile?.path ?? '',
      languages: List<String>.from(_languages),
      references: List<String>.from(_references),
      website: _websiteController.text.trim(),
      linkedin: _linkedinController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppAppBar(
        title: AppStrings.createNewResume,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _saveDraft();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          BannerAdWidget(adUnitId: AdService.bannerAdUnitId),
          _buildProgressBar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: SingleChildScrollView(
                key: ValueKey<int>(_currentStep),
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCurrentStep(),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentStep + 1) / _stepTitles.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingLarge,
        AppDimensions.paddingMedium,
        AppDimensions.paddingLarge,
        AppDimensions.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of ${_stepTitles.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                _stepTitles[_currentStep],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_stepTitles.length, (index) {
              final isDone = index < _currentStep;
              final isActive = index == _currentStep;
              final dotColor = (isDone || isActive)
                  ? AppTheme.primaryColor
                  : Colors.grey.shade200;
              return Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 15)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isActive
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    if (index != _stepTitles.length - 1)
                      Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isDone
                                ? AppTheme.primaryColor
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            borderRadius: BorderRadius.circular(8),
            minHeight: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildExperienceStep();
      case 2:
        return _buildEducationStep();
      case 3:
        return _buildSkillsAndLanguagesStep();
      case 4:
        return _buildSummaryAndPhotoStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal Details', 'Basic info to identify you'),
        CustomTextField(
          label: AppStrings.fullName,
          hint: 'e.g. John Doe',
          controller: _nameController,
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        CustomTextField(
          label: AppStrings.jobTitle,
          hint: 'e.g. Senior Software Engineer',
          controller: _jobTitleController,
          prefixIcon: Icons.work_outline,
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        CustomTextField(
          label: AppStrings.email,
          hint: 'e.g. john.doe@example.com',
          controller: _emailController,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        CustomTextField(
          label: AppStrings.phone,
          hint: 'e.g. +1 234 567 890',
          controller: _phoneController,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        CustomTextField(
          label: AppStrings.location,
          hint: 'e.g. New York, USA',
          controller: _locationController,
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        _buildSectionTitle('Social Links', 'Where else can they find you?'),
        CustomTextField(
          label: 'Website / Portfolio',
          hint: 'e.g. www.johndoe.com',
          controller: _websiteController,
          prefixIcon: Icons.language_outlined,
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        CustomTextField(
          label: 'LinkedIn URL',
          hint: 'e.g. linkedin.com/in/johndoe',
          controller: _linkedinController,
          prefixIcon: Icons.link_outlined,
        ),
      ],
    );
  }

  Widget _buildExperienceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Work Experience', 'Your professional history'),
            IconButton(
              onPressed: _showAddExperienceDialog,
              icon: Icon(Icons.add_circle,
                  color: AppTheme.primaryColor, size: 32),
            ),
          ],
        ),
        if (_experienceItems.isEmpty)
          _buildEmptyState(
              'No experience added yet.', Icons.business_center_outlined)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _experienceItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _experienceItems[index];
              return _buildRemovableItem(
                title: item.title,
                subtitle: item.company,
                trailing: item.duration,
                onDelete: () =>
                    setState(() => _experienceItems.removeAt(index)),
                onEdit: () =>
                    _showAddExperienceDialog(item: item, index: index),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEducationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Education', 'Your academic background'),
            IconButton(
              onPressed: _showAddEducationDialog,
              icon: Icon(Icons.add_circle,
                  color: AppTheme.primaryColor, size: 32),
            ),
          ],
        ),
        if (_educationItems.isEmpty)
          _buildEmptyState('No education added yet.', Icons.school_outlined)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _educationItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _educationItems[index];
              return _buildRemovableItem(
                title: item.degree,
                subtitle: item.school,
                trailing: item.year,
                icon: Icons.school_outlined,
                onDelete: () => setState(() => _educationItems.removeAt(index)),
                onEdit: () => _showAddEducationDialog(item: item, index: index),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSkillsAndLanguagesStep() {
    final skillController = TextEditingController();
    final langController = TextEditingController();
    final refController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Skills', 'Key expertise'),
        _buildListInput(
          controller: skillController,
          hint: 'e.g. Project Management',
          onAdd: (val) => setState(() => _skills.add(val)),
          items: _skills,
          onRemove: (index) => setState(() => _skills.removeAt(index)),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        _buildSectionTitle('Languages', 'Languages you speak'),
        _buildListInput(
          controller: langController,
          hint: 'e.g. English (Fluent)',
          onAdd: (val) => setState(() => _languages.add(val)),
          items: _languages,
          onRemove: (index) => setState(() => _languages.removeAt(index)),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        _buildSectionTitle('References', 'People who can vouch for you'),
        _buildListInput(
          controller: refController,
          hint: 'e.g. Jane Smith (Manager at Apple)',
          onAdd: (val) => setState(() => _references.add(val)),
          items: _references,
          onRemove: (index) => setState(() => _references.removeAt(index)),
        ),
      ],
    );
  }

  Widget _buildSummaryAndPhotoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Profile Photo', 'A professional photo (Optional)'),
        Center(
          child: Stack(
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: ClipOval(
                  child: _imageFile != null
                      ? Image.file(File(_imageFile!.path), fit: BoxFit.cover)
                      : Icon(Icons.person_add_alt_1_outlined,
                          size: 60, color: Colors.grey.shade400),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () => _showImagePickerOptions(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge * 1.5),
        _buildSectionTitle(
            'Professional Summary', 'A brief overview of your value'),
        _buildAiHelperCard(
          title: 'Write my summary with AI',
          subtitle:
              'AI will craft a clean summary from your job title, skills, and latest experience.',
          onPressed: _generateSummaryWithAI,
          isLoading: _isGeneratingSummary,
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        CustomTextField(
          label: 'Summary',
          hint: 'Highlight your key achievements and career goals...',
          controller: _summaryController,
          maxLines: 6,
          prefixIcon: Icons.description_outlined,
        ),
      ],
    );
  }

  Widget _buildAiHelperCard({
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.12),
            AppTheme.secondaryColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.bolt),
            label: Text(isLoading ? 'Writing...' : 'Generate'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildRemovableItem({
    required String title,
    required String subtitle,
    required String trailing,
    required VoidCallback onDelete,
    required VoidCallback onEdit,
    IconData icon = Icons.work_outline,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (trailing.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trailing,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.edit_outlined,
                size: 20, color: AppTheme.secondaryColor),
            onPressed: onEdit,
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.delete_outline,
                size: 20, color: AppTheme.errorColor),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildListInput({
    required TextEditingController controller,
    required String hint,
    required Function(String) onAdd,
    required List<String> items,
    required Function(int) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Add New',
                hint: hint,
                controller: controller,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    onAdd(controller.text.trim());
                    controller.clear();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(items.length, (index) {
            return Chip(
              label: Text(items[index]),
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.08),
              labelStyle: TextStyle(color: AppTheme.primaryColor, fontSize: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => onRemove(index),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    final isLast = _currentStep == _stepTitles.length - 1;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: SecondaryButton(
                label: 'Back',
                onPressed: () => setState(() => _currentStep--),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              label: isLast ? 'Finish & View' : 'Next Step',
              onPressed: _currentStep < _stepTitles.length - 1
                  ? () {
                      if (_validateStep()) {
                        setState(() => _currentStep++);
                        _saveDraft();
                      }
                    }
                  : _finishResume,
              isLoading: _isSubmitting,
            ),
          ),
        ],
      ),
    );
  }

  bool _validateStep() {
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty) {
        _showError('Please enter your full name');
        return false;
      }
    }
    return true;
  }

  void _showError(String msg) {
    AppSnackBar.error(context, msg);
  }

  Future<void> _finishResume() async {
    setState(() => _isSubmitting = true);
    try {
      final resume = _buildResumeData();
      final resumeTitle =
          resume.fullName.isEmpty ? AppStrings.resumeTitle : resume.fullName;

      final savedResume = SavedResume(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: resumeTitle,
        data: resume,
        updatedAt: DateTime.now(),
      );

      await LocalStorageService.instance.saveResumeData(savedResume);
      await LocalStorageService.instance.clearResumeDraft();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResumePreviewScreen(
            resumeTitle: resumeTitle,
            resumeData: resume,
            allowEditing: true,
          ),
        ),
      );
    } catch (e) {
      _showError('Failed to save resume: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showAddExperienceDialog({ExperienceItem? item, int? index}) {
    final titleC = TextEditingController(text: item?.title);
    final compC = TextEditingController(text: item?.company);
    final durC = TextEditingController(text: item?.duration);
    final descC = TextEditingController(text: item?.description);
    bool isGeneratingDescription = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Add Experience' : 'Edit Experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                    label: 'Job Title',
                    hint: 'e.g. Designer',
                    controller: titleC),
                const SizedBox(height: 12),
                CustomTextField(
                    label: 'Company', hint: 'e.g. Google', controller: compC),
                const SizedBox(height: 12),
                CustomTextField(
                    label: 'Duration',
                    hint: 'e.g. 2020 - 2022',
                    controller: durC),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: isGeneratingDescription
                        ? null
                        : () async {
                            if (titleC.text.trim().isEmpty &&
                                compC.text.trim().isEmpty) {
                              _showError(
                                  'Add job title or company so AI can write relevant text.');
                              return;
                            }
                            setDialogState(
                                () => isGeneratingDescription = true);
                            final generated = await _aiAssistant
                                .generateExperienceDescription(
                              jobTitle: titleC.text.trim(),
                              company: compC.text.trim(),
                              duration: durC.text.trim(),
                            );
                            descC.text = generated;
                            setDialogState(
                                () => isGeneratingDescription = false);
                          },
                    icon: isGeneratingDescription
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(isGeneratingDescription
                        ? 'AI is writing...'
                        : 'Generate description with AI'),
                  ),
                ),
                CustomTextField(
                    label: 'Description',
                    hint: 'Key responsibilities...',
                    controller: descC,
                    maxLines: 3),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleC.text.isEmpty || compC.text.isEmpty) return;
                final newItem = ExperienceItem(
                  title: titleC.text.trim(),
                  company: compC.text.trim(),
                  duration: durC.text.trim(),
                  description: descC.text.trim(),
                );
                setState(() {
                  if (index != null) {
                    _experienceItems[index] = newItem;
                  } else {
                    _experienceItems.add(newItem);
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEducationDialog({EducationItem? item, int? index}) {
    final degC = TextEditingController(text: item?.degree);
    final schoolC = TextEditingController(text: item?.school);
    final yearC = TextEditingController(text: item?.year);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Add Education' : 'Edit Education'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                  label: 'Degree', hint: 'e.g. Bachelor', controller: degC),
              const SizedBox(height: 12),
              CustomTextField(
                  label: 'Institute', hint: 'e.g. MIT', controller: schoolC),
              const SizedBox(height: 12),
              CustomTextField(
                  label: 'Year', hint: 'e.g. 2022', controller: yearC),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (degC.text.isEmpty || schoolC.text.isEmpty) return;
              final newItem = EducationItem(
                degree: degC.text.trim(),
                school: schoolC.text.trim(),
                year: yearC.text.trim(),
              );
              setState(() {
                if (index != null) {
                  _educationItems[index] = newItem;
                } else {
                  _educationItems.add(newItem);
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() => _imageFile = image);
    }
  }

  Future<void> _generateSummaryWithAI() async {
    final role = _jobTitleController.text.trim();
    if (role.isEmpty) {
      _showError('Please add job title first for better AI summary.');
      return;
    }

    setState(() => _isGeneratingSummary = true);
    try {
      final summary = await _aiAssistant.generateSummary(
        fullName: _nameController.text.trim(),
        jobTitle: role,
        skills: _skills,
        experiences: _experienceItems,
      );
      _summaryController.text = summary;
      _saveDraft();
      if (!mounted) return;
      AppSnackBar.success(context, 'AI summary generated successfully.');
    } catch (e) {
      if (!mounted) return;
      _showError('AI summary generation failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isGeneratingSummary = false);
      }
    }
  }
}
