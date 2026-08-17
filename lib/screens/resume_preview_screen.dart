import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cv_ganerator/constants/dimensions.dart';
import 'package:cv_ganerator/constants/strings.dart';
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

  const ResumePreviewScreen({
    required this.resumeTitle,
    this.resumeData,
    this.allowEditing = false,
    this.initialTemplate = ResumeTemplateKind.travis,
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
  ResumeTemplateKind _templateKind = ResumeTemplateKind.travis;

  @override
  void initState() {
    super.initState();
    _data = widget.resumeData ?? _sampleData();
    _templateKind = widget.initialTemplate;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: AppStrings.resumeTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePDF,
            tooltip: AppStrings.share,
          ),
          if (widget.allowEditing) // Only show edit button if allowed
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                children: [
                  CustomCard(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: _buildResumePreview(),
                  ),
                ],
              ),
            ),
          ),
          if (!_isEditing)
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
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
        ],
      ),
    );
  }

  Widget _buildResumePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isEditing) ...[
          _buildEditPanel(),
          const SizedBox(height: AppDimensions.paddingLarge),
        ],
        ResumeTemplateSwitcher(
          data: _data,
          kind: _templateKind,
        ),
        if (_isEditing) ...[
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildExperienceEditors(),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildEducationEditors(),
        ],
      ],
    );
  }

  Future<void> _printPDF() async {
    if (_isPrinting) return;
    setState(() => _isPrinting = true);
    try {
      await AdService.instance.showInterstitialThen(() async {
        final pdfData = await _pdfService.buildPdf(
          data: _data,
          title: widget.resumeTitle,
        );
        await Printing.layoutPdf(onLayout: (format) async => pdfData);
        if (mounted) {
          AppSnackBar.info(context, 'Print dialog opened');
        }
      });
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
    switch (_templateKind) {
      case ResumeTemplateKind.travis:
      case ResumeTemplateKind.alice:
        return false;
      default:
        return true;
    }
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
              setState(() => _experience[i] = updated);
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
              setState(() => _education[i] = updated);
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
