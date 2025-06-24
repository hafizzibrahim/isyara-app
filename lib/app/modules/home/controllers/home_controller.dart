import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  final textToGestureHistory = <String>[].obs;

  static const _prefsKey = 'textToGestureHistory';

  @override
  void onInit() {
    super.onInit();
    loadHistory(); // Load saat controller dibuat
  }

  void addTextToGestureHistory(String text) async {
    if (text.isNotEmpty && !textToGestureHistory.contains(text)) {
      textToGestureHistory.insert(0, text);
      await saveHistory(); // Simpan ke shared prefs
    }
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, textToGestureHistory);
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedList = prefs.getStringList(_prefsKey);
    if (savedList != null) {
      textToGestureHistory.assignAll(savedList);
    }
  }
}
