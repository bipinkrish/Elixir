import 'package:elixir/theme.dart';
import 'package:flutter/material.dart';
import 'package:markdown_viewer/markdown_viewer.dart';

class UserQuestionWidget extends StatelessWidget {
  final String question;

  const UserQuestionWidget({required this.question, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            child: MarkdownViewer(
              question,
              styleSheet: MarkdownStyle(
                textStyle:
                    kWhiteText.copyWith(fontSize: 16, fontWeight: kRegular),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ClipOval(
          child: Material(
            color: Colors.deepOrangeAccent,
            child: SizedBox(
              height: 32,
              width: 32,
              child: Center(
                child: Text(
                  "Me",
                  style: kWhiteText.copyWith(
                    fontWeight: kSemiBold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
