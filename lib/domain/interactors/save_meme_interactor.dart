import 'dart:io';

import 'package:memogenerator/domain/interactors/screenshot_interactor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../data/repositories/memes_repository.dart';
import '../../data/models/meme.dart';
import '../../data/models/text_with_position.dart';
import 'package:collection/collection.dart';

class SaveMemeInteractor {
  static SaveMemeInteractor? _instance;

  factory SaveMemeInteractor.getInstance() =>
      _instance ??= SaveMemeInteractor._internal();

  SaveMemeInteractor._internal();

  static const memesPathName = "memes";

  Future<Meme> saveMeme({
    required final String id,
    required final List<TextWithPosition> textWithPositions,
    required final ScreenshotController screenshotController,
    String? imagePath,
  }) async {
    if (imagePath == null) {
      final meme = Meme(
        id: id,
        texts: textWithPositions,
      );

      await MemesRepository.getInstance().addToMemes(meme);
      return meme;
    }
    await ScreenshotInteractor.getInstance().saveThumbnail(id, screenshotController);
    await createNewFile(imagePath);

    final meme = Meme(
      id: id,
      texts: textWithPositions,
      memePath: imagePath,
    );

    await MemesRepository.getInstance().addToMemes(meme);
    return meme;
  }

  Future<void> createNewFile(final String imagePath) async {
    final docsPath = await getApplicationDocumentsDirectory();
    final memePath =
        "${docsPath.absolute.path}${Platform.pathSeparator}$memesPathName";
    final memesDirectory = await Directory(memePath).create(recursive: true);
    final imageName = _getFileNameByPath(imagePath);
    final newImagePath = "$memePath${Platform.pathSeparator}$imageName";
    print("newImagePath - $newImagePath");
    final currentFiles = memesDirectory.listSync();

    final oldFileWithTheSameName = currentFiles.firstWhereOrNull((element) {
      return _getFileNameByPath(element.path) == imageName && element is File;
    });

    final tempFile = File(imagePath);
    if (oldFileWithTheSameName == null) {
      await tempFile.copy(newImagePath);
      return;
    }
    final oldFileLength = await (oldFileWithTheSameName as File).length();
    final newFileLength = await tempFile.length();
    print("Размер старого файла - $oldFileLength");
    print("Размер нового файла - $newFileLength");

    if (oldFileLength == newFileLength) {
      return;
    }
    return _createFileForSameNameButDifferentLength(
      imageName: imageName,
      tempFile: tempFile,
      newImagePath: newImagePath,
      memePath: memePath,
    );
  }

  Future<void> _createFileForSameNameButDifferentLength({
    required final String imageName,
    required final File tempFile,
    required final String newImagePath,
    required final String memePath,
  }) async {
    final indexOfLastDot = imageName.lastIndexOf(".");
    if (indexOfLastDot == -1) {
      await tempFile.copy(newImagePath);
      return;
    }
    final extension = imageName.substring(indexOfLastDot);
    final imageNameWithoutExtension = imageName.substring(0, indexOfLastDot);
    final indexOfLastUnderscore = imageNameWithoutExtension.lastIndexOf("_");
    if (indexOfLastUnderscore == -1) {
      final correctedNewImagePath =
          "$memePath${Platform.pathSeparator}${imageNameWithoutExtension}_1$extension";
      await tempFile.copy(correctedNewImagePath);
      return;
    }
    final suffixNumberString =
        imageNameWithoutExtension.substring(indexOfLastUnderscore + 1);
    final suffixNumber = int.tryParse(suffixNumberString);
    if (suffixNumber == null) {
      final correctedNewImagePath =
          "$memePath${Platform.pathSeparator}${imageNameWithoutExtension}$extension";
      await tempFile.copy(correctedNewImagePath);
    } else {
      final imageNameWithoutSuffix =
          imageNameWithoutExtension.substring(0, indexOfLastUnderscore);
      final correctedNewImagePath =
          "$memePath${Platform.pathSeparator}${imageNameWithoutSuffix}_${suffixNumber + 1}$extension";
      await tempFile.copy(correctedNewImagePath);
    }
  }

  String _getFileNameByPath(String imagePath) =>
      imagePath.split(Platform.pathSeparator).last;
}
