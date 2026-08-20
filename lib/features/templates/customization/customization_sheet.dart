import 'package:flutter/material.dart';
import 'package:cv_ganerator/config/theme.dart';
import 'package:cv_ganerator/features/templates/models/resume_template.dart';
import 'package:cv_ganerator/models/resume_data.dart';

Future<TemplateCustomization?> showCustomizationSheet({
  required BuildContext context,
  required ResumeTemplate template,
  required ResumeData data,
  required TemplateCustomization customization,
}) {
  return showModalBottomSheet<TemplateCustomization>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _CustomizationSheet(
      template: template,
      data: data,
      initial: customization,
    ),
  );
}

class _CustomizationSheet extends StatefulWidget {
  final ResumeTemplate template;
  final ResumeData data;
  final TemplateCustomization initial;

  const _CustomizationSheet({
    required this.template,
    required this.data,
    required this.initial,
  });

  @override
  State<_CustomizationSheet> createState() => _CustomizationSheetState();
}

class _CustomizationSheetState extends State<_CustomizationSheet>
    with SingleTickerProviderStateMixin {
  late TemplateCustomization _custom;
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _custom = widget.initial;
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.86;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Customize CV',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, _custom),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabs,
            labelColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Color'),
              Tab(text: 'Type'),
              Tab(text: 'Layout'),
              Tab(text: 'Sections'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _colors(),
                _type(),
                _layout(),
                _sections(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colors() {
    final entries = TemplateCustomization.presetColors.entries.toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Accent color', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final entry in entries)
              _colorDot(entry.key, entry.value),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'The selected color updates headers, rules, icons, and sidebar accents without changing your resume content.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _colorDot(String label, Color color) {
    final selected = _custom.accentColor == color;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: () => setState(() => _custom = _custom.copyWith(accentColor: color)),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 92,
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppTheme.primaryColor : Colors.black12,
                    width: selected ? 3 : 1,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _type() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Font', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TemplateCustomization.fontOptions.map((font) {
            final selected = (_custom.fontFamily ?? widget.template.typography.bodyFont) == font;
            return ChoiceChip(
              label: Text(font),
              selected: selected,
              onSelected: (_) => setState(() => _custom = _custom.copyWith(fontFamily: font)),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _slider('Name size', _custom.nameSize ?? widget.template.typography.nameSize, 18, 36, (v) {
          setState(() => _custom = _custom.copyWith(nameSize: v));
        }),
        _slider('Heading size', _custom.headingSize ?? widget.template.typography.headingSize, 9, 16, (v) {
          setState(() => _custom = _custom.copyWith(headingSize: v));
        }),
        _slider('Body size', _custom.bodySize ?? widget.template.typography.bodySize, 8, 14, (v) {
          setState(() => _custom = _custom.copyWith(bodySize: v));
        }),
        _slider('Line height', _custom.lineHeight ?? widget.template.typography.lineHeight, 1.1, 1.7, (v) {
          setState(() => _custom = _custom.copyWith(lineHeight: v));
        }),
        _slider('Letter spacing', _custom.letterSpacing ?? widget.template.typography.letterSpacing, 0, 2, (v) {
          setState(() => _custom = _custom.copyWith(letterSpacing: v));
        }),
      ],
    );
  }

  Widget _layout() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Page size', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        SegmentedButton<PageSizeOption>(
          segments: const [
            ButtonSegment(value: PageSizeOption.a4, label: Text('A4')),
            ButtonSegment(value: PageSizeOption.usLetter, label: Text('US Letter')),
          ],
          selected: {_custom.pageSize},
          onSelectionChanged: (value) {
            setState(() => _custom = _custom.copyWith(pageSize: value.first));
          },
        ),
        const SizedBox(height: 20),
        const Text('Photo', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Template default'),
              selected: _custom.photoMode == PhotoMode.auto,
              onSelected: (_) => setState(() => _custom = _custom.copyWith(photoMode: PhotoMode.auto)),
            ),
            ChoiceChip(
              label: const Text('Show photo'),
              selected: _custom.photoMode == PhotoMode.show,
              onSelected: (_) => setState(() => _custom = _custom.copyWith(photoMode: PhotoMode.show)),
            ),
            ChoiceChip(
              label: const Text('Hide photo'),
              selected: _custom.photoMode == PhotoMode.hide,
              onSelected: (_) => setState(() => _custom = _custom.copyWith(photoMode: PhotoMode.hide)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _slider('Page margin', _custom.pageMargin ?? widget.template.spacing.pageMargin, 16, 48, (v) {
          setState(() => _custom = _custom.copyWith(pageMargin: v));
        }),
        _slider('Section spacing', _custom.sectionSpacing ?? widget.template.spacing.sectionSpacing, 8, 28, (v) {
          setState(() => _custom = _custom.copyWith(sectionSpacing: v));
        }),
        _slider('Column spacing', _custom.columnSpacing ?? widget.template.spacing.columnSpacing, 8, 32, (v) {
          setState(() => _custom = _custom.copyWith(columnSpacing: v));
        }),
        _slider('Header spacing', _custom.headerSpacing ?? widget.template.spacing.headerSpacing, 8, 28, (v) {
          setState(() => _custom = _custom.copyWith(headerSpacing: v));
        }),
      ],
    );
  }

  Widget _sections() {
    final ids = [
      ...(_custom.sectionOrder.isNotEmpty ? _custom.sectionOrder : widget.data.sectionOrder),
      ...widget.template.defaultSectionOrder,
      ...widget.data.customSections.map((item) => item.id),
    ];
    final seen = <String>{};
    final order = <String>[];
    for (final id in ids) {
      if (seen.add(id)) order.add(id);
    }
    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: order.length,
            onReorderItem: (oldIndex, newIndex) {
              setState(() {
                final item = order.removeAt(oldIndex);
                order.insert(newIndex, item);
                _custom = _custom.copyWith(sectionOrder: List<String>.from(order));
              });
            },
            itemBuilder: (context, index) {
              final id = order[index];
              final visible = _custom.sectionVisibility[id] ??
                  widget.data.sectionVisibility[id] ??
                  widget.data.sectionHasContent(id);
              final title = _custom.sectionTitles[id] ??
                  widget.data.titleForSection(id);
              return ListTile(
                key: ValueKey(id),
                leading: Icon(Icons.drag_handle, color: Colors.grey.shade500),
                title: Text(title),
                trailing: Switch(
                  value: visible,
                  onChanged: (value) {
                    setState(() {
                      final vis = Map<String, bool>.from(_custom.sectionVisibility);
                      vis[id] = value;
                      _custom = _custom.copyWith(sectionVisibility: vis);
                    });
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: OutlinedButton.icon(
            onPressed: _addCustom,
            icon: const Icon(Icons.add),
            label: const Text('Add custom section'),
          ),
        ),
      ],
    );
  }

  Future<void> _addCustom() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom section'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Section title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      final order = [
        ...(_custom.sectionOrder.isNotEmpty
            ? _custom.sectionOrder
            : widget.template.defaultSectionOrder),
        id,
      ];
      final titles = Map<String, String>.from(_custom.sectionTitles)..[id] = name;
      final vis = Map<String, bool>.from(_custom.sectionVisibility)..[id] = true;
      _custom = _custom.copyWith(
        sectionOrder: order,
        sectionTitles: titles,
        sectionVisibility: vis,
      );
    });
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            Text(value.toStringAsFixed(1)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
