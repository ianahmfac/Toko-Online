import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final int price;
  final String imageUrl;
  final String sellerName;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    @required this.sellerName,
    this.isFavorite = false,
  });

  Future<void> setFavorite(String token, String userId) async {
    var oldValue = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url =
        "https://toko-online-3a266-default-rtdb.firebaseio.com/user_favorites/$userId/$id.json?auth=$token";
    try {
      final response = await http.put(
        url,
        body: json.encode(isFavorite),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldValue);
        throw HttpException(
            "Terjadi kesalahan. Tidak dapat menambahkan/menghapus produk pada favorite.");
      }
    } catch (e) {
      _setFavValue(oldValue);
      throw e.toString();
    }
  }

  void _setFavValue(bool oldValue) {
    isFavorite = oldValue;
    notifyListeners();
  }
}
