import 'dart:convert';

import 'package:memogenerator/data/shared_preference_data.dart';
import 'package:rxdart/rxdart.dart';

import '../models/meme.dart';
import 'list_with_ids_reactive_repository.dart';

class MemesRepository extends ListWithIdsReactiveRepository<Meme> {
  final SharedPreferenceData spData;

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

}
