import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

const String baseUrl =
    "https://3fb2-36-255-87-134.ngrok-free.app"; // "http://192.168.1.13:8000";

Future<Map<String, String>> newSession(String sessionName) async {
  final response = await http.get(
    Uri.parse('$baseUrl/new_session?session_name=$sessionName'),
  );
  final Map responseJson = jsonDecode(response.body);
  final Map<String, String> data = {};

  responseJson.forEach((key, value) {
    data[key.toString()] = value.toString();
  });
  return data;
}

Future<List<Map<String, String>>> listSessions() async {
  final response = await http.get(Uri.parse('$baseUrl/list_sessions'));
  final List<dynamic> sessionsJson = jsonDecode(response.body);
  final List<Map<String, String>> sessions = [];

  for (var session in sessionsJson) {
    final Map<String, String> sessionMap = {};
    session.forEach((key, value) {
      sessionMap[key.toString()] = value.toString();
    });
    sessions.add(sessionMap);
  }

  return sessions;
}

Future<Map<String, dynamic>> deleteSessionById(String sessionId) async {
  final response = await http
      .get(Uri.parse('$baseUrl/delete_session_by_id?session_id=$sessionId'));
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> uploadFile(
    String sessionId, String fileName, Uint8List content) async {
  final response = await http.post(
    Uri.parse('$baseUrl/upload_file'),
    body: {
      "session_id_or_name": sessionId,
      "filename": fileName,
      "file": content.toString(),
    },
  );
  return jsonDecode(response.body);
}

Future<List<Map<String, String>>> getChatHistory(String sessionId) async {
  final response = await http.get(
      Uri.parse('$baseUrl/get_chat_history?session_id_or_name=$sessionId'));
  final List<dynamic> sessionsJson = jsonDecode(response.body);
  final List<Map<String, String>> history = [];

  for (var session in sessionsJson) {
    final Map<String, String> sessionMap = {};
    session.forEach((key, value) {
      sessionMap[key.toString()] = value.toString();
    });
    history.add(sessionMap);
  }

  return history;
}

String getImageUrl(String fileId) {
  return '$baseUrl/get_image?file_id=$fileId';
}

Uri getChatUrl(String sessionID, String message) {
  return Uri.parse(
      '$baseUrl/chat_with_file?session_id_or_name=$sessionID&message=$message');
}
