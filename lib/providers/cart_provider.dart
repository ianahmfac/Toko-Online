import 'package:flutter/material.dart';

class Cart {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final int price;
  final String imageUrl;

  Cart({
    @required this.id,
    @required this.productId,
    @required this.title,
    @required this.quantity,
    @required this.price,
    @required this.imageUrl,
  });
}

class CartProvider with ChangeNotifier {
  Map<String, Cart> _cartItems = {};

  Map<String, Cart> get cartItems => {..._cartItems};

  int get totalItem {
    int total = 0;
    _cartItems.forEach((key, cart) {
      total += cart.quantity;
    });
    return total;
  }

  int get totalPrice {
    int total = 0;
    _cartItems.forEach((key, cart) {
      total += cart.price * cart.quantity;
    });

    return total;
  }

  void addCartItem(String productId, String title, int price, String imageUrl) {
    if (_cartItems.containsKey(productId)) {
      // Jika product id sudah ada pada cart items
      _cartItems.update(
        productId,
        (existingCart) => Cart(
          id: existingCart.id,
          productId: existingCart.productId,
          title: existingCart.title,
          quantity: existingCart.quantity + 1,
          price: existingCart.price,
          imageUrl: existingCart.imageUrl,
        ),
      );
    } else {
      _cartItems.putIfAbsent(
        productId,
        () => Cart(
          id: DateTime.now().toString(),
          productId: productId,
          title: title,
          quantity: 1, // Pertama kali ditambahkan
          price: price,
          imageUrl: imageUrl,
        ),
      ); // Menambahkan data jika product ID nya belum ada
    }
    notifyListeners();
  }

  void decreaseCartItem(String productId) {
    _cartItems.update(
      productId,
      (value) => Cart(
        id: value.id,
        productId: value.productId,
        title: value.title,
        quantity: value.quantity - 1,
        imageUrl: value.imageUrl,
        price: value.price,
      ),
    );
    notifyListeners();
  }

  void removeItem(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }

  void clear() {
    _cartItems = {};
    notifyListeners();
  }
}
