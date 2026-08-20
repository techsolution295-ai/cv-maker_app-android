import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cv_ganerator/constants/dimensions.dart';
import 'package:cv_ganerator/constants/strings.dart';
import 'package:cv_ganerator/features/templates/customization/customization_sheet.dart';
import 'package:cv_ganerator/features/templates/models/resume_template.dart';
import 'package:cv_ganerator/features/templates/registry/template_registry.dart';
import 'package:cv_ganerator/features/templates/previews/paged_resume_view.dart';
import 'package:cv_ganerator/models/resume_data.dart';
import 'package:cv_ganerator/services/resume_pdf_service.dart';
import 'package:cv_ganerator/services/file_storage_service.dart';
import 'package:cv_ganerator/services/ad_service.dart';
import 'package:cv_ganerator/services/resume_ai_assistant_service.dart';
import 'package:cv_ganerator/widgets/common_widgets.dart';
import 'package:cv_ganerator/widgets/app_widgets.dart';
import 'package:cv_ganerator/widgets/banner_ad_widget.dart';
import 'package:cv_ganerator/widgets/resume_templates.dart';

import 'package:printing/printing.dart';

class ResumePreviewScreen extends StatefulWidget {
  final String resumeTitle;
  final ResumeData? resumeData;
  final bool allowEditing;
  final ResumeTemplateKind initialTemplate;
  final String? initialTemplateId;
  final TemplateCustomization? customization;

