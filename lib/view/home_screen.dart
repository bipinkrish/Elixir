import 'package:flutter/material.dart';
import 'package:elixir/theme.dart';
import 'package:elixir/api.dart';
import 'package:elixir/view/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> sessions = [];
  final ScrollController _scrollController = ScrollController();

  getSessions() {
    listSessions().then((value) {
      setState(() {
        sessions = value;
      });
    });
  }

  removeSession(String sessionId) {
    setState(() {
      sessions.removeWhere((element) => element['session_id'] == sessionId);
    });
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

  InkWell getCard(
      String name, double width, double height, void Function() pressed) {
    return InkWell(
      onTap: pressed,
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
                Icons.chat_bubble,
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
              getCard("Chat with PDF", width * 0.4, height * 0.2, () {}),
              getCard("Chat without PDF", width * 0.4, height * 0.2, () async {
                String? sessionName = await showAskSessionName();
                if (sessionName != null) {
                  newSession(sessionName).then((value) {
                    setState(() {
                      sessions.add(value);
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          sessionId: value['session_id']!,
                          sessions: sessions,
                        ),
                      ),
                    );
                  });
                }
              }),
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
                            hoverColor: kBg100Color,
                            title: Text(sessions[index]['session_name']!),
                            titleTextStyle: kWhiteText.copyWith(
                              fontSize: 20,
                              fontWeight: kMedium,
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                showDeleteConfirmationDialog(
                                    sessions[index]['session_id']!);
                              },
                              icon: const Icon(Icons.delete_rounded),
                              hoverColor: Colors.red,
                              color: kWhiteColor,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    sessionId: sessions[index]['session_id']!,
                                    sessions: sessions,
                                  ),
                                ),
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

  showDeleteConfirmationDialog(String sessionId) {
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
}
