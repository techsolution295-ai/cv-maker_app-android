import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cv_ganerator/features/templates/models/resume_template.dart';
import 'package:cv_ganerator/features/templates/registry/template_registry.dart';
import 'package:cv_ganerator/features/templates/renderers/template_renderer.dart';
import 'package:cv_ganerator/features/templates/style/resolved_theme.dart';
import 'package:cv_ganerator/models/resume_data.dart';

class ResumePagePreview extends StatelessWidget {
  final ResumeData resumeData;
  final String templateId;
  final TemplateCustomization? customization;
  final bool thumbnail;

  const ResumePagePreview({
    super.key,
    required this.resumeData,
    required this.templateId,
    this.customization,
    this.thumbnail = false,
  });

  @override
  Widget build(BuildContext context) {
    return PagedResumeView(
      resumeData: resumeData,
      templateId: templateId,
      customization: customization,
      thumbnail: thumbnail,
      maxPages: 1,
      framed: !thumbnail,
    );
  }
}

class PagedResumeView extends StatefulWidget {
  final ResumeData resumeData;
  final String templateId;
  final TemplateCustomization? customization;
  final bool thumbnail;
  final int? maxPages;
  final bool framed;
  final bool scrollable;
  final EdgeInsetsGeometry padding;

  const PagedResumeView({
    super.key,
    required this.resumeData,
    required this.templateId,
    this.customization,
    this.thumbnail = false,
    this.maxPages = 1,
    this.framed = true,
    this.scrollable = false,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<PagedResumeView> createState() => _PagedResumeViewState();
}

class _PagedResumeViewState extends State<PagedResumeView> {
  final GlobalKey _measureKey = GlobalKey();
  double _contentHeight = 0;

  Size _pageSize() {
    final theme = ResolvedTemplateTheme.resolve(
      definition: TemplateRegistry.getById(widget.templateId),
      data: widget.resumeData,
      customization: widget.customization,
      thumbnail: widget.thumbnail,
    );
    return theme.pageSizePx;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant PagedResumeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.templateId != widget.templateId ||
        oldWidget.resumeData != widget.resumeData ||
        oldWidget.customization != widget.customization) {
      _contentHeight = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
  }

  void _measure() {
    if (widget.maxPages == 1) return;
    final box = _measureKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _measure();
      });
      return;
    }
    final height = box.size.height;
    if (height > 0 && (height - _contentHeight).abs() > 2 && mounted) {
      setState(() => _contentHeight = height);
    }
  }

  Widget _document({Key? key, required double width}) {
    return KeyedSubtree(
      key: key,
      child: SizedBox(
        width: width,
        child: TemplateRenderer(
          resumeData: widget.resumeData,
          templateId: widget.templateId,
          customization: widget.customization,
          thumbnail: widget.thumbnail,
        ),
      ),
    );
  }

  int _pageCount(Size page) {
    if (widget.maxPages == 1) return 1;
    if (_contentHeight <= 0) return 1;
    if (_contentHeight <= page.height + 2) return 1;
    return (_contentHeight / page.height).ceil().clamp(1, widget.maxPages ?? 6);
  }

  @override
  Widget build(BuildContext context) {
    final page = _pageSize();
    final pages = _pageCount(page);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final width = maxWidth.isFinite && maxWidth > 0
            ? math.min(maxWidth, 520.0)
            : math.min(page.width, 520.0);
        final height = width * page.height / page.width;

        Widget sheet(int index) {
          return _ResumeSheet(
            width: width,
            height: height,
            framed: widget.framed,
            child: FittedBox(
              fit: BoxFit.fill,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: page.width,
                height: page.height,
                child: _document(width: page.width),
              ),
            ),
          );
        }

        final measure = widget.maxPages == 1
            ? const SizedBox.shrink()
            : Offstage(
                child: SizedBox(
                  width: page.width,
                  child: _document(key: _measureKey, width: page.width),
                ),
              );

        final stack = <Widget>[
          for (var index = 0; index < pages; index++) ...[
            if (index > 0) const SizedBox(height: 20),
            sheet(index),
          ],
        ];

        if (widget.scrollable) {
          final padding = widget.padding.resolve(TextDirection.ltr);
          final minHeight = constraints.maxHeight.isFinite
              ? math.max(0.0, constraints.maxHeight - padding.vertical)
              : 0.0;
          return Stack(
            children: [
              measure,
              SingleChildScrollView(
                padding: widget.padding,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: stack,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Stack(
          children: [
            measure,
            Padding(
              padding: widget.padding,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: stack,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ResumeSheet extends StatelessWidget {
  final double width;
  final double height;
  final bool framed;
  final Widget child;

  const _ResumeSheet({
    required this.width,
    required this.height,
    required this.framed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: framed
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: const Color(0x1A0F172A)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x330F172A),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            )
          : const BoxDecoration(color: Colors.white),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
