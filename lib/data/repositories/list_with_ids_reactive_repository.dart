import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

abstract class ListWithIdsReactiveRepository<T> {

  final updater = PublishSubject<Null>();

  @protected
  Future<List<String>> getRawData();

  @protected
  Future<bool> saveRawData(final List<String> items);

  @protected
  T convertFromString(final String rawItem);

  @protected
  String convertToString(final T item);

  @protected
  dynamic getId(final T item);

  Future<List<T>> getItems() async {
    final rawItems = await getRawData();
    return rawItems.map((rawItem) => convertFromString(rawItem)).toList();
  }

  Future<bool> setItems(List<T> items) {
    final rawItems = items.map((item) => convertToString(item)).toList();
    return saveRawData(rawItems);
  }

  Stream<List<T>> observeItems() async* {
    yield await getItems();
    await for (final _ in updater) {
      yield await getItems();
    }
  }

  Future<bool> addItem(T newItem) async {
    final items = await getItems();
    items.add(newItem);
    return setItems(items);
  }

  Future<bool> removeItem(final T item) async {
    final items = await getItems();
    items.remove(item);
    return setItems(items);
  }

  Future<bool> addItemOrReplaceById(final T newItem) async {
    final items = await getItems();

    final elementIndex =
    items.indexWhere((item) => getId(item) == getId(newItem));
    if (elementIndex == -1) {
      items.add(newItem);
    } else {
      items[elementIndex] = newItem;
    }
    return setItems(items);
  }

  Future<bool> removeFromItemsById(final dynamic id) async {
    final items = await getItems();
    items.removeWhere((item) => getId(item) == id);
    return setItems(items);
  }

  Future<T?> getItemById(final dynamic id) async {
    final rawItems = await getItems();
    return rawItems.firstWhereOrNull((rawItem) {
      return getId(rawItem) == id;
    });
  }
}
