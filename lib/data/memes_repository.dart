import 'dart:convert';

import 'package:memogenerator/data/shared_preferences_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

import 'models/meme.dart';

class MemesRepository {
  final SharedPreferencesData spData;

  final updater = PublishSubject<Null>();

  static MemesRepository? _instance;

  factory MemesRepository.getInstance() => _instance ??=
      MemesRepository._internal(SharedPreferencesData.getInstance());

  MemesRepository._internal(this.spData);

  Future<bool> addToMemes(final Meme meme) async {
    final rawMemes = await spData.getMemes();
    rawMemes.add(json.encode(meme.toJson()));
    return _setRawMemes(rawMemes);
  }

  Future<bool> removeFromMemes(final String id) async {
    final superHeroes = await _getMemes();
    superHeroes.removeWhere((meme) => meme.id == id);
    return _setMemes(superHeroes);
  }

  Future<Meme?> getMeme(final String id) async {
    final memes = await _getMemes();
    return memes.firstWhereOrNull((meme) {
      return meme.id == id;
    });
  }

  Stream<List<Meme>> observeMemes() async* {
    yield await _getMemes();
    await for (final _ in updater) {
      yield await _getMemes();
    }
  }

  Future<List<Meme>> _getMemes() async {
    final rawMemes = await spData.getMemes();
    return rawMemes
        .map((rawMeme) => Meme.fromJson(json.decode(rawMeme)))
        .toList();
  }

  Future<bool> _setMemes(final List<Meme> memes) async {
    final rawMemes = memes
        .map((meme) => json.encode(meme.toJson()))
        .toList();
    return _setRawMemes(rawMemes);
  }

  Future<bool> _setRawMemes(final List<String> rawMemes) async {
    updater.add(null);
    return await spData.setMemes(rawMemes);
  }

}
