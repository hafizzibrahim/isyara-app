import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isyara_app/app/modules/text_to_gesture/controllers/text_to_gesture_controller.dart';
import 'package:isyara_app/themes.dart';
import 'package:video_player/video_player.dart';

class TextToGestureView extends GetView<TextToGestureController> {
  const TextToGestureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBlue,
      appBar: AppBar(
        backgroundColor: softBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text("Text to Gesture", style: semiBoldText22),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CircularProgressIndicator();
                }
                if (controller.videos.isEmpty ||
                    controller.videoControllers.isEmpty) {
                  return const Text("Masukan Kata yang ingin diterjemahkan");
                }

                final index = controller.currentVideoIndex.value;
                if (index < 0 ||
                    index >= controller.videoControllers.length ||
                    index >= controller.videos.length) {
                  return const Text("Terjadi kesalahan pada video");
                }

                final videoCtrl = controller.videoControllers[index];
                final word = controller.videos[index].word;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      word,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!videoCtrl.value.isInitialized)
                      const CircularProgressIndicator()
                    else
                      AspectRatio(
                        aspectRatio: videoCtrl.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            VideoPlayer(videoCtrl),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.replay,
                                  color: Colors.white,
                                  size: 36,
                                ),
                                // Panggil metode baru untuk memutar ulang dari awal
                                onPressed: controller.replayVideosFromStart,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
      bottomSheet: _buildInputSection(),
    );
  }

  Widget _buildInputSection() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Masukkan kalimat...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) {
                  if (!controller.isLoading.value) {
                    controller.submitText();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => InkWell(
                onTap:
                    controller.isLoading.value ? null : controller.submitText,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        controller.isLoading.value ? Colors.grey : Colors.teal,
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
