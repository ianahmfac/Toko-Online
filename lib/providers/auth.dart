import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toko_online/providers/user_provider.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _timeAuth;

  bool get isAuth => token != null;

  String get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String get userId => _userId;

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyC1NoQnLKLwTYFo5lArU2ZiQxKcpV28jx4";
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }),
      );
      final data = json.decode(response.body);
      if (data["error"] != null) {
        throw HttpException(data["error"]["message"]);
      }
      _token = data["idToken"];
      _userId = data["localId"];
      _expiryDate = DateTime.now().add(Duration(
        seconds: int.parse(data["expiresIn"]),
      ));
      _autoSignOut();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token": _token,
        "userId": _userId,
        "expiryDate": _expiryDate.toIso8601String(),
      });
      prefs.setString("userData", userData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    await _authenticate(email, password, "signUp");
    final user = UserProvider(_token, _userId);
    user.addingNewUser(email, name);
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _authenticate(email, password, "signInWithPassword");
  }

  Future<bool> tryAutoSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("userData")) {
      return false;
    }
    Map<String, Object> extractedUserData =
        json.decode(prefs.getString("userData"));
    final expiryDate = DateTime.parse(extractedUserData["expiryDate"]);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData["token"];
    _userId = extractedUserData["userId"];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoSignOut();
    return true;
  }

  Future<void> signOut() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_timeAuth != null) {
      _timeAuth.cancel();
      _timeAuth = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoSignOut() {
    if (_timeAuth != null) {
      _timeAuth.cancel();
    }
    final _timeExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _timeAuth = Timer(Duration(seconds: _timeExpiry), signOut);
  }
}
