import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../data/repositories/memes_repository.dart';
import '../../data/models/meme.dart';
import '../../data/models/text_with_position.dart';

class SaveMemeInteractor {
  static SaveMemeInteractor? _instance;

  factory SaveMemeInteractor.getInstance() =>
      _instance ??= SaveMemeInteractor._internal();

  SaveMemeInteractor._internal();

  Future<bool> saveMeme({
    required final String id,
    required final List<TextWithPosition> textWithPositions,
    String? imagePath,
  }) async {
    if (imagePath == null) {
      final meme = Meme(
        id: id,
        texts: textWithPositions,
      );

      return MemesRepository.getInstance().addToMemes(meme);
    }
    final docsPath = await getApplicationDocumentsDirectory();
    final memePath = "${docsPath.absolute.path}${Platform.pathSeparator}memes";
    final directory = await Directory(memePath).create(recursive: true);
    final imageName = imagePath.split(Platform.pathSeparator).last;
    final newImagePath = "$memePath${Platform.pathSeparator}$imageName";
    print("newImagePath - $newImagePath");
    final tempFile = File(imagePath);
    final directoryFiles = directory.listSync();
    File? oldFile;
    for (final file in directoryFiles) {
      final fileName = file.absolute.path.split(Platform.pathSeparator).last;
      if (fileName == imageName) {
        oldFile = file as File;
        print("Нашел старый объект");
        break;
      }
    }

    if (oldFile != null) {
      final oldFileLength = await oldFile.length();
      final newFileLength = await tempFile.length();
      print("Размер старого файла - $oldFileLength");
      print("Размер нового файла - $newFileLength");

      if (oldFileLength != newFileLength) {
        print("Старый и новый файл имеют одинаковый размер, не сохраняем");
      } else {
        final fileNameWithType =
            oldFile.absolute.path.split(Platform.pathSeparator).last;
        final fileName = fileNameWithType.split(".").first;
        final fileType = fileNameWithType.split(".").last;
        var fileClearName = fileName.split("_").first;
        var fileVersion = int.tryParse(fileName.split("_").last);
        if (fileVersion == null) {
          fileVersion = 0;
        }
        fileVersion += 1;

        final newImagePathWithIndex =
            "$memePath${Platform.pathSeparator}${fileClearName}_$fileVersion.$fileType";

        print("fileNameWithType - $fileNameWithType");
        print("newImagePathWithIndex - $newImagePathWithIndex");
        print("Сохраняем новый файл с новым индексом");
        await tempFile.copy(newImagePathWithIndex);
      }
    } else {
      print("Сохраняем новый объект");
      await tempFile.copy(newImagePath);
    }

    final meme = Meme(
      id: id,
      texts: textWithPositions,
      memePath: newImagePath,
    );

    return MemesRepository.getInstance().addToMemes(meme);
  }
}
