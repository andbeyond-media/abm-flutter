import 'package:shared_preferences/shared_preferences.dart';

/// A simple helper class for managing preferences using SharedPreferences.
class PreferencesHelper {
  /// Private constructor to prevent instantiation from outside the class.
  PreferencesHelper._();

  /// Static instance of the PreferencesHelper.
  static final PreferencesHelper instance = PreferencesHelper._();

  /// SharedPreferences instance.
  SharedPreferences? _prefs;

  /// Initializes the SharedPreferences instance.
  ///
  /// This method must be called before using any other methods of this class.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Saves a string value to preferences.
  ///
  /// [key] is the key to store the value under.
  /// [value] is the string value to store.
  Future<bool> setString(String key, String value) async {
    _checkInitialized();
    return await _prefs!.setString(key, value);
  }

  /// Retrieves a string value from preferences.
  ///
  /// [key] is the key to retrieve the value for.
  /// [defaultValue] is the value to return if the key is not found.
  String getString(String key, {String defaultValue = ''}) {
    _checkInitialized();
    return _prefs!.getString(key) ?? defaultValue;
  }

  /// Saves an integer value to preferences.
  ///
  /// [key] is the key to store the value under.
  /// [value] is the integer value to store.
  Future<bool> setInt(String key, int value) async {
    _checkInitialized();
    return await _prefs!.setInt(key, value);
  }

  /// Retrieves an integer value from preferences.
  ///
  /// [key] is the key to retrieve the value for.
  /// [defaultValue] is the value to return if the key is not found.
  int getInt(String key, {int defaultValue = 0}) {
    _checkInitialized();
    return _prefs!.getInt(key) ?? defaultValue;
  }

  /// Saves a double value to preferences.
  ///
  /// [key] is the key to store the value under.
  /// [value] is the double value to store.
  Future<bool> setDouble(String key, double value) async {
    _checkInitialized();
    return await _prefs!.setDouble(key, value);
  }

  /// Retrieves a double value from preferences.
  ///
  /// [key] is the key to retrieve the value for.
  /// [defaultValue] is the value to return if the key is not found.
  double getDouble(String key, {double defaultValue = 0.0}) {
    _checkInitialized();
    return _prefs!.getDouble(key) ?? defaultValue;
  }

  /// Saves a boolean value to preferences.
  ///
  /// [key] is the key to store the value under.
  /// [value] is the boolean value to store.
  Future<bool> setBool(String key, bool value) async {
    _checkInitialized();
    return await _prefs!.setBool(key, value);
  }

  /// Retrieves a boolean value from preferences.
  ///
  /// [key] is the key to retrieve the value for.
  /// [defaultValue] is the value to return if the key is not found.
  bool getBool(String key, {bool defaultValue = false}) {
    _checkInitialized();
    return _prefs!.getBool(key) ?? defaultValue;
  }

  /// Saves a list of strings to preferences.
  ///
  /// [key] is the key to store the value under.
  /// [value] is the list of strings to store.
  Future<bool> setStringList(String key, List<String> value) async {
    _checkInitialized();
    return await _prefs!.setStringList(key, value);
  }

  /// Retrieves a list of strings from preferences.
  ///
  /// [key] is the key to retrieve the value for.
  /// [defaultValue] is the value to return if the key is not found.
  List<String> getStringList(String key,
      {List<String> defaultValue = const []}) {
    _checkInitialized();
    return _prefs!.getStringList(key) ?? defaultValue;
  }

  /// Removes a value from preferences.
  ///
  /// [key] is the key to remove.
  Future<bool> remove(String key) async {
    _checkInitialized();
    return await _prefs!.remove(key);
  }

  /// Clears all values from preferences.
  Future<bool> clear() async {
    _checkInitialized();
    return await _prefs!.clear();
  }

  /// Checks if the SharedPreferences instance is initialized.
  ///
  /// Throws an exception if it's not initialized.
  void _checkInitialized() {
    if (_prefs == null) {
      throw Exception('PreferencesHelper not initialized. Call init() first.');
    }
  }
}
