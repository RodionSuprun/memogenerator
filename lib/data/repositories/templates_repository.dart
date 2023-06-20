import 'dart:convert';

import 'package:memogenerator/data/shared_preference_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

import '../models/template.dart';
import 'list_with_ids_reactive_repository.dart';

class TemplatesRepository extends ListWithIdsReactiveRepository<Template> {
  final SharedPreferenceData spData;

  final updater = PublishSubject<Null>();

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

  @override
  Future<List<Template>> getItems() async {
    final rawData = await getRawData();
    return rawData.map((rawItem) {
      return convertFromString(rawItem);
    }).toList();
  }

  @override
  Future<bool> setItems(List<Template> items) async {
    final rawData = items.map((item) => convertToString(item)).toList();
    return saveRawData(rawData);
  }

  @override
  Future<bool> addItem(Template newItem) async {
    final items = await getItems();
    items.add(newItem);
    return setItems(items);
  }

  @override
  Future<bool> addItemOrReplaceById(Template newItem) async {
    final templates = await getItems();
    final elementIndex =
        templates.indexWhere((element) => element.id == newItem.id);
    if (elementIndex == -1) {
      templates.add(newItem);
    } else {
      templates.removeAt(elementIndex);
      templates.insert(elementIndex, newItem);
    }
    return setItems(templates);
  }

  @override
  Future<Template?> getItemById(id) async {
    final templates = await getItems();
    return templates.firstWhereOrNull((template) {
      return template.id == id;
    });
  }

  @override
  Stream<List<Template>> observeItems() async* {
    yield await getItems();
    await for (final _ in updater) {
      yield await getItems();
    }
  }

  @override
  Future<bool> removeFromItemsById(id) async {
    final templates = await getItems();
    templates.removeWhere((template) => template.id == id);
    return setItems(templates);
  }

  @override
  Future<bool> removeItem(Template item) async {
    final templates = await getItems();
    templates.removeWhere((template) => template.id == item.id);
    return setItems(templates);
  }
}
