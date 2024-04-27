import 'package:elixir/components/utils.dart';
import 'package:elixir/theme.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String inProgressResponse;
  final Map inProgressData;

  const LoadingWidget({
    super.key,
    required this.inProgressResponse,
    required this.inProgressData,
  });

  @override
  Widget build(BuildContext context) {
    Map sources = inProgressData["sources"] ?? {};
    List images = inProgressData["images"] ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16, top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: SizedBox(
              height: 32,
              width: 32,
              child: Image.asset("assets/logo.png"),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
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
              child: Column(
                children: [
                  if (images.isNotEmpty) getImagesWidget(images),
                  const SizedBox(
                    height: 8,
                  ),
                  if (inProgressResponse.isNotEmpty)
                    Text(
                      inProgressResponse,
                      style: kWhiteText.copyWith(
                          fontSize: 16, fontWeight: kRegular),
                    ),
                  if (inProgressResponse.isEmpty)
                    SizedBox(width: 128, height: 128, child: getPackman()),
                  const SizedBox(
                    height: 8,
                  ),
                  if (sources.isNotEmpty) getSourcesWidget(sources),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