  const ResumePreviewScreen({
    required this.resumeTitle,
    this.resumeData,
    this.allowEditing = false,
    this.initialTemplate = ResumeTemplateKind.travis,
    this.initialTemplateId,
    this.customization,
    super.key,
  });

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> {
  bool _isPrinting = false;
  bool _isSaving = false;
  bool _isEditing = false;
  bool _isPolishingSummary = false;
  final ResumePdfService _pdfService = ResumePdfService();
  final FileStorageService _fileStorage = FileStorageService();
  final ResumeAiAssistantService _aiAssistant = ResumeAiAssistantService();
  late ResumeData _data;
  late final TextEditingController _fullNameController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  late final TextEditingController _summaryController;
  late final TextEditingController _skillsController;
  late final TextEditingController _languagesController;
  late final TextEditingController _referencesController;
  late final TextEditingController _photoUrlController;
  late final TextEditingController _websiteController;
  late final TextEditingController _linkedinController;
  late List<ExperienceItem> _experience;
  late List<EducationItem> _education;
  late String _templateId;
  late TemplateCustomization _customization;

  @override
  void initState() {
    super.initState();
    _data = widget.resumeData ?? _sampleData();
    _templateId = widget.initialTemplateId ??
        kLegacyTemplateIds[widget.initialTemplate] ??
        'ats_classic';
    _customization = widget.customization ?? const TemplateCustomization();
    _fullNameController = TextEditingController(text: _data.fullName);
    _jobTitleController = TextEditingController(text: _data.jobTitle);
    _emailController = TextEditingController(text: _data.email);
    _phoneController = TextEditingController(text: _data.phone);
    _locationController = TextEditingController(text: _data.location);
    _summaryController = TextEditingController(text: _data.summary);
    _skillsController = TextEditingController(text: _data.skills.join(', '));
    _languagesController =
        TextEditingController(text: _data.languages.join(', '));
    _referencesController =
        TextEditingController(text: _data.references.join(', '));
    _photoUrlController = TextEditingController(text: _data.photoUrl);
    _websiteController = TextEditingController(text: _data.website);
    _linkedinController = TextEditingController(text: _data.linkedin);
    _experience = List<ExperienceItem>.from(_data.experience);
    _education = List<EducationItem>.from(_data.education);
    AdService.instance.preloadInterstitial();
    for (final controller in [
      _fullNameController,
      _jobTitleController,
      _emailController,
      _phoneController,
      _locationController,
      _summaryController,
      _skillsController,
      _languagesController,
      _referencesController,
      _photoUrlController,
      _websiteController,
      _linkedinController,
    ]) {
      controller.addListener(_applyLiveEdits);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _jobTitleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    _skillsController.dispose();
    _languagesController.dispose();
    _referencesController.dispose();
    _photoUrlController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  static const Color _desk = Color(0xFFE6EDF4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _desk,
      appBar: AppBar(
        backgroundColor: _desk,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppStrings.resumeTitle,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.style_outlined),
            onPressed: _changeTemplate,
            tooltip: 'Templates',
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _customize,
            tooltip: 'Customize',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePDF,
            tooltip: AppStrings.share,
          ),
          if (widget.allowEditing)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: _toggleEdit,
              tooltip: _isEditing ? AppStrings.save : AppStrings.edit,
            ),
        ],
      ),
      body: Column(
        children: [
          BannerAdWidget(adUnitId: AdService.bannerAdUnitId),
          Expanded(
            child: _isEditing ? _buildEditingLayout() : _buildTemplatePreview(),
          ),
          if (!_isEditing) _buildPrintBar(),
        ],
      ),
    );
  }

  Widget _buildTemplatePreview() {
    return PagedResumeView(
      resumeData: _data,
      templateId: _templateId,
      customization: _customization,
      scrollable: true,
      maxPages: 1,
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
    );
  }

  Widget _buildEditingLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditPanel(),
          const SizedBox(height: AppDimensions.paddingLarge),
          PagedResumeView(
            resumeData: _data,
            templateId: _templateId,
            customization: _customization,
            maxPages: 1,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildExperienceEditors(),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildEducationEditors(),
        ],
      ),
    );
  }

  Widget _buildPrintBar() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: _isPrinting
                      ? 'Opening Print...'
                      : AppStrings.printResume,
                  onPressed: (_isPrinting || _isSaving) ? null : _printPDF,
                  icon: _isPrinting ? Icons.hourglass_top : null,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: PrimaryButton(
                  label: AppStrings.saveToGallery,
                  onPressed:
                      (_isSaving || _isPrinting) ? null : _savePdfToPhone,
                  isLoading: _isSaving,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _printPDF() async {
    if (_isPrinting) return;
    setState(() => _isPrinting = true);
    try {
      await AdService.instance.showInterstitialThen(
        () async {
          final pdfData = await _pdfService.buildPdf(
            data: _data,
            title: widget.resumeTitle,
            templateId: _templateId,
            customization: _customization,
          );
          await Printing.layoutPdf(onLayout: (format) async => pdfData);
          if (mounted) {
            AppSnackBar.info(context, 'Print dialog opened');
          }
        },
        waitForAd: true,
      );
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(context, 'Failed to print PDF: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  Future<void> _savePdfToPhone() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await AdService.instance.showInterstitialThen(() async {
        final pdfData = await _pdfService.buildPdf(
          data: _data,
          title: widget.resumeTitle,
          templateId: _templateId,
          customization: _customization,
        );
        final baseName =
            _data.fullName.isNotEmpty ? _data.fullName : widget.resumeTitle;
        final result = await _fileStorage.savePdf(
          bytes: pdfData,
          baseName: baseName,
        );
        if (mounted) {
          AppSnackBar.success(
            context,
            'Resume saved to ${result.displayLocation}',
          );
        }
      });
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(context, 'Failed to save PDF. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _sharePDF() async {
    if (_isPrinting) return;
    setState(() => _isPrinting = true);
    try {
      final pdfData = await _pdfService.buildPdf(
        data: _data,
        title: widget.resumeTitle,
        templateId: _templateId,
        customization: _customization,
      );
      final baseName =
          _data.fullName.isNotEmpty ? _data.fullName : widget.resumeTitle;
      await Printing.sharePdf(
        bytes: pdfData,
        filename: _fileStorage.pdfFileNameFor(baseName),
      );
      if (mounted) {
        AppSnackBar.info(context, 'Share sheet opened');
      }
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(context, 'Failed to share PDF: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  void _applyLiveEdits() {
    if (!_isEditing) return;
    setState(() {
      _data = _data.copyWith(
        fullName: _fullNameController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        summary: _summaryController.text.trim(),
        skills: _splitList(_skillsController.text),
        languages: _splitList(_languagesController.text),
        references: _splitList(_referencesController.text),
        photoUrl: _photoUrlController.text.trim(),
        website: _websiteController.text.trim(),
        linkedin: _linkedinController.text.trim(),
        experience: List<ExperienceItem>.from(_experience),
        education: List<EducationItem>.from(_education),
      );
    });
  }

  Future<void> _customize() async {
    final template = TemplateRegistry.getById(_templateId);
    final updated = await showCustomizationSheet(
      context: context,
      template: template,
      data: _data,
      customization: _customization,
    );
    if (updated == null || !mounted) return;
    setState(() {
      _customization = updated;
      if (updated.sectionOrder.isNotEmpty ||
          updated.sectionVisibility.isNotEmpty ||
          updated.sectionTitles.isNotEmpty) {
        final extraIds = updated.sectionOrder.where((id) {
          if (ResumeSectionIds.builtIn.contains(id)) return false;
          return !_data.customSections.any((section) => section.id == id);
        });
        _data = _data.copyWith(
          sectionOrder: updated.sectionOrder.isNotEmpty
              ? updated.sectionOrder
              : _data.sectionOrder,
          sectionVisibility: {
            ..._data.sectionVisibility,
            ...updated.sectionVisibility,
          },
          sectionTitles: {
            ..._data.sectionTitles,
            ...updated.sectionTitles,
          },
          customSections: [
            ..._data.customSections,
            ...extraIds.map(
              (id) => CustomSection(
                id: id,
                title: updated.sectionTitles[id] ?? 'Custom Section',
              ),
            ),
          ],
        );
      }
    });
  }

  Future<void> _changeTemplate() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final templates = TemplateRegistry.allTemplates;
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Switch template',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return ListTile(
                      title: Text(template.name),
                      subtitle: Text(
                        [
                          template.categoryLabel,
                          if (template.atsFriendly) 'ATS Friendly',
                        ].join(' • '),
                      ),
                      trailing: template.id == _templateId
                          ? const Icon(Icons.check, color: Color(0xFF1F5AA6))
                          : null,
                      onTap: () => Navigator.pop(context, template.id),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    setState(() => _templateId = selected);
  }

  void _toggleEdit() {
    if (_isEditing) {
      final skills = _skillsController.text
          .split(',')
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toList();
      final languages = _splitList(_languagesController.text);
      final references = _splitList(_referencesController.text);
      _data = _data.copyWith(
        fullName: _fullNameController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        summary: _summaryController.text.trim(),
        skills: skills,
        experience: _experience,
        education: _education,
        languages: languages,
        references: references,
        photoUrl: _photoUrlController.text.trim(),
        website: _websiteController.text.trim(),
        linkedin: _linkedinController.text.trim(),
      );
    }
    setState(() => _isEditing = !_isEditing);
  }

  List<String> _splitList(String raw) {
    return raw
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('file://')) {
      return FileImage(File(path.replaceFirst('file://', '')));
    } else {
      return FileImage(File(path));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _photoUrlController.text = image.path;
        _data = _data.copyWith(photoUrl: image.path);
      });
    }
  }

  Widget _buildHeaderField({
    required TextEditingController controller,
    required String hint,
    required TextStyle? style,
    TextAlign textAlign = TextAlign.center,
  }) {
    return TextField(
      controller: controller,
      textAlign: textAlign,
      style: style,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        border: const UnderlineInputBorder(),
      ),
    );
  }

  Widget _buildEditPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edit Details',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        _buildHeaderField(
          controller: _fullNameController,
          hint: AppStrings.fullName,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.start,
        ),
        _buildHeaderField(
          controller: _jobTitleController,
          hint: AppStrings.jobTitle,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.start,
        ),
        _buildHeaderField(
          controller: _emailController,
          hint: AppStrings.email,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.start,
        ),
        _buildHeaderField(
          controller: _phoneController,
          hint: AppStrings.phone,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.start,
        ),
        _buildHeaderField(
          controller: _locationController,
          hint: AppStrings.location,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        TextField(
          controller: _summaryController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Summary',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Align(
          alignment: Alignment.centerLeft,
          child: SecondaryButton(
            label: _isPolishingSummary
                ? 'AI is improving summary...'
                : 'Polish Summary with AI',
            onPressed: _isPolishingSummary ? null : _polishSummaryWithAi,
            icon: Icons.auto_awesome,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        TextField(
          controller: _skillsController,
          decoration: const InputDecoration(
            hintText: 'Skills (comma separated)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        TextField(
          controller: _languagesController,
          decoration: const InputDecoration(
            hintText: 'Languages (comma separated)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        TextField(
          controller: _referencesController,
          decoration: const InputDecoration(
            hintText: 'References (comma separated)',
            border: OutlineInputBorder(),
          ),
        ),
        if (_templateSupportsProfilePhoto()) ...[
          const SizedBox(height: AppDimensions.paddingSmall),
          Row(
            children: [
              if (_photoUrlController.text.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(right: AppDimensions.paddingMedium),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        _getImageProvider(_photoUrlController.text),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Profile Photo',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            label: 'Gallery',
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: Icons.image,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Expanded(
                          child: SecondaryButton(
                            label: 'Camera',
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: Icons.camera_alt,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppDimensions.paddingSmall),
        TextField(
          controller: _websiteController,
          decoration: const InputDecoration(
            hintText: 'Website',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        TextField(
          controller: _linkedinController,
          decoration: const InputDecoration(
            hintText: 'LinkedIn',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Future<void> _polishSummaryWithAi() async {
    setState(() => _isPolishingSummary = true);
    try {
      final generated = await _aiAssistant.generateSummary(
        fullName: _fullNameController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
        skills: _splitList(_skillsController.text),
        experiences: _experience,
      );
      if (!mounted) return;
      setState(() => _summaryController.text = generated);
    } finally {
      if (mounted) {
        setState(() => _isPolishingSummary = false);
      }
    }
  }

  bool _templateSupportsProfilePhoto() {
    if (_customization.photoMode == PhotoMode.hide) return false;
    if (_customization.photoMode == PhotoMode.show) return true;
    return TemplateRegistry.getById(_templateId).photoStyle != PhotoStyle.none;
  }

  Widget _buildExperienceEditors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edit Experience',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        for (var i = 0; i < _experience.length; i++) ...[
          _buildExperienceEditor(
            item: _experience[i],
            onChanged: (updated) {
              setState(() {
                _experience[i] = updated;
                _applyLiveEdits();
              });
            },
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
        ],
      ],
    );
  }

  Widget _buildEducationEditors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edit Education',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        for (var i = 0; i < _education.length; i++) ...[
          _buildEducationEditor(
            item: _education[i],
            onChanged: (updated) {
              setState(() {
                _education[i] = updated;
                _applyLiveEdits();
              });
            },
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
        ],
      ],
    );
  }

  Widget _buildExperienceEditor({
    required ExperienceItem item,
    required ValueChanged<ExperienceItem> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: item.title,
          onChanged: (value) => onChanged(item.copyWith(title: value)),
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        TextFormField(
          initialValue: item.company,
          onChanged: (value) => onChanged(item.copyWith(company: value)),
          decoration: const InputDecoration(
            labelText: 'Company',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        TextFormField(
          initialValue: item.duration,
          onChanged: (value) => onChanged(item.copyWith(duration: value)),
          decoration: const InputDecoration(
            labelText: 'Duration',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        TextFormField(
          initialValue: item.description,
          onChanged: (value) => onChanged(item.copyWith(description: value)),
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildEducationEditor({
    required EducationItem item,
    required ValueChanged<EducationItem> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: item.degree,
          onChanged: (value) => onChanged(item.copyWith(degree: value)),
          decoration: const InputDecoration(
            labelText: 'Degree',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        TextFormField(
          initialValue: item.school,
          onChanged: (value) => onChanged(item.copyWith(school: value)),
          decoration: const InputDecoration(
            labelText: 'School',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        TextFormField(
          initialValue: item.year,
          onChanged: (value) => onChanged(item.copyWith(year: value)),
          decoration: const InputDecoration(
            labelText: 'Year',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  ResumeData _sampleData() {
    return const ResumeData(
      fullName: 'John Doe',
      jobTitle: 'Senior Software Engineer',
      email: 'john@example.com',
      phone: '+1 (555) 123-4567',
      location: 'New York, USA',
      summary:
          'Experienced software engineer with 5+ years of expertise in full-stack development. Proficient in Flutter, React, and backend technologies. Strong track record of delivering high-quality solutions.',
      skills: ['Flutter', 'Dart', 'React', 'Node.js', 'SQL', 'REST APIs'],
      languages: ['English', 'Spanish'],
      references: ['Jane Smith â€¢ Former Manager', 'Alex Lee â€¢ Team Lead'],
      website: 'johnportfolio.com',
      linkedin: 'linkedin.com/in/johndoe',
      experience: [
        ExperienceItem(
          title: 'Senior Developer',
          company: 'Tech Company ABC',
          duration: 'Jan 2021 - Present',
          description:
              'Led development of key features and mentored junior developers.',
        ),
        ExperienceItem(
          title: 'Software Engineer',
          company: 'Tech Company XYZ',
          duration: 'Jun 2019 - Dec 2020',
          description:
              'Developed and maintained mobile applications using Flutter.',
        ),
      ],
      education: [
        EducationItem(
          degree: 'Bachelor of Science in Computer Science',
          school: 'University of Technology',
          year: '2019',
        ),
      ],
    );
  }
}
