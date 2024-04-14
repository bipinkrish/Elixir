import 'package:elixir/theme.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16, top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: SizedBox(
                height: 32, width: 32, child: Image.asset("assets/logo.png")),
          ),
          const SizedBox(width: 12),
          Container(
              width: 128,
              height: 128,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(164, 31, 30, 36),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white24,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: getPackman())
        ],
      ),
    );
  }
}

LoadingIndicator getPackman() {
  return const LoadingIndicator(
    indicatorType: Indicator.pacman,
    colors: [kWhiteColor, Colors.green, Colors.red],
  );
}
