import 'package:memo_care/features/templates/domain/models/template_pack.dart';
import 'package:memo_care/features/templates/domain/models/template_packs.dart';

/// In-memory template repository.
///
/// Templates are compile-time constants — no database, no
/// network. This class exists for API consistency with other
/// features.
class TemplateRepository {
  /// Creates a const [TemplateRepository].
  const TemplateRepository();

  /// Returns all available template packs.
  List<TemplatePack> getAll() => kTemplatePacks;

  /// Returns the pack with the given [id], or `null`.
  TemplatePack? getById(String id) {
    for (final pack in kTemplatePacks) {
      if (pack.id == id) return pack;
    }
    return null;
  }

  /// Returns packs matching the given [condition].
  List<TemplatePack> getByCondition(String condition) {
    return kTemplatePacks
        .where((p) => p.condition == condition)
        .toList();
  }
}
