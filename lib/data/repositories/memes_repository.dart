import 'dart:convert';

import 'package:memogenerator/data/shared_preference_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

import '../models/meme.dart';

class MemesRepository {
  final SharedPreferenceData spData;

  final updater = PublishSubject<Null>();

  static MemesRepository? _instance;

  factory MemesRepository.getInstance() => _instance ??=
      MemesRepository._internal(SharedPreferenceData.getInstance());

  MemesRepository._internal(this.spData);

  Future<bool> addToMemes(final Meme newMeme) async {
    final memes = await getMemes();

    final elementIndex =
        memes.indexWhere((element) => element.id == newMeme.id);
    if (elementIndex == -1) {
      memes.add(newMeme);
    } else {
      memes.removeAt(elementIndex);
      memes.insert(elementIndex, newMeme);
      // memes[elementIndex] = newMeme;
    }
    return _setMemes(memes);
  }

  Future<bool> removeFromMemes(final String id) async {
    final memes = await getMemes();
    memes.removeWhere((meme) => meme.id == id);
    return _setMemes(memes);
  }

  Future<Meme?> getMeme(final String id) async {
    final memes = await getMemes();
    return memes.firstWhereOrNull((meme) {
      return meme.id == id;
    });
  }

  Stream<List<Meme>> observeMemes() async* {
    yield await getMemes();
    await for (final _ in updater) {
      yield await getMemes();
    }
  }

  Future<List<Meme>> getMemes() async {
    final rawMemes = await spData.getMemes();
    return rawMemes
        .map((rawMeme) => Meme.fromJson(json.decode(rawMeme)))
        .toList();
  }

  Future<bool> _setMemes(final List<Meme> memes) async {
    final rawMemes = memes.map((meme) => json.encode(meme.toJson())).toList();
    return _setRawMemes(rawMemes);
  }

  Future<bool> _setRawMemes(final List<String> rawMemes) async {
    updater.add(null);
    return await spData.setMemes(rawMemes);
  }
}
