import 'package:flutter/material.dart';
import 'package:cv_ganerator/constants/dimensions.dart';
import 'package:cv_ganerator/constants/strings.dart';
import 'package:cv_ganerator/models/cover_letter_model.dart';
import 'package:cv_ganerator/services/local_storage_service.dart';
import 'package:cv_ganerator/services/resume_ai_assistant_service.dart';
import 'package:cv_ganerator/widgets/common_widgets.dart';
import 'package:cv_ganerator/widgets/app_widgets.dart';

class CoverLetterScreen extends StatefulWidget {
  const CoverLetterScreen({super.key});

  @override
  State<CoverLetterScreen> createState() => _CoverLetterScreenState();
}

class _CoverLetterScreenState extends State<CoverLetterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _companyController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _experienceController = TextEditingController();
  bool _isGenerating = false;
  String? _generatedLetter;
  final ResumeAiAssistantService _aiAssistant = ResumeAiAssistantService();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: AppStrings.coverLetterGenerator),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_generatedLetter == null) ...[
              SectionHeader(title: AppStrings.coverLetterGenerator),
              const SizedBox(height: AppDimensions.paddingMedium),
              CustomTextField(
                label: AppStrings.fullName,
                hint: 'John Doe',
                controller: _fullNameController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              CustomTextField(
                label: AppStrings.email,
                hint: 'you@email.com',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              CustomTextField(
                label: AppStrings.phone,
                hint: '+1 555 123 4567',
                controller: _phoneController,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              CustomTextField(
                label: AppStrings.location,
                hint: 'Lahore, Pakistan',
                controller: _locationController,
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              CustomTextField(
                label: AppStrings.companyName,
                hint: 'Enter company name',
                controller: _companyController,
                prefixIcon: Icons.business,
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              CustomTextField(
                label: AppStrings.jobTitle,
                hint: 'Enter job title',
                controller: _jobTitleController,
                prefixIcon: Icons.work,
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              CustomTextField(
                label: 'Experience Summary',
                hint: 'Briefly describe your relevant experience.',
                controller: _experienceController,
                prefixIcon: Icons.notes_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              PrimaryButton(
                label: AppStrings.generateCoverLetter,
                onPressed: _generateLetter,
                isLoading: _isGenerating,
              ),
            ] else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Generated Cover Letter',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          setState(() => _generatedLetter = null);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  CustomCard(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    backgroundColor: Colors.white,
                    child: SelectableText(
                      _generatedLetter!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Copy',
                          onPressed: () {
                            // Copy to clipboard
                          },
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Download',
                          onPressed: () {
                            // Download as PDF
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateLetter() async {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _companyController.text.isEmpty ||
        _jobTitleController.text.isEmpty ||
        _experienceController.text.isEmpty) {
      AppSnackBar.error(context, 'Please fill all fields');
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final generated = await _aiAssistant.generateCoverLetter(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        company: _companyController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
        experience: _experienceController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _generatedLetter = generated;
      });
      _saveCoverLetter();
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _saveCoverLetter() {
    if (_generatedLetter == null) {
      return;
    }
    final now = DateTime.now();
    final letter = CoverLetter(
      id: now.millisecondsSinceEpoch.toString(),
      userId: '',
      resumeId: '',
      companyName: _companyController.text.trim(),
      jobTitle: _jobTitleController.text.trim(),
      content: _generatedLetter!,
      createdAt: now,
      updatedAt: now,
    );
    LocalStorageService.instance.saveCoverLetter(letter);
  }
}
