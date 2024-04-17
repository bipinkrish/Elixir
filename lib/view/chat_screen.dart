import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:elixir/theme.dart';
import 'package:elixir/api.dart';
import 'package:elixir/components/answer_widget.dart';
import 'package:elixir/components/loading_widget.dart';
import 'package:elixir/components/text_input_widget.dart';
import 'package:elixir/components/user_question_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {super.key, required this.sessionId, required this.sessions});

  final String sessionId;
  final List<Map<String, String>> sessions;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool inProgress = false;
  Map inProgressData = {};
  String inProgressResponse = "";

  late ScrollController scrollController;
  late TextEditingController inputQuestionController;
  List<Map<String, String>> history = [];

  getHistory() {
    getChatHistory(widget.sessionId).then((value) {
      history = value;
      refresh();
    });
  }

  addUserQuestion(String question) {
    history.add({'role': 'user', 'message': question});
  }

  addAiResponse(String result, Map others) {
    others["results"] = result;
    history.add({'role': 'assistant', 'message': jsonEncode(others)});
  }

  @override
  void initState() {
    inputQuestionController = TextEditingController();
    scrollController = ScrollController();
    getHistory();
    super.initState();
  }

  @override
  void dispose() {
    inputQuestionController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: kBg300Color,
              ),
              child: Text(
                'Sessions',
                style: kWhiteText.copyWith(fontSize: 20, fontWeight: kSemiBold),
              ),
            ),
            for (Map<String, String> session in widget.sessions)
              ListTile(
                title: Text(session["session_name"]!),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        sessionId: session['session_id']!,
                        sessions: widget.sessions,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      backgroundColor: kBg500Color,
      appBar: AppBar(
        elevation: 1,
        shadowColor: Colors.white12,
        centerTitle: true,
        title: Text(
          "Elixir",
          style: kWhiteText.copyWith(fontSize: 20, fontWeight: kSemiBold),
        ),
        backgroundColor: kBg300Color,
        iconTheme: const IconThemeData(
          color: kWhiteColor,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.home_rounded)),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildChatList(),
            if (inProgress)
              LoadingWidget(
                inProgressResponse: inProgressResponse,
                inProgressData: inProgressData,
              ),
            // Align(
            //   alignment: Alignment.bottomRight,
            //   child: IconButton(
            //     onPressed: _scrollToBottom,
            //     icon: const Icon(Icons.arrow_downward_rounded),
            //   ),
            // ),
            TextInputWidget(
              textController: inputQuestionController,
              onSubmitted: () => _sendMessage(),
            )
          ],
        ),
      ),
    );
  }

  Expanded buildChatList() {
    return history.isNotEmpty
        ? Expanded(
            child: RawScrollbar(
              thumbVisibility: true,
              trackVisibility: true,
              thumbColor: kWhiteColor,
              trackColor: kBg100Color,
              radius: const Radius.circular(4),
              trackRadius: const Radius.circular(4),
              controller: scrollController,
              child: ListView.separated(
                controller: scrollController,
                separatorBuilder: (context, index) => const SizedBox(
                  height: 12,
                ),
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                    bottom: 20, left: 16, right: 16, top: 16),
                itemCount: history.length,
                itemBuilder: (BuildContext context, int index) {
                  final thishistory = history[index];
                  final isUser = thishistory['role'] == 'user';
                  String msg = "";
                  Map sources = {};
                  List images = [];

                  if (isUser) {
                    msg = thishistory['message']!;
                  } else {
                    final jsondata = jsonDecode(thishistory['message']!);
                    msg = jsondata['results'];
                    sources = jsondata['source'];
                    images = jsondata['images'] ?? jsondata['imgs'];
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      isUser
                          ? UserQuestionWidget(question: msg)
                          : AnswerWidget(
                              answer: msg,
                              sources: sources,
                              images: images,
                            ),
                    ],
                  );
                },
              ),
            ),
          )
        : Expanded(
            child: Center(
              child: Text(
                "No chat history, start asking questions!",
                style: kWhiteText,
              ),
            ),
          );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    });
  }

  void handleStremedResponse(Uri url) async {
    void onComplete() {
      addAiResponse(inProgressResponse, inProgressData);
      inProgress = false;
      inProgressResponse = "";
      inProgressData = {};
      _scrollToBottom();
      refresh();
    }

    try {
      final request = http.StreamedRequest('GET', url)..sink.close();
      final response = await request.send();
      bool firstResponse = true;

      response.stream.listen(
        (List<int> event) {
          if (!(event.length == 3 && event[1] == 13 && event[2] == 10)) {
            if (firstResponse) {
              firstResponse = false;

              inProgressData = jsonDecode(utf8.decode(event));
              //   debugPrint(inProgressData.toString());
            } else {
              inProgressResponse +=
                  utf8.decode(event).replaceAll("\r\n", "");
                  // debugPrint(event);

              //   debugPrint(inProgressResponse);
            }
            refresh();
          }
        },
        onDone: onComplete,
        onError: (error) {
          debugPrint('Error: $error');
          onComplete();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('Error: $e');
      onComplete();
    } finally {}
  }

  void _sendMessage() async {
    final question = inputQuestionController.text;
    inputQuestionController.clear();

    addUserQuestion(question);
    handleStremedResponse(getChatUrl(widget.sessionId, question));

    _scrollToBottom();
    inProgress = true;

    refresh();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }
}
