import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextToGestureController extends GetxController {
  //TODO: Implement TextToGestureController
  final count = 0.obs;
  final TextEditingController textController = TextEditingController();
  

  void submitText() {
    final input = textController.text.trim();
    if (input.isNotEmpty) {
      // Contoh debug print
      print("Input text: $input");

      // Clear input
      textController.clear();
    } else {
      Get.snackbar("Oops", "Text tidak boleh kosong");
    }
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  void increment() => count.value++;
}