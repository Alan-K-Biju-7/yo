import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const Duration requestTimeout = Duration(seconds: 90);
  static const Duration loginTimeout = Duration(seconds: 12);
  static const String offlineAccessToken = 'rset-parent-offline-session';

  static const String serverOrigin = String.fromEnvironment(
    'SERVER_ORIGIN',
    defaultValue: 'https://rset-student-api.onrender.com',
  );
  static const String baseUrl = '$serverOrigin/api/mobile';

  static Map<String, String> _headers(String authToken) => {
        'Authorization': 'Bearer $authToken',
      };

  static bool isOfflineToken(String authToken) =>
      authToken == offlineAccessToken;

  static void _requireOnlineToken(String authToken) {
    if (isOfflineToken(authToken)) {
      throw Exception('Offline mode');
    }
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$serverOrigin/api/auth/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    ).timeout(loginTimeout);

    if (response.statusCode != 200) {
      throw Exception(response.statusCode == 401
          ? 'Invalid username or password'
          : 'Login failed (${response.statusCode})');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Uri fileUri(String fileUrl) => Uri.parse(
        fileUrl.startsWith('http') ? fileUrl : '$serverOrigin$fileUrl',
      );

  static Future<Map<String, dynamic>> getAttendanceByClass(
    String classCode,
    String authToken,
  ) async {
    _requireOnlineToken(authToken);
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/attendance/$classCode'),
            headers: _headers(authToken),
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load attendance');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> getMarks(
    String studentId,
    String classCode,
    String authToken,
  ) async {
    _requireOnlineToken(authToken);
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/marks/$classCode'),
            headers: _headers(authToken),
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load marks');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<dynamic>> getNotices(
    bool isExamNotice,
    String authToken,
  ) async {
    _requireOnlineToken(authToken);
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/notices?is_exam=$isExamNotice'),
            headers: _headers(authToken),
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load notices');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<dynamic>> getAllEvents(String authToken) async {
    _requireOnlineToken(authToken);
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/events'),
            headers: _headers(authToken),
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<dynamic>> getEventsByDate(
    String date,
    String authToken,
  ) async {
    _requireOnlineToken(authToken);
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/events?date=$date'),
            headers: _headers(authToken),
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
