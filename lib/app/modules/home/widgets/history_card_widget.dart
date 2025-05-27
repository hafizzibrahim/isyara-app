

import 'package:flutter/material.dart';
import 'package:isyara_app/themes.dart';

class HistoryCardWidget extends StatelessWidget {
  const HistoryCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text("Lorem ipsum dolor sit amet, consectetur", style: regularText12, overflow: TextOverflow.ellipsis, maxLines: 1,),
        ],
      )
    );
  }
}