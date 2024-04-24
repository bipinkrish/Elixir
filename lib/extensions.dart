import 'package:flutter/material.dart';
import 'package:markdown_viewer/markdown_viewer.dart';
import 'package:flutter_prism/flutter_prism.dart';

final prism = Prism(
  mouseCursor: SystemMouseCursors.text,
  style: const PrismStyle.dark(),
); // Code Highlighter

List<MdInlineSyntax> syntaxes = [];
List<MarkdownElementBuilder> builders = [];

class SyntaxAndBuilder {
  MdInlineSyntax syntax;
  MarkdownElementBuilder builder;

  SyntaxAndBuilder(this.syntax, this.builder);
}

class MdSyntax extends MdInlineSyntax {
  String name;
  String regex;
  MdSyntax(this.name, this.regex) : super(RegExp(regex));

  @override
  MdInlineObject? parse(MdInlineParser parser, Match match) {
    final markers = [parser.consume()];
    final content = parser.consumeBy(match[0]!.length - 1);
    final children = content.map((e) => MdText.fromSpan(e)).toList();

    return MdInlineElement(
      name,
      markers: markers,
      children: children,
      start: markers.first.start,
      end: children.last.end,
    );
  }
}

class MdBuilder extends MarkdownElementBuilder {
  String name;
  TextStyle style;
  MdBuilder(this.name, this.style) : super(textStyle: style);

  @override
  bool isBlock(element) => false;

  @override
  List<String> matchTypes = <String>["temp"];
}

SyntaxAndBuilder makeSyntaxAndBuilder(
    String name, String regex, TextStyle style) {
  final syntax = MdSyntax(name, regex);
  final builder = MdBuilder(name, style);
  builder.matchTypes[0] = name;
  return SyntaxAndBuilder(syntax, builder);
}

void initSyntaxesAndBuilders() {
  for (SyntaxAndBuilder element in syntaxBuilds) {
    syntaxes.add(element.syntax);
    builders.add(element.builder);
  }
}

//////////////// Editable Code Below //////////////////////

List<SyntaxAndBuilder> syntaxBuilds = [
  makeSyntaxAndBuilder(
    "hashtags",
    r'#[^#]+?(?=\s+|$)',
    const TextStyle(
      color: Colors.deepOrange,
      decoration: TextDecoration.underline,
    ),
  )
];
