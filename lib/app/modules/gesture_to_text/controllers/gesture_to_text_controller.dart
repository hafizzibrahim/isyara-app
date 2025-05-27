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

class GestureToTextController extends GetxController with WidgetsBindingObserver {
  late CameraController _cameraController;
  late IO.Socket socket;
  List<CameraDescription> cameras = []; // Menyimpan daftar kamera
  var activeCameraIndex = 0.obs; // Indeks kamera aktif
  final isCameraInitialized = false.obs;
  var predictionResult = "".obs; // Menyimpan hasil prediksi dari server
  Timer? _throttleTimer;
  bool _isStreaming = false;

  @override
  void onInit() {
    super.onInit();
    initSocket();
    initCamera();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      stopCamera();
    } else if (state == AppLifecycleState.resumed) {
      reinitCamera();
    }
  }

  void initSocket() {
    socket = IO.io(
      'http://127.0.0.1:8000', // Ganti dengan URL server Anda
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      predictionResult.value = "Connected to server";
    });

    socket.on('prediction', (data) {
      predictionResult.value = "Hasil: ${data['class']}";
    });

    socket.onError((error) {
      predictionResult.value = "Socket error: $error";
    });

    socket.onDisconnect((_) => print("❌ Disconnected from socket"));
  }

  Future<void> initCamera() async {
    try {
      var status = await Permission.camera.request();
      if (!status.isGranted) {
        predictionResult.value = "Error: Camera permission denied";
        return;
      }

      cameras = await availableCameras();
      if (cameras.isEmpty) {
        predictionResult.value = "Error: No cameras available";
        return;
      }

      activeCameraIndex.value = 0;
      await initializeCamera(cameras[activeCameraIndex.value]);
    } catch (e) {
      predictionResult.value = "Error initializing camera: $e";
    }
  }

  Future<void> initializeCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController.initialize();
      if (!isClosed) {
        isCameraInitialized.value = true;
        _startImageStream();
      }
    } catch (e) {
      predictionResult.value = "Error: Failed to initialize camera - $e";
    }
  }

  void _startImageStream() {
    if (_isStreaming) return;

    _isStreaming = true;
    _cameraController.startImageStream((CameraImage image) {
      processImage(image);
    });
  }

  Future<void> switchCamera() async {
    if (cameras.length < 2) {
      print('Only one camera available');
      return;
    }

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

  void processImage(CameraImage image) {
    if (_throttleTimer?.isActive ?? false) return;

    _throttleTimer?.cancel();
    _throttleTimer = Timer(const Duration(seconds: 2), () {
      _processImageWithThrottle(image);
    });
  }

  void _processImageWithThrottle(CameraImage image) async {
    try {
      final width = image.width;
      final height = image.height;
      final format = image.format.group;

      final planeData =
          image.planes.map((plane) => plane.bytes.buffer.asUint8List()).toList();

      final metadata = {
        "width": width,
        "height": height,
        "format": format.toString(),
      };

      final input = {
        "bytes": planeData,
        "metadata": metadata,
      };

      final base64Image = await compute(convertRawImageToBase64, input);
      socket.emit("frame", {"image": base64Image, "metadata": metadata});
    } catch (e) {
      predictionResult.value = "Error processing image: $e";
    }
  }

  CameraController get cameraController => _cameraController;

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    stopCamera();
    socket.dispose();
    _throttleTimer?.cancel();
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

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
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
    image = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: planes[0].buffer,
      order: img.ChannelOrder.bgra,
    );
  }

  final jpg = img.encodeJpg(image!);
  return base64Encode(jpg);
}