import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStore extends ChangeNotifier {
  SessionStore._(this._preferences, this._isSignedIn);

  static const _signedInKey = 'signed_in';

  final SharedPreferences _preferences;
  bool _isSignedIn;

  bool get isSignedIn => _isSignedIn;

  static Future<SessionStore> load() async {
    final preferences = await SharedPreferences.getInstance();
    return SessionStore._(
      preferences,
      preferences.getBool(_signedInKey) ?? false,
    );
  }

  Future<void> signIn() async {
    _isSignedIn = true;
    await _preferences.setBool(_signedInKey, true);
    notifyListeners();
  }

  Future<void> signOut() async {
    _isSignedIn = false;
    await _preferences.remove(_signedInKey);
    notifyListeners();
  }
}
