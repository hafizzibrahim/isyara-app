import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isyara_app/app/modules/text_to_gesture/bindings/text_to_gesture_binding.dart';
import 'package:isyara_app/app/modules/text_to_gesture/views/text_to_gesture_view.dart';
import 'package:isyara_app/themes.dart';

class HistoryCardWidget extends StatelessWidget {
  final String text;

  const HistoryCardWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => const TextToGestureView(),
          binding: TextToGestureBinding(),
          arguments: {'initialText': text},
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 400),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/icons/ic_history.png',
              width: 25,
              height: 25,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: regularText12,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
