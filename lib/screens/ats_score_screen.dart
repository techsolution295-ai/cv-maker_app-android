import 'package:flutter/material.dart';
import 'package:cv_ganerator/config/theme.dart';
import 'package:cv_ganerator/constants/dimensions.dart';
import 'package:cv_ganerator/constants/strings.dart';
import 'package:cv_ganerator/models/saved_resume.dart';
import 'package:cv_ganerator/services/local_storage_service.dart';
import 'package:cv_ganerator/services/resume_ai_assistant_service.dart';
import 'package:cv_ganerator/widgets/common_widgets.dart';
import 'package:cv_ganerator/widgets/app_widgets.dart';

class ATSScoreScreen extends StatefulWidget {
  final bool showAppBar;

  const ATSScoreScreen({super.key, this.showAppBar = true});

  @override
  State<ATSScoreScreen> createState() => _ATSScoreScreenState();
}

class _ATSScoreScreenState extends State<ATSScoreScreen> {
  bool _isAnalyzing = false;
  bool _isGeneratingAiTips = false;
  int? _atsScore;
  List<String> _aiTips = [];
  List<SavedResume> _resumes = [];
  String? _selectedResumeId;
  final ResumeAiAssistantService _aiAssistant = ResumeAiAssistantService();

  @override
  void initState() {
    super.initState();
    _loadResumes();
  }

  void _loadResumes() {
    final storage = LocalStorageService.instance;
    final resumes = storage.getSavedResumes();
    setState(() {
      _resumes = resumes;
      _selectedResumeId = resumes.isNotEmpty ? resumes.first.id : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_atsScore == null)
            Column(
              children: [
                Icon(
                  Icons.assessment,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                Text(
                  AppStrings.analyzeResume,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                Text(
                  'Get a detailed analysis of your resume\'s compatibility with Applicant Tracking Systems (ATS)',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                if (_resumes.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _selectedResumeId,
                    decoration: const InputDecoration(
                      labelText: 'Select Resume',
                      border: OutlineInputBorder(),
                    ),
                    items: _resumes
                        .map(
                          (resume) => DropdownMenuItem(
                            value: resume.id,
                            child: Text(resume.title),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedResumeId = value);
                    },
                  )
                else
                  CustomCard(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Text(
                      'Create a resume first to analyze ATS score.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: AppDimensions.paddingXLarge),
                PrimaryButton(
                  label: AppStrings.analyzeResume,
                  onPressed: _resumes.isEmpty ? null : _analyzeResume,
                  isLoading: _isAnalyzing,
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCard(
                  backgroundColor: _getScoreColor().withOpacity(0.1),
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.atsCompatibility,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: _atsScore! / 100,
                              strokeWidth: 8,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getScoreColor(),
                              ),
                              backgroundColor: Colors.grey[300],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '$_atsScore%',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      color: _getScoreColor(),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                _getScoreLabel(),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                SectionHeader(title: AppStrings.improvementTips),
                const SizedBox(height: AppDimensions.paddingMedium),
                SecondaryButton(
                  label: _isGeneratingAiTips
                      ? 'AI is generating tips...'
                      : 'Generate AI Tips',
                  onPressed: _isGeneratingAiTips ? null : _generateAiTips,
                  icon: Icons.auto_awesome,
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                if (_aiTips.isNotEmpty)
                  ..._aiTips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingMedium),
                      child: _buildTipCard(
                        'AI Suggestion',
                        tip,
                        Icons.auto_awesome,
                      ),
                    ),
                  ),
                _buildTipCard(
                  'Add more keywords',
                  'Include industry-specific keywords to improve ATS compatibility',
                  Icons.search,
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                _buildTipCard(
                  'Use standard formatting',
                  'Avoid complex formatting that ATS systems cannot read',
                  Icons.format_align_left,
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                _buildTipCard(
                  'Expand your skills section',
                  'Add more technical skills relevant to the job description',
                  Icons.psychology,
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                _buildTipCard(
                  'Add quantifiable achievements',
                  'Use numbers and metrics to highlight your accomplishments',
                  Icons.trending_up,
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                PrimaryButton(
                  label: 'Analyze Again',
                  onPressed: () {
                    setState(() {
                      _atsScore = null;
                      _aiTips = [];
                    });
                  },
                ),
              ],
            ),
        ],
      ),
    );

    if (!widget.showAppBar) {
      return body;
    }

    return Scaffold(
      appBar: AppAppBar(title: AppStrings.atsScore),
      body: body,
    );
  }

  Widget _buildTipCard(String title, String description, IconData icon) {
    return CustomCard(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusSmall,
              ),
            ),
            child: Icon(icon, color: AppTheme.secondaryColor),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _analyzeResume() {
    setState(() => _isAnalyzing = true);
    Future.delayed(const Duration(seconds: 3), () {
      final resume = _resumes.firstWhere(
        (item) => item.id == _selectedResumeId,
        orElse: () => _resumes.first,
      );
      final score = _calculateScore(resume);
      setState(() {
        _isAnalyzing = false;
        _atsScore = score;
        _aiTips = [];
      });
    });
  }

  Future<void> _generateAiTips() async {
    if (_selectedResumeId == null) {
      return;
    }
    final resume = _resumes.firstWhere(
      (item) => item.id == _selectedResumeId,
      orElse: () => _resumes.first,
    );
    setState(() => _isGeneratingAiTips = true);
    try {
      final tips = await _aiAssistant.generateAtsTips(
        jobTitle: resume.data.jobTitle,
        skills: resume.data.skills,
        summary: resume.data.summary,
      );
      if (!mounted) return;
      setState(() => _aiTips = tips);
    } finally {
      if (mounted) {
        setState(() => _isGeneratingAiTips = false);
      }
    }
  }

  int _calculateScore(SavedResume resume) {
    final data = resume.data;
    var score = 0;
    if (data.fullName.trim().isNotEmpty) score += 10;
    if (data.jobTitle.trim().isNotEmpty) score += 10;
    if (data.email.trim().isNotEmpty) score += 10;
    if (data.phone.trim().isNotEmpty) score += 5;
    if (data.location.trim().isNotEmpty) score += 5;
    if (data.summary.trim().isNotEmpty) score += 15;
    if (data.skills.length >= 3) {
      score += 15;
    } else if (data.skills.isNotEmpty) {
      score += 8;
    }
    if (data.experience.isNotEmpty) score += 15;
    if (data.education.isNotEmpty) score += 10;
    if (data.skills.length >= 5) score += 5;
    if (score > 100) {
      score = 100;
    }
    return score;
  }

  Color _getScoreColor() {
    if (_atsScore == null) return AppTheme.primaryColor;
    if (_atsScore! >= 80) return AppTheme.successColor;
    if (_atsScore! >= 60) return AppTheme.accentColor;
    return AppTheme.errorColor;
  }

  String _getScoreLabel() {
    if (_atsScore == null) return 'Unknown';
    if (_atsScore! >= 80) return 'Excellent';
    if (_atsScore! >= 60) return 'Good';
    return 'Needs Improvement';
  }
}
