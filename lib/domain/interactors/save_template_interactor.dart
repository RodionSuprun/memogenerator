import 'package:uuid/uuid.dart';

import '../../data/models/template.dart';
import '../../data/repositories/templates_repository.dart';
import 'copy_unique_file_interactor.dart';

class SaveTemplateInteractor {
  static const templatesPathName = "templates";

  static SaveTemplateInteractor? _instance;

  factory SaveTemplateInteractor.getInstance() =>
      _instance ??= SaveTemplateInteractor._internal();

  SaveTemplateInteractor._internal();

  Future<bool> saveTemplate({
    required final String imagePath,
  }) async {
    final newImagePath =
        await CopyUniqueFileInteractor.getInstance().copyUniqueFile(
      directoryWithFiles: templatesPathName,
      filePath: imagePath,
    );

    final template = Template(id: Uuid().v4(), imageUrl: newImagePath);

    return await TemplatesRepository.getInstance().addItem(template);
  }
}
