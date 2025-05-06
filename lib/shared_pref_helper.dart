import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String _key = 'my_string_key';

  /// String qiymatni saqlash
  Future<void> saveString(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value);
  }

  /// String qiymatni o'qish
  Future<String?> getString() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// String qiymatni o'chirish (ixtiyoriy)
  Future<void> removeString() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
