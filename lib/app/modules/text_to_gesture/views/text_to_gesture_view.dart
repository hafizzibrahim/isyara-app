import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:isyara_app/themes.dart';

import '../controllers/text_to_gesture_controller.dart';

class TextToGestureView extends GetView<TextToGestureController> {
  const TextToGestureView({super.key});
@override
  Widget build(BuildContext context) {

    final TextToGestureController controller = Get.put(TextToGestureController());
    
    return Scaffold(
      backgroundColor: softBlue,
      appBar: AppBar(
        backgroundColor: softBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text("Text to Animation", style: semiBoldText22),
        centerTitle: true,
      ),
body: Stack(
        children: [
          // Placeholder stickman
          Positioned.fill(
            child: Center(
              child: Placeholder(), // Ganti nanti dengan animasi stickman
            ),
          ),

          // Container putih input di bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Input text",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            maxLines: 3,
                            controller: controller.textController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: controller.submitText,
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.teal,
                            ),
                            child: const Icon(Icons.send, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
