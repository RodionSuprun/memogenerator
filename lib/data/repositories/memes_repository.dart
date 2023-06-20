import 'dart:convert';

import 'package:memogenerator/data/shared_preference_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

import '../models/meme.dart';
import 'list_with_ids_reactive_repository.dart';

class MemesRepository extends ListWithIdsReactiveRepository<Meme> {
  final SharedPreferenceData spData;

  final updater = PublishSubject<Null>();

  static MemesRepository? _instance;

  factory MemesRepository.getInstance() => _instance ??=
      MemesRepository._internal(SharedPreferenceData.getInstance());

  MemesRepository._internal(this.spData);

  @override
  Meme convertFromString(String rawItem) {
    return Meme.fromJson(json.decode(rawItem));
  }

  @override
  String convertToString(Meme item) {
    return json.encode(item.toJson());
  }

  @override
  getId(Meme item) {
    return item.id;
  }

  @override
  Future<List<String>> getRawData() async {
    return await spData.getMemes();
  }

  @override
  Future<bool> saveRawData(List<String> items) async {
    updater.add(null);
    return await spData.setMemes(items);
  }

  @override
  Future<bool> addItem(Meme newItem) async {
    final memes = await getItems();
    memes.add(newItem);
    return setItems(memes);
  }

  @override
  Future<bool> addItemOrReplaceById(Meme newItem) async {
    final memes = await getItems();

    final elementIndex =
        memes.indexWhere((element) => element.id == newItem.id);
    if (elementIndex == -1) {
      memes.add(newItem);
    } else {
      memes.removeAt(elementIndex);
      memes.insert(elementIndex, newItem);
      // memes[elementIndex] = newMeme;
    }
    return setItems(memes);
  }

  @override
  Future<List<Meme>> getItems() async {
    final rawMemes = await getRawData();
    return rawMemes.map((rawMeme) => convertFromString(rawMeme)).toList();
  }

  @override
  Future<bool> setItems(List<Meme> items) {
    final rawMemes = items.map((item) => convertToString(item)).toList();
    return saveRawData(rawMemes);
  }

  @override
  Future<Meme?> getItemById(id) async {
    final memes = await getItems();
    return memes.firstWhereOrNull((meme) {
      return meme.id == id;
    });
  }

  @override
  Stream<List<Meme>> observeItems() async* {
    yield await getItems();
    await for (final _ in updater) {
      yield await getItems();
    }
  }

  @override
  Future<bool> removeFromItemsById(id) async {
    final memes = await getItems();
    memes.removeWhere((meme) => meme.id == id);
    return setItems(memes);
  }

  @override
  Future<bool> removeItem(Meme item) async {
    final memes = await getItems();
    memes.removeWhere((meme) => meme.id == item.id);
    return setItems(memes);
  }
}
