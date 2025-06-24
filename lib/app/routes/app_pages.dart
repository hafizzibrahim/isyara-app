import 'package:get/get.dart';

import '../modules/gesture_to_text/bindings/gesture_to_text_binding.dart';
import '../modules/gesture_to_text/views/gesture_to_text_view.dart';
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/text_to_gesture/bindings/text_to_gesture_binding.dart';
import '../modules/text_to_gesture/views/text_to_gesture_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.GESTURE_TO_TEXT,
      page: () => const GestureToTextView(),
      binding: GestureToTextBinding(),
    ),
    GetPage(
      name: _Paths.TEXT_TO_GESTURE,
      page: () => const TextToGestureView(),
      binding: TextToGestureBinding(),
    ),
    GetPage(
      name: _Paths.HISTORY,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
  ];
}
