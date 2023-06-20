import 'dart:io';
import 'package:collection/collection.dart';

import 'package:path_provider/path_provider.dart';

class CopyUniqueFileInteractor {
  static CopyUniqueFileInteractor? _instance;

  factory CopyUniqueFileInteractor.getInstance() =>
      _instance ??= CopyUniqueFileInteractor._internal();

  CopyUniqueFileInteractor._internal();

  Future<String> copyUniqueFile({
    required final String directoryWithFiles,
    required final String filePath,
  }) async {
    final docsPath = await getApplicationDocumentsDirectory();
    final memePath =
        "${docsPath.absolute.path}${Platform.pathSeparator}$directoryWithFiles";
    final memesDirectory = await Directory(memePath).create(recursive: true);
    final imageName = _getFileNameByPath(filePath);
    final newImagePath = "$memePath${Platform.pathSeparator}$imageName";
    print("newImagePath - $newImagePath");
    final currentFiles = memesDirectory.listSync();

    final oldFileWithTheSameName = currentFiles.firstWhereOrNull((element) {
      return _getFileNameByPath(element.path) == imageName && element is File;
    });

    final tempFile = File(filePath);
    if (oldFileWithTheSameName == null) {
      //Файлов с таким названием нет, сохраняем файл в документы
      await tempFile.copy(newImagePath);
      return imageName;
    }
    final oldFileLength = await (oldFileWithTheSameName as File).length();
    final newFileLength = await tempFile.length();
    print("Размер старого файла - $oldFileLength");
    print("Размер нового файла - $newFileLength");

    if (oldFileLength == newFileLength) {
      // Такой файл уже существует, не сохраняем его заново
      return imageName;
    }

    final indexOfLastDot = imageName.lastIndexOf(".");
    if (indexOfLastDot == -1) {
      // У файла нет расширения сохраняем его
      await tempFile.copy(newImagePath);
      return imageName;
    }
    final extension = imageName.substring(indexOfLastDot);
    final imageNameWithoutExtension = imageName.substring(0, indexOfLastDot);
    final indexOfLastUnderscore = imageNameWithoutExtension.lastIndexOf("_");
    if (indexOfLastUnderscore == -1) {
      // Файл с таким названием есть, но с другим размером. Сохраняем с индексом 1
      final newImageName = "${imageNameWithoutExtension}_1$extension";
      final correctedNewImagePath =
          "$memePath${Platform.pathSeparator}$newImageName";
      await tempFile.copy(correctedNewImagePath);
      return newImageName;
    }
    final suffixNumberString =
    imageNameWithoutExtension.substring(indexOfLastUnderscore + 1);
    final suffixNumber = int.tryParse(suffixNumberString);
    if (suffixNumber == null) {
      // Файл с таким названием есть, но с другим размером. Сохраняем с индексом 1
      final newImageName = "${imageNameWithoutExtension}_1$extension";
      final correctedNewImagePath =
          "$memePath${Platform.pathSeparator}$newImageName";
      await tempFile.copy(correctedNewImagePath);
      return newImageName;
    }

    // Файл с таким названием есть, но с другим размером. Сохраняем с индексом +1
    final imageNameWithoutSuffix =
    imageNameWithoutExtension.substring(0, indexOfLastUnderscore);
    final newImageName = "${imageNameWithoutSuffix}_${suffixNumber + 1}$extension";
    final correctedNewImagePath =
        "$memePath${Platform.pathSeparator}$newImageName";
    await tempFile.copy(correctedNewImagePath);
    return newImageName;
  }

  String _getFileNameByPath(String imagePath) =>
      imagePath.split(Platform.pathSeparator).last;
}
