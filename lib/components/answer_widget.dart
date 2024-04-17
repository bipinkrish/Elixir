import 'package:elixir/api.dart';
import 'package:elixir/theme.dart';
import 'package:flutter/material.dart';
import 'package:markdown_viewer/markdown_viewer.dart';

class AnswerWidget extends StatelessWidget {
  final String answer;
  final Map sources;
  final List images;

  const AnswerWidget(
      {required this.answer,
      required this.sources,
      required this.images,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: SizedBox(
              height: 32, width: 32, child: Image.asset("assets/logo.png")),
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
                MarkdownViewer(
                  answer,
                  enableTaskList: true,
                  enableSuperscript: true,
                  enableSubscript: true,
                  enableFootnote: true,
                  enableImageSize: true,
                  enableKbd: true,
                  styleSheet: MarkdownStyle(
                    textStyle:
                        kWhiteText.copyWith(fontSize: 16, fontWeight: kRegular),
                    codeSpan: const TextStyle(color: Colors.green),
                    codeBlock: const TextStyle(color: kWhiteColor),
                    codeblockDecoration: BoxDecoration(
                      color: const Color.fromARGB(207, 39, 40, 34),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tableHead: const TextStyle(color: Colors.green),
                    tableBorder: TableBorder.all(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                if (sources.isNotEmpty) getSourcesWidget(sources),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

RawScrollbar getImagesWidget(List images) {
  final ScrollController scrollController = ScrollController();

  return RawScrollbar(
    controller: scrollController,
    thumbVisibility: true,
    trackVisibility: true,
    thumbColor: kWhiteColor,
    trackColor: kBg100Color,
    radius: const Radius.circular(4),
    trackRadius: const Radius.circular(4),
    child: SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var image in images)
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.network(
                  getImageUrl(image)

                ),
              ),
            ),
        ],
      ),
    ),
  );
}

Column getSourcesWidget(Map sources) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Sources",
        style: kWhiteText.copyWith(
            fontSize: 16, fontWeight: kSemiBold, color: Colors.green),
      ),
      const SizedBox(
        height: 8,
      ),
      for (var source in sources.entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              const Icon(
                Icons.link,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  source.key + ": " + source.value.join(", "),
                  style:
                      kWhiteText.copyWith(fontSize: 14, fontWeight: kRegular),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
    ],
  );
}
