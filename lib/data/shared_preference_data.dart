import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceData {
  static const memeKey = "meme_key";
  static const templateKey = "template_key";

  static SharedPreferenceData? _instance;

  factory SharedPreferenceData.getInstance() =>
      _instance ??= SharedPreferenceData._internal();

  SharedPreferenceData._internal();

  Future<bool> setMemes(final List<String> memes) async {
    return setItems(memeKey, memes);
  }

  Future<List<String>> getMemes() async {
    return getItems(memeKey);
  }

  Future<bool> setTemplates(final List<String> templates) async {
    return setItems(templateKey, templates);
  }

  Future<List<String>> getTemplates() async {
    return getItems(templateKey);
  }

  Future<bool> setItems(final String key, final List<String> templates) async {
    final sp = await SharedPreferences.getInstance();
    final result = sp.setStringList(key, templates);
    return result;
  }

  Future<List<String>> getItems(final String key) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(key) ?? [];
  }
}
