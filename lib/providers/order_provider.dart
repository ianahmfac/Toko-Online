import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:toko_online/models/http_exception.dart';
import 'package:toko_online/providers/cart_provider.dart';

import 'package:http/http.dart' as http;

class Order {
  final String id;
  final List<Cart> productCart;
  final int amount;
  final DateTime dateTime;

  Order({
    @required this.id,
    @required this.productCart,
    @required this.amount,
    @required this.dateTime,
  });
}

class OrderProvider with ChangeNotifier {
  final String authToken;
  final String userId;
  List<Order> _productOrder = [];

  OrderProvider(this.authToken, this.userId, this._productOrder);

  List<Order> get productOrder => [..._productOrder];

  Future<void> fetchOrders() async {
    final url =
        "https://toko-online-3a266-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";
    final response = await http.get(url);
    final List<Order> dataFetched = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      dataFetched.add(Order(
        id: orderId,
        productCart: (orderData["product_cart"] as List)
            .map((cart) => Cart(
                  id: cart["id"],
                  productId: cart["product_id"],
                  title: cart["title"],
                  quantity: cart["quantity"],
                  price: cart["price"],
                  imageUrl: cart["imageUrl"],
                ))
            .toList(),
        amount: orderData["amount"],
        dateTime: DateTime.parse(orderData["date_time"]),
      ));
    });
    _productOrder = dataFetched.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<Cart> productCart, int amount) async {
    final url =
        "https://toko-online-3a266-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";
    final dateTime = DateTime.now();
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "amount": amount,
          "date_time": dateTime.toIso8601String(),
          "product_cart": productCart
              .map(
                (pc) => {
                  "id": pc.id,
                  "product_id": pc.productId,
                  "title": pc.title,
                  "quantity": pc.quantity,
                  "price": pc.price,
                  "imageUrl": pc.imageUrl,
                },
              )
              .toList(),
        }),
      );
      _productOrder.insert(
        0,
        Order(
          id: json.decode(response.body)["name"],
          productCart: productCart,
          amount: amount,
          dateTime: dateTime,
        ),
      );
      notifyListeners();
    } catch (e) {
      throw HttpException("Terjadi kesalahan. Pesanan tidak dapat diproses.")
          .toString();
    }
  }
}
