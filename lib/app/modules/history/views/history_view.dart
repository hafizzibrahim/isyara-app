import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isyara_app/app/modules/home/controllers/home_controller.dart';
import 'package:isyara_app/app/modules/home/widgets/history_card_widget.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
      ),
      body: Obx(() {
        final history = homeController.textToGestureHistory;

        if (history.isEmpty) {
          return const Center(
            child: Text("Belum ada riwayat."),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: HistoryCardWidget(text: history[index]),
            );
          },
        );
      }),
    );
  }
}
