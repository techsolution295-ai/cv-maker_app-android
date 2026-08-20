import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cv_ganerator/features/templates/models/resume_template.dart';
import 'package:cv_ganerator/features/templates/renderers/template_renderer.dart';
import 'package:cv_ganerator/features/templates/sample/sample_resume_data.dart';
import 'package:cv_ganerator/models/resume_data.dart';

class ThumbnailScrollScope extends InheritedWidget {
  final bool isScrolling;

  const ThumbnailScrollScope({
    super.key,
    required this.isScrolling,
    required super.child,
  });

  static bool of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ThumbnailScrollScope>()
            ?.isScrolling ??
        false;
  }

  @override
  bool updateShouldNotify(ThumbnailScrollScope oldWidget) {
    return oldWidget.isScrolling != isScrolling;
  }
}

class TemplateThumbnailCache {
  static final Map<String, ui.Image> _images = {};

  static ui.Image? get(String id) => _images[id];

  static void put(String id, ui.Image image) {
    final previous = _images[id];
    _images[id] = image;
    previous?.dispose();
  }
}

class TemplateThumbnail extends StatefulWidget {
  final ResumeTemplate template;
  final ResumeData? resumeData;
  final TemplateCustomization? customization;

  static const Size layoutSize = Size(240, 340);

  const TemplateThumbnail({
    super.key,
    required this.template,
    this.resumeData,
    this.customization,
  });

  @override
  State<TemplateThumbnail> createState() => _TemplateThumbnailState();
}

class _TemplateThumbnailState extends State<TemplateThumbnail> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _capturing = false;

  String get _cacheKey => widget.template.id;

  Future<void> _capture() async {
    if (_capturing || TemplateThumbnailCache.get(_cacheKey) != null) return;
    final boundary =
        _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null || !boundary.hasSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _capture();
      });
      return;
    }
    _capturing = true;
    try {
      final image = await boundary.toImage(pixelRatio: 1.5);
      if (!mounted) {
        image.dispose();
        return;
      }
      TemplateThumbnailCache.put(_cacheKey, image);
      if (mounted) setState(() {});
    } catch (_) {
      _capturing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cached = TemplateThumbnailCache.get(_cacheKey);
    if (cached != null) {
      return RawImage(
        image: cached,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.low,
      );
    }

    final scrolling = ThumbnailScrollScope.of(context);
    if (scrolling) {
      return _TemplateSkeleton(template: widget.template);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
        return;
      }
      _capture();
    });

    return RepaintBoundary(
      key: _boundaryKey,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: TemplateThumbnail.layoutSize.width,
          height: TemplateThumbnail.layoutSize.height,
          child: IgnorePointer(
            child: TemplateRenderer(
              resumeData: SampleResumeData.gallerySample,
              templateId: widget.template.id,
              customization: widget.customization,
              thumbnail: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _TemplateSkeleton extends StatelessWidget {
  final ResumeTemplate template;

  const _TemplateSkeleton({required this.template});

  @override
  Widget build(BuildContext context) {
    final colors = template.colors;
    final sidebar = template.layoutType == TemplateLayoutType.modernSidebar ||
        template.layoutType == TemplateLayoutType.rightSidebar;
    if (sidebar) {
      final left = template.layoutType == TemplateLayoutType.modernSidebar;
      final rail = ColoredBox(color: colors.sidebar);
      final page = ColoredBox(color: Colors.white, child: _lines(colors));
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: left
            ? [
                Expanded(flex: 34, child: rail),
                Expanded(flex: 66, child: page),
              ]
            : [
                Expanded(flex: 66, child: page),
                Expanded(flex: 34, child: rail),
              ],
      );
    }
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: colors.primary.withValues(alpha: 0.92),
            child: const SizedBox(height: 36),
          ),
          Expanded(child: _lines(colors)),
        ],
      ),
    );
  }

  Widget _lines(TemplateColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(0.55, colors.text.withValues(alpha: 0.22)),
          const SizedBox(height: 6),
          _bar(0.35, colors.primary.withValues(alpha: 0.18)),
          const SizedBox(height: 12),
          _bar(0.92, colors.rule),
          const SizedBox(height: 8),
          _bar(0.88, colors.rule),
          const SizedBox(height: 8),
          _bar(0.7, colors.rule),
        ],
      ),
    );
  }

  Widget _bar(double widthFactor, Color color) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: ColoredBox(
        color: color,
        child: const SizedBox(height: 6),
      ),
    );
  }
}
