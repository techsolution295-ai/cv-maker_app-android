import 'package:cv_ganerator/features/templates/models/resume_template.dart';
import 'package:cv_ganerator/features/templates/registry/template_catalog.dart';

class TemplateRegistry {
  TemplateRegistry._();

  static final List<ResumeTemplate> allTemplates =
      List<ResumeTemplate>.unmodifiable(TemplateCatalog.all);

  static final Map<String, ResumeTemplate> _byId = {
    for (final template in allTemplates) template.id: template,
  };

  static ResumeTemplate getById(String id) {
    return _byId[id] ?? allTemplates.first;
  }

  static ResumeTemplate? tryGetById(String id) => _byId[id];

  static List<ResumeTemplate> getByCategory(TemplateCategory category) {
    return allTemplates.where((item) => item.category == category).toList();
  }

  static List<ResumeTemplate> get featuredTemplates =>
      allTemplates.where((item) => item.featured).toList();

  static List<ResumeTemplate> get popularTemplates =>
      allTemplates.where((item) => item.popular).toList();

  static List<ResumeTemplate> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return allTemplates;
    return allTemplates.where((item) {
      final haystack = [
        item.name,
        item.categoryLabel,
        item.description,
        item.category.name,
        ...item.tags,
        ...item.bestFor,
        ...item.features,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  static List<ResumeTemplate> filter({
    String query = '',
    TemplateCategory? category,
    bool favoritesOnly = false,
    Set<String> favoriteIds = const {},
  }) {
    Iterable<ResumeTemplate> items = search(query);
    if (category != null) {
      items = items.where((item) => item.category == category);
    }
    if (favoritesOnly) {
      items = items.where((item) => favoriteIds.contains(item.id));
    }
    return items.toList();
  }
}
