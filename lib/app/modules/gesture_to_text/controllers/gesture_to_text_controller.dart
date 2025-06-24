import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class GestureToTextController extends GetxController
    with WidgetsBindingObserver {
  late CameraController _cameraController;
  late IO.Socket socket;
  List<CameraDescription> cameras = [];
  var activeCameraIndex = 0.obs;
  final isCameraInitialized = false.obs;
  var predictionResult = "".obs;

  bool _isStreaming = false;
  DateTime _lastFrameSent = DateTime.now().subtract(Duration(seconds: 2));

  List<String> recentPredictions = [];
  final int maxBufferSize = 5;

  @override
  void onInit() {
    super.onInit();
    initSocket();
    initCamera();
    WidgetsBinding.instance.addObserver(this);
  }

  void initSocket() {
    socket = IO.io(
      'https://healthy-exact-terrier.ngrok-free.app',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) => print("✅ Terhubung ke server"));

    socket.on('prediction', (data) {
      final pred = data['class'];

      if (pred == '...') {
        predictionResult.value = "🔄 Mendeteksi...";
      } else if (pred == 'Error') {
        predictionResult.value = "❌ Error: ${data['error']}";
      } else {
        updatePrediction(pred);
        predictionResult.value = "Hasil: $pred";
      }
    });

    socket.onError((error) {
      predictionResult.value = "Error socket: $error";
    });

    socket.onDisconnect((_) => print("❌ Terputus dari server"));
  }

  void updatePrediction(String newPrediction) {
    recentPredictions.add(newPrediction);
    if (recentPredictions.length > maxBufferSize) {
      recentPredictions.removeAt(0);
    }

    final Map<String, int> frequency = {};
    for (var pred in recentPredictions) {
      frequency[pred] = (frequency[pred] ?? 0) + 1;
    }

    final sorted =
        frequency.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.isNotEmpty && sorted.first.value >= 3) {
      predictionResult.value = "Hasil: ${sorted.first.key}";
    }
  }

  Future<void> initCamera() async {
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      predictionResult.value = "Error: Kamera ditolak";
      return;
    }

    cameras = await availableCameras();
    if (cameras.isEmpty) {
      predictionResult.value = "Error: Tidak ada kamera tersedia";
      return;
    }

    activeCameraIndex.value = 0;
    await initializeCamera(cameras[activeCameraIndex.value]);
  }

  Future<void> initializeCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController.initialize();
      isCameraInitialized.value = true;
      _startImageStream();
    } catch (e) {
      predictionResult.value = "Error: Gagal inisialisasi kamera - \$e";
    }
  }

  void _startImageStream() {
    if (_isStreaming) return;
    _isStreaming = true;

    _cameraController.startImageStream((CameraImage image) async {
      final now = DateTime.now();
      if (now.difference(_lastFrameSent) >= Duration(seconds: 1)) {
        _lastFrameSent = now;
        await _processImage(image);
      }
    });
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      final XFile picture = await _cameraController.takePicture();
      final Uint8List bytes = await picture.readAsBytes();
      final base64Image = base64Encode(bytes);

      print(
        "📤 Frame dikirim (takePicture): \${base64Image.substring(0, 20)}...",
      );
      socket.emit("frame", {"image": base64Image});
    } catch (e) {
      predictionResult.value = "Error proses gambar (takePicture): $e";
    }
  }

  Future<void> switchCamera() async {
    if (cameras.length < 2) return;
    stopCamera();
    activeCameraIndex.value = (activeCameraIndex.value + 1) % cameras.length;
    await initializeCamera(cameras[activeCameraIndex.value]);
  }

  void stopCamera() {
    if (isCameraInitialized.value) {
      _cameraController.stopImageStream();
      _cameraController.dispose();
      isCameraInitialized.value = false;
      _isStreaming = false;
    }
  }

  Future<void> reinitCamera() async {
    if (!isCameraInitialized.value && cameras.isNotEmpty) {
      await initializeCamera(cameras[activeCameraIndex.value]);
    }
  }

  CameraController get cameraController => _cameraController;

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    stopCamera();
    socket.disconnect();
    super.onClose();
  }
}

String convertRawImageToBase64(Map<String, dynamic> input) {
  final List<Uint8List> planes = input['bytes'];
  final int width = input['metadata']['width'];
  final int height = input['metadata']['height'];
  final String formatStr = input['metadata']['format'];

  img.Image? image;

  if (formatStr.contains('yuv420')) {
    final yPlane = planes[0];
    final uPlane = planes[1];
    final vPlane = planes[2];

    image = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * width + x;
        final uvIndex = (x >> 1) + (y >> 1) * (width >> 1);

        final Y = yPlane[yIndex];
        final U = uPlane[uvIndex] - 128;
        final V = vPlane[uvIndex] - 128;

        final r = (Y + 1.402 * V).clamp(0, 255).toInt();
        final g = (Y - 0.344 * U - 0.714 * V).clamp(0, 255).toInt();
        final b = (Y + 1.772 * U).clamp(0, 255).toInt();

        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }
  } else if (formatStr.contains('bgra8888')) {
    final data = planes[0];
    image = img.Image(width: width, height: height);

    int i = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (i + 3 >= data.length) break;
        final b = data[i++];
        final g = data[i++];
        final r = data[i++];
        final a = data[i++];
        image.setPixelRgba(x, y, r, g, b, a);
      }
    }
  } else {
    throw Exception("Format kamera tidak dikenali: \$formatStr");
  }

  if (image == null) {
    throw Exception("Gagal membuat image dari raw data");
  }

  const targetSize = 144;
  double scale = targetSize / (width > height ? width : height);
  int newW = (width * scale).round();
  int newH = (height * scale).round();

  final resized = img.copyResize(image, width: newW, height: newH);
  final padded = img.Image(width: targetSize, height: targetSize);

  for (int y = 0; y < targetSize; y++) {
    for (int x = 0; x < targetSize; x++) {
      padded.setPixelRgba(x, y, 0, 0, 0, 255);
    }
  }

  final offsetX = ((targetSize - newW) / 2).floor();
  final offsetY = ((targetSize - newH) / 2).floor();

  for (int y = 0; y < newH; y++) {
    for (int x = 0; x < newW; x++) {
      final pixel = resized.getPixel(x, y);
      padded.setPixel(offsetX + x, offsetY + y, pixel);
    }
  }

  final jpg = img.encodeJpg(padded, quality: 85);
  return base64Encode(jpg);
}
