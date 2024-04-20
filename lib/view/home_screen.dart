import 'package:elixir/components/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:elixir/theme.dart';
import 'package:elixir/api.dart';
import 'package:elixir/view/chat_screen.dart';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> sessions = [];
  final ScrollController _scrollController = ScrollController();
  bool fileUploading = false;

  getSessions() {
    listSessions().then((value) {
      sessions = value;
      refresh();
    });
  }

  removeSession(String sessionId) {
    sessions.removeWhere((element) => element['session_id'] == sessionId);
    refresh();
  }

  @override
  void initState() {
    super.initState();
    getSessions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  InkWell getCard(String name, double width, double height, IconData icon,
      void Function() pressed) {
    return InkWell(
      onTap: pressed,
      splashColor: kBg500Color,
      focusColor: kBg500Color,
      hoverColor: kBg500Color,
      highlightColor: kBg500Color,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(height * 0.01),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          color: kBg300Color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Icon(
                icon,
                size: height * 0.25,
                color: kWhiteColor,
              ),
            ),
            Text(
              name,
              style: kWhiteText.copyWith(fontSize: 20, fontWeight: kMedium),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (fileUploading) {
      return getMainLoading();
    }

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final cardWidth = width * 0.3;

    return Scaffold(
      backgroundColor: kBg500Color,
      body: Column(
        children: [
          SizedBox(
            height: height * 0.05,
          ),
          Center(
            child: Text(
              'Elixir',
              style: kWhiteText.copyWith(
                  fontSize: height * 0.1, fontWeight: kBold),
            ),
          ),
          SizedBox(
            height: height * 0.05,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              getCard("Chat with PDF", cardWidth, height * 0.2, Icons.file_open,
                  () async {
                final file = await FilePicker.platform.pickFiles(
                  allowMultiple: false,
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'txt'],
                  withData: true,
                );
                if (file != null) {
                  String? sessionName = await showAskSessionName();
                  if (sessionName != null && sessionName.isNotEmpty) {
                    final newCreated = await newSession(sessionName);
                    sessions.add(newCreated);
                    fileUploading = true;
                    refresh();
                    uploadFile(
                      newCreated["session_id"]!,
                      file.names.first!,
                      file.files.first.bytes!,
                    ).then((value) {
                      fileUploading = false;
                      refresh();
                      if (value != 200) {
                        removeSession(newCreated['session_id']!);
                        debugPrint('Error uploading file');
                        return;
                      }
                      gotoChatScreen(newCreated['session_id']!, sessions);
                    });
                  }
                }
              }),
              getCard(
                "Chat without PDF",
                cardWidth,
                height * 0.2,
                Icons.chat,
                () async {
                  String? sessionName = await showAskSessionName();
                  if (sessionName != null && sessionName.isNotEmpty) {
                    createNewsessionAndGo(sessionName);
                  }
                },
              ),
              getCard(
                "Set the URL",
                cardWidth,
                height * 0.2,
                Icons.link,
                () async {
                  String? url = await askURL();
                  if (url != null && url.isNotEmpty) {
                    setBaseUrl(url);
                    getSessions();
                  }
                },
              ),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          if (sessions.isNotEmpty)
            Text(
              'Sessions',
              style: kWhiteText.copyWith(fontSize: 30, fontWeight: kBold),
            ),
          if (sessions.isNotEmpty)
            const SizedBox(
              height: 10,
            ),
          if (sessions.isNotEmpty)
            SizedBox(
              height: height * 0.35,
              width: width * 0.4,
              child: RawScrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                thumbColor: kWhiteColor,
                trackColor: kBg100Color,
                radius: const Radius.circular(4),
                trackRadius: const Radius.circular(4),
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    controller: _scrollController,
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
                            splashColor: kBg500Color,
                            focusColor: kBg500Color,
                            hoverColor: kBg500Color,
                            title: Text(sessions[index]['session_name']!),
                            titleTextStyle: kWhiteText.copyWith(
                              fontSize: 20,
                              fontWeight: kMedium,
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                showDeleteConfirmationDialog(
                                  sessions[index]['session_id']!,
                                );
                              },
                              icon: const Icon(Icons.delete_rounded),
                              hoverColor: Colors.red,
                              color: kWhiteColor,
                            ),
                            onTap: () {
                              gotoChatScreen(
                                sessions[index]['session_id']!,
                                sessions,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void createNewsessionAndGo(String sessionName) {
    newSession(sessionName).then((value) {
      sessions.add(value);
      refresh();
      gotoChatScreen(value['session_id']!, sessions);
    });
  }

  void gotoChatScreen(
      String sessionID, List<Map<String, String>> sessionsList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          sessionId: sessionID,
          sessions: sessionsList,
        ),
      ),
    );
  }

  Future<String?> showAskSessionName() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        return AlertDialog(
          title: const Text('Enter name for session'),
          content: TextField(
            onChanged: (value) {
              name = value;
            },
            onSubmitted: (value) => Navigator.of(context).pop(value),
            decoration: const InputDecoration(
              hintText: 'Enter name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop(name);
              },
            ),
          ],
        );
      },
    );
  }

  Future<String?> askURL() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        return AlertDialog(
          title: const Text('Enter URL'),
          content: TextField(
            controller: TextEditingController(text: baseUrl),
            onChanged: (value) {
              name = value;
            },
            onSubmitted: (value) => Navigator.of(context).pop(value),
            decoration: const InputDecoration(
              hintText: 'Enter URL',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              child: const Text('Set'),
              onPressed: () {
                Navigator.of(context).pop(name);
              },
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmationDialog(String sessionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Are you sure you want to delete this session?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteSessionById(sessionId).then((value) {
                  removeSession(sessionId);
                  Navigator.of(context).pop();
                });
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Scaffold getMainLoading() {
    return Scaffold(
      backgroundColor: kBg500Color,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: getPackman(),
            ),
            const SizedBox(height: 20),
            Text(
              'Processing file...',
              style: kWhiteText.copyWith(
                fontWeight: kRegular,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }
}
