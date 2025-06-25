import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:isyara_app/app/data/models/video_response.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../../home/controllers/home_controller.dart';

class TextToGestureController extends GetxController {
  final textController = TextEditingController();
  final isLoading = false.obs;
  final videos = <VideoResponse>[].obs;
  final videoControllers = <VideoPlayerController>[].obs;
  final currentVideoIndex = 0.obs;

  final String baseUrl = "https://healthy-exact-terrier.ngrok-free.app";

  @override
  void onInit() {
    super.onInit();

    final initialText = Get.arguments?['initialText'];
    if (initialText != null && initialText is String && initialText.isNotEmpty) {
      textController.text = initialText;
      submitText(); // langsung kirim jika ada teks dari history
    }
  }

  Future<void> submitText() async {
    final inputText = textController.text.trim();
    if (inputText.isEmpty) {
      Get.snackbar("Oops", "Teks nggak boleh kosong");
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/translate'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": inputText}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> videoList = data['videos'];

        for (var c in videoControllers) {
          c.removeListener(_videoEndListener);
          await c.dispose();
        }
        videoControllers.clear();

        final newVideos = <VideoResponse>[];
        for (var v in videoList) {
          final rawBase64 = (v['video_data'] as String).split(',').last;
          if (isValidBase64(rawBase64)) {
            newVideos.add(
              VideoResponse(word: v['class'], videoData: rawBase64),
            );
          } else {
            Get.snackbar("Error", "Ada video dengan format tidak valid");
          }
        }

        videos.assignAll(newVideos);

        final futures = newVideos.map(
          (v) => _createVideoController(v.videoData),
        );
        final controllers = await Future.wait(futures);
        videoControllers.assignAll(controllers);

        currentVideoIndex.value = 0;

        if (videoControllers.isNotEmpty) {
          _playVideoAtIndex(0);
        }

        if (Get.focusScope != null) {
          Get.focusScope!.unfocus();
        }

        // Tambahkan ke history di HomeController
        final homeController = Get.find<HomeController>();
        homeController.addTextToGestureHistory(inputText);

        Get.snackbar("Sukses", "Teks berhasil diterjemahkan ke gesture");
        textController.clear();
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar("Error", error['detail'] ?? "Ada masalah di server");
      }
    } catch (e, s) {
      if (kDebugMode) print("ERROR: $e\nSTACKTRACE: $s");
      Get.snackbar("Error", "Gagal proses permintaan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  bool isValidBase64(String src) {
    try {
      final result = base64.decode(src);
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<VideoPlayerController> _createVideoController(
    String base64Data,
  ) async {
    try {
      final bytes = base64Decode(base64Data);
      final tempDir = await getTemporaryDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${UniqueKey().toString()}.mp4';
      final file = File('${tempDir.path}/$fileName');
      await file.create();
      await file.writeAsBytes(bytes);

      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      controller.setLooping(false);

      return controller;
    } catch (e) {
      Get.snackbar("Error", "Gagal muat video: $e");
      rethrow;
    }
  }

  void _playVideoAtIndex(int index) {
    if (index < 0 || index >= videoControllers.length) return;

    for (var c in videoControllers) {
      c.pause();
      c.seekTo(Duration.zero);
    }

    final current = videoControllers[index];
    current.play();

    current.removeListener(_videoEndListener);
    current.addListener(_videoEndListener);
  }

  void _videoEndListener() {
    final current = videoControllers[currentVideoIndex.value];
    if (current.value.position >= current.value.duration &&
        !current.value.isPlaying) {
      current.removeListener(_videoEndListener);

      final nextIndex = currentVideoIndex.value + 1;
      if (nextIndex < videoControllers.length) {
        currentVideoIndex.value = nextIndex;
        _playVideoAtIndex(nextIndex);
      }
    }
  }

  void replayVideosFromStart() {
    if (videoControllers.isNotEmpty) {
      _playVideoAtIndex(0);
    }
  }

  void replayCurrentVideo() {
    final index = currentVideoIndex.value;
    if (index < videoControllers.length) {
      _playVideoAtIndex(index);
    }
  }

  @override
  void onClose() {
    for (var c in videoControllers) {
      c.dispose();
    }
    videoControllers.clear();
    videos.clear();
    currentVideoIndex.value = 0;

    textController.clear();
    textController.dispose();
    super.onClose();
  }
}
