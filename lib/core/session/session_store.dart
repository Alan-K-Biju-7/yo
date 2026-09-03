import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/api_service.dart';

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
  bool _upgradeRunning = false;
  Timer? _upgradeRetryTimer;

  bool get isSignedIn => _isSignedIn;
  String? get accessToken => _accessToken;
  String? get studentId => _studentId;

  static Future<SessionStore> load() async {
    final preferences = await SharedPreferences.getInstance();
    final accessToken = preferences.getString(_accessTokenKey);
    final studentId = preferences.getString(_studentIdKey);
    final store = SessionStore._(
      preferences,
      (preferences.getBool(_signedInKey) ?? false) &&
          accessToken != null &&
          studentId != null,
      accessToken,
      studentId,
    );
    store.startOnlineUpgrade();
    return store;
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
    _upgradeRetryTimer?.cancel();
    _upgradeRetryTimer = null;
    _upgradeRunning = false;
    _isSignedIn = false;
    _accessToken = null;
    _studentId = null;
    await _preferences.remove(_signedInKey);
    await _preferences.remove(_accessTokenKey);
    await _preferences.remove(_studentIdKey);
    notifyListeners();
  }

  void startOnlineUpgrade() {
    if (_upgradeRunning ||
        !_isSignedIn ||
        _studentId != 'U2503208' ||
        _accessToken == null ||
        !ApiService.isOfflineToken(_accessToken!)) {
      return;
    }
    _upgradeRunning = true;
    unawaited(_tryOnlineUpgrade());
  }

  Future<void> _tryOnlineUpgrade() async {
    try {
      final result = await ApiService.login('U2503208', '08032007');
      if (!_isSignedIn || _studentId != 'U2503208') {
        _upgradeRunning = false;
        return;
      }
      await signIn(
        accessToken: result['access_token'] as String,
        studentId: 'U2503208',
      );
      _upgradeRunning = false;
    } catch (_) {
      if (_isSignedIn &&
          _studentId == 'U2503208' &&
          _accessToken != null &&
          ApiService.isOfflineToken(_accessToken!)) {
        _upgradeRetryTimer?.cancel();
        _upgradeRetryTimer = Timer(
          const Duration(seconds: 30),
          () => unawaited(_tryOnlineUpgrade()),
        );
      } else {
        _upgradeRunning = false;
      }
    }
  }
}
