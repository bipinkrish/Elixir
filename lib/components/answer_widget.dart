import 'package:elixir/components/utils.dart';
import 'package:elixir/extensions.dart';
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
                  selectable: true,
                  selectionColor: Colors.lightBlue,
                  syntaxExtensions: syntaxes,
                  elementBuilders: builders,
                  highlightBuilder: (text, language, infoString) {
                    // Code Highlighting
                    return prism.render(text, language ?? 'plain');
                  },
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
                  onTapLink: (href, title) {
                    // ignore: avoid_print
                    print({href, title});
                  },
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
