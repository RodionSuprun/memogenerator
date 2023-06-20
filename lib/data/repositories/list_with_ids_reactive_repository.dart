abstract class ListWithIdsReactiveRepository<T> {
  Future<List<String>> getRawData();
  Future<bool> saveRawData(final List<String> items);
  T convertFromString(final String rawItem);
  String convertToString(final T item);
  dynamic getId(final T item);

  Future<List<T>> getItems();
  Future<bool> setItems(final List<T> items);
  Stream<List<T>> observeItems();
  Future<bool> addItem(final T newItem);
  Future<bool> removeItem(final T item);
  Future<bool> addItemOrReplaceById(final T newItem);
  Future<bool> removeFromItemsById(final dynamic id);
  Future<T?> getItemById(final dynamic id);
}