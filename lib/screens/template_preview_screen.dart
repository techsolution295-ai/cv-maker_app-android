import 'package:flutter/material.dart';
import 'package:cv_ganerator/features/templates/models/resume_template.dart';
import 'package:cv_ganerator/features/templates/previews/paged_resume_view.dart';
import 'package:cv_ganerator/features/templates/registry/template_registry.dart';
import 'package:cv_ganerator/features/templates/sample/sample_resume_data.dart';
import 'package:cv_ganerator/models/resume_data.dart';
import 'package:cv_ganerator/models/saved_resume.dart';
import 'package:cv_ganerator/screens/resume_preview_screen.dart';
import 'package:cv_ganerator/services/ad_service.dart';
import 'package:cv_ganerator/services/local_storage_service.dart';
import 'package:cv_ganerator/widgets/common_widgets.dart';
import 'package:cv_ganerator/widgets/favorite_heart_icon.dart';

class TemplatePreviewScreen extends StatefulWidget {
  final ResumeTemplate template;
  final ResumeData resumeData;
  final SavedResume? savedResume;

  const TemplatePreviewScreen({
    super.key,
    required this.template,
    required this.resumeData,
    this.savedResume,
  });

  @override
  State<TemplatePreviewScreen> createState() => _TemplatePreviewScreenState();
}

class _TemplatePreviewScreenState extends State<TemplatePreviewScreen> {
  late String _templateId;
  bool _favorite = false;

  ResumeTemplate get _template => TemplateRegistry.getById(_templateId);

  @override
  void initState() {
    super.initState();
    _templateId = widget.template.id;
    _favorite = LocalStorageService.instance.isFavoriteTemplate(_templateId);
  }

  ResumeData get _data => SampleResumeData.forPreview(widget.resumeData);

  Future<void> _toggleFavorite() async {
    final value =
        await LocalStorageService.instance.toggleFavoriteTemplate(_template.id);
    if (!mounted) return;
    setState(() => _favorite = value);
    AppSnackBar.success(
      context,
      value ? 'Template added to favorites' : 'Removed from favorites',
    );
  }

  @override
  Widget build(BuildContext context) {
    final template = _template;
    const desk = Color(0xFFE6EDF4);
    return Scaffold(
      backgroundColor: desk,
      appBar: AppBar(
        backgroundColor: desk,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          template.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          FavoriteHeartIcon(
            isFavorite: _favorite,
            onTap: _toggleFavorite,
            size: 22,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PagedResumeView(
              resumeData: _data,
              templateId: template.id,
              customization: widget.savedResume?.customization,
              scrollable: true,
              maxPages: 1,
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
            ),
          ),
          DecoratedBox(
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
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1F5AA6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    onPressed: _use,
                    child: const Text('Use This Template'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _use() async {
    await LocalStorageService.instance.addRecentTemplate(_templateId);
    if (!mounted) return;
    AdService.instance.showInterstitialThen(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResumePreviewScreen(
            resumeTitle: widget.savedResume?.title ?? _data.fullName,
            resumeData: _data,
            allowEditing: true,
            initialTemplateId: _templateId,
            customization: widget.savedResume?.customization,
          ),
        ),
      );
    });
  }
}
