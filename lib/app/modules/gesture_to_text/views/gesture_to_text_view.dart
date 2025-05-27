import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isyara_app/themes.dart';
import '../controllers/gesture_to_text_controller.dart';

class GestureToTextView extends GetView<GestureToTextController> {
  const GestureToTextView({super.key});

  @override
  Widget build(BuildContext context) {
    final GestureToTextController controller = Get.put(GestureToTextController());
    return Scaffold(
      backgroundColor: softBlue,
      appBar: AppBar(
        backgroundColor: softBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text("Video to Text", style: semiBoldText22),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Kamera Preview dengan border rounded & layout tengah
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: 750,
                    color: Colors.grey[700],
                    child: Obx(() {
                      if (controller.isCameraInitialized.value) {
                        return CameraPreview(
                          controller.cameraController,
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tombol untuk beralih kamera
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () => controller.switchCamera(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Icon(Icons.flip_camera_ios, color: Colors.black),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Translated Result",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          // Menampilkan hasil prediksi dari server
          Obx(() => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.predictionResult.value.isEmpty
                      ? "Waiting for prediction..."
                      : controller.predictionResult.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              )),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}