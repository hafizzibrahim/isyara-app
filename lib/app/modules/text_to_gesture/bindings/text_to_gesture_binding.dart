import 'package:get/get.dart';

import '../controllers/text_to_gesture_controller.dart';

class TextToGestureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TextToGestureController>(
      () => TextToGestureController(),
    );
  }
}
