import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStore extends ChangeNotifier {
  SessionStore._(
    this._preferences,
    this._isSignedIn,
    this._accessToken,
    this._studentId,
  );

  static const _signedInKey = 'signed_in';
  static const _accessTokenKey = 'access_token';
  static const _studentIdKey = 'student_id';

  final SharedPreferences _preferences;
  bool _isSignedIn;
  String? _accessToken;
  String? _studentId;

  bool get isSignedIn => _isSignedIn;
  String? get accessToken => _accessToken;
  String? get studentId => _studentId;

  static Future<SessionStore> load() async {
    final preferences = await SharedPreferences.getInstance();
    final accessToken = preferences.getString(_accessTokenKey);
    final studentId = preferences.getString(_studentIdKey);
    return SessionStore._(
      preferences,
      (preferences.getBool(_signedInKey) ?? false) &&
          accessToken != null &&
          studentId != null,
      accessToken,
      studentId,
    );
  }

  Future<void> signIn({
    required String accessToken,
    required String studentId,
  }) async {
    _isSignedIn = true;
    _accessToken = accessToken;
    _studentId = studentId;
    await _preferences.setBool(_signedInKey, true);
    await _preferences.setString(_accessTokenKey, accessToken);
    await _preferences.setString(_studentIdKey, studentId);
    notifyListeners();
  }

  Future<void> signOut() async {
    _isSignedIn = false;
    _accessToken = null;
    _studentId = null;
    await _preferences.remove(_signedInKey);
    await _preferences.remove(_accessTokenKey);
    await _preferences.remove(_studentIdKey);
    notifyListeners();
  }
}
