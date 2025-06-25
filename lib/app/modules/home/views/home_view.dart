// === home_view.dart ===
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isyara_app/app/modules/gesture_to_text/views/gesture_to_text_view.dart';
import 'package:isyara_app/app/modules/history/bindings/history_binding.dart';
import 'package:isyara_app/app/modules/history/views/history_view.dart';
import 'package:isyara_app/app/modules/home/widgets/history_card_widget.dart';
import 'package:isyara_app/app/modules/text_to_gesture/views/text_to_gesture_view.dart';
import 'package:isyara_app/themes.dart';
import '../../text_to_gesture/bindings/text_to_gesture_binding.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double containerWidth = screenWidth * 0.45;

    return Scaffold(
      backgroundColor: softBlue,
      appBar: AppBar(
        backgroundColor: softBlue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/icons/ic_isyara.png', width: 40, height: 40),
            const SizedBox(width: 10),
            Text("Isyara", style: semiBoldText22),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(1, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      right: -15,
                      child: Image.asset(
                        'assets/images/mascot_home.png',
                        width: 170,
                        height: 170,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hello..!!", style: semiBoldText22),
                        Text("Welcome to Isyara", style: regularText16),
                        const SizedBox(height: 100),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => const GestureToTextView(),
                                    transition: Transition.rightToLeft,
                                    duration: const Duration(milliseconds: 400),
                                  );
                                },
                                child: Container(
                                  width: containerWidth,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: blue,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(25),
                                      topRight: Radius.circular(25),
                                      bottomRight: Radius.circular(25),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Video to Text",
                                              style: semiBoldText16.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Image.asset(
                                            'assets/icons/ic_hand_sign.png',
                                            width: 40,
                                            height: 40,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "Record your hand sign to generate and get the text!",
                                        style: regularText10.copyWith(
                                          color: Colors.white,
                                        ),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => const TextToGestureView(),
                                    binding: TextToGestureBinding(),
                                    transition: Transition.rightToLeft,
                                    duration: const Duration(milliseconds: 400),
                                  );
                                },
                                child: Container(
                                  width: containerWidth,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: green,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(25),
                                      topRight: Radius.circular(25),
                                      topLeft: Radius.circular(25),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Text to Gesture",
                                              style: semiBoldText16.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Image.asset(
                                            'assets/icons/ic_play.png',
                                            width: 40,
                                            height: 40,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "Write a sentence and see how it's signed in video form!",
                                        style: regularText10.copyWith(
                                          color: Colors.white,
                                        ),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("History", style: semiBoldText22),
                            TextButton(
                              onPressed: () {
                                Get.to(
                                  () => HistoryView(),
                                  binding: HistoryBinding(),
                                  transition: Transition.rightToLeft,
                                  duration: const Duration(milliseconds: 400),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                              ),
                              child: Text(
                                "See All",
                                style: semiBoldText12.copyWith(color: blue),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Obx(() {
                          final history = controller.textToGestureHistory;
                          if (history.isEmpty) {
                            return const Text("Belum ada riwayat terjemahan.");
                          }
                          return Column(
                            children:
                                history.map((text) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: HistoryCardWidget(text: text),
                                  );
                                }).toList(),
                          );
                        }),
                        const SizedBox(height: 16),
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
