import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:toko_online/models/http_exception.dart';
import 'package:toko_online/providers/product.dart';
import 'package:http/http.dart' as http;

// This provider for List of product
class ProductProvider with ChangeNotifier {
  final String authToken;
  final String userId;
  ProductProvider(this.authToken, this.userId, this._products);

  List<Product> _products = [];

  List<Product> get products {
    return [..._products];
  }

  List<Product> get favoriteProducts {
    return _products.where((product) => product.isFavorite).toList();
  }

  Product findById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }

  Future<void> fetchData([bool filterByUser = false]) async {
    String filterString = filterByUser
        ? 'orderBy="sellerId"&equalTo="$userId"'
        : ''; // Harus pakai petik 2 dalamnya
    var url =
        "https://toko-online-3a266-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString";
    try {
      final response = await http.get(url);
      final productMap = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> allProducts = [];
      if (productMap == null) {
        return null;
      }
      //* Get data favorit tiap user
      url =
          "https://toko-online-3a266-default-rtdb.firebaseio.com/user_favorites/$userId.json?auth=$authToken";
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      productMap.forEach((key, value) {
        allProducts.add(
          Product(
            id: key,
            title: value["title"],
            description: value["description"],
            price: value["price"],
            imageUrl: value["imageUrl"],
            sellerName: value["sellerName"],
            isFavorite:
                favoriteData == null ? false : favoriteData[key] ?? false,
          ),
        );
      });
      _products = allProducts;
      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> addItem(Product product, String name) async {
    final url =
        "https://toko-online-3a266-default-rtdb.firebaseio.com/products.json?auth=$authToken";
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            "sellerId": userId,
            "sellerName": name,
            "title": product.title,
            "description": product.description,
            "price": product.price,
            "imageUrl": product.imageUrl,
          },
        ),
      );
      final _newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        sellerName: product.sellerName,
      );
      _products.add(_newProduct);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateItem(String id, Product product) async {
    final index = _products.indexWhere((element) => element.id == id);
    if (index >= 0) {
      final url =
          "https://toko-online-3a266-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";
      await http.patch(
        url,
        body: json.encode({
          "title": product.title,
          "price": product.price,
          "description": product.description,
          "imageUrl": product.imageUrl,
        }),
      );
      _products[index] = product;
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    final url =
        "https://toko-online-3a266-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";
    final currentIndex = _products.indexWhere((element) => element.id == id);
    var currentProduct = _products[currentIndex];
    _products.removeWhere((element) => element.id == id);
    notifyListeners();
    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        _reinsertProduct(currentIndex, currentProduct);
        throw HttpException("Terjadi kesalahan. Tidak dapat menghapus produk.");
      }
      currentProduct = null;
    } catch (e) {
      _reinsertProduct(currentIndex, currentProduct);
      throw e.toString();
    }
  }

  void _reinsertProduct(int currentIndex, Product currentProduct) {
    _products.insert(currentIndex, currentProduct);
    notifyListeners();
  }
}
