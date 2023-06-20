import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:memogenerator/data/models/template.dart';
import 'package:memogenerator/data/repositories/templates_repository.dart';
import 'package:memogenerator/domain/interactors/save_template_interactor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/repositories/memes_repository.dart';
import '../../data/models/meme.dart';
import 'models/meme_thumbnail.dart';
import 'models/template_full.dart';

class MainBloc {

  Stream<List<MemeThumbnail>> observeMemes() {
    return Rx.combineLatest2<List<Meme>, Directory, List<MemeThumbnail>>(
      MemesRepository.getInstance().observeItems(),
      getApplicationDocumentsDirectory().asStream(),
      (memes, docsDirectory) {
        return memes.map(
          (meme) {
            final fullImagePath =
                "${docsDirectory.absolute.path}${Platform.pathSeparator}${meme.id}.png";
            print(fullImagePath);
            return MemeThumbnail(
                memeId: meme.id, fullImageUrl: fullImagePath);
          },
        ).toList();
      },
    );
  }

  Stream<List<TemplateFull>> observeTemplates() {
    return Rx.combineLatest2<List<Template>, Directory, List<TemplateFull>>(
        TemplatesRepository.getInstance().observeItems(),
        getApplicationDocumentsDirectory().asStream(),
        (templates, docsDirectory) {
      return templates.map((template) {
        final fullImagePath =
            "${docsDirectory.absolute.path}${Platform.pathSeparator}${SaveTemplateInteractor.templatesPathName}${Platform.pathSeparator}${template.imageUrl}";
        return TemplateFull(id: template.id, fullImagePath: fullImagePath);
      }).toList();
    });
  }

  Future<String?> selectMeme() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    final imagePath = xFile?.path;
    if (imagePath != null) {
      await SaveTemplateInteractor.getInstance()
          .saveTemplate(imagePath: imagePath);
    }
    return xFile?.path;
  }

  Future<void> selectTemplate() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    final imagePath = xFile?.path;
    if (imagePath != null) {
      await SaveTemplateInteractor.getInstance()
          .saveTemplate(imagePath: imagePath);
    }
  }

  MainBloc() {}

  void deleteMeme(final String memeId) async {
    await MemesRepository.getInstance().removeFromItemsById(memeId);
  }

  void deleteTemplate(final String templateId) async {
    await TemplatesRepository.getInstance().removeFromItemsById(templateId);
  }

  void dispose() {}
}
