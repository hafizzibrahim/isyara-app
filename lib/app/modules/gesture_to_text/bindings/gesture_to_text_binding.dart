import 'package:get/get.dart';

import '../controllers/gesture_to_text_controller.dart';

class GestureToTextBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GestureToTextController>(
      () => GestureToTextController(),
    );
  }
}
