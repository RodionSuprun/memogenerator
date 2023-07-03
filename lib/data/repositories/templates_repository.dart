import 'dart:convert';

import 'package:memogenerator/data/shared_preference_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

import '../models/template.dart';
import 'list_with_ids_reactive_repository.dart';

class TemplatesRepository extends ListWithIdsReactiveRepository<Template> {
  final SharedPreferenceData spData;

  static TemplatesRepository? _instance;

  factory TemplatesRepository.getInstance() => _instance ??=
      TemplatesRepository._internal(SharedPreferenceData.getInstance());

  TemplatesRepository._internal(this.spData);

  @override
  Template convertFromString(String rawItem) {
    return Template.fromJson(json.decode(rawItem));
  }

  @override
  String convertToString(Template item) {
    return json.encode(item.toJson());
  }

  @override
  getId(Template item) {
    return item.id;
  }

  @override
  Future<List<String>> getRawData() async {
    return await spData.getTemplates();
  }

  @override
  Future<bool> saveRawData(List<String> items) async {
    updater.add(null);
    return await spData.setTemplates(items);
  }
}
