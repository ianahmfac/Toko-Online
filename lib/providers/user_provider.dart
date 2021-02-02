import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class User {
  final String id;
  final String email;
  final String name;

  User({
    @required this.id,
    @required this.email,
    @required this.name,
  });
}

class UserProvider with ChangeNotifier {
  final String authToken;
  final String userId;
  UserProvider(this.authToken, this.userId);

  String _name, _email;
  String get name => _name;
  String get email => _email;

  Future<void> addingNewUser(String email, String name) async {
    final url =
        "https://toko-online-3a266-default-rtdb.firebaseio.com/users/$userId.json?auth=$authToken";
    await http.put(
      url,
      body: json.encode({
        "email": email,
        "name": name,
      }),
    );
  }

  Future<void> fetchUser() async {
    final url =
        "https://toko-online-3a266-default-rtdb.firebaseio.com/users/$userId.json?auth=$authToken";
    final response = await http.get(url);
    final user = json.decode(response.body);
    _name = user["name"];
    _email = user["email"];
    notifyListeners();
  }
}
