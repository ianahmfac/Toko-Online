import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:toko_online/providers/cart_provider.dart';
import 'package:toko_online/providers/order_provider.dart';
import 'package:toko_online/screens/order_screen.dart';
import 'package:toko_online/shared/theme.dart';
import 'package:toko_online/shared/value.dart';
import 'package:toko_online/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = "/cart-screen";
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Keranjang Belanja"),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemBuilder: (context, index) {
                final cartItem = cart.cartItems.values.toList()[index];
                return CartItem(
                  cartItem: cartItem,
                );
              },
              itemCount: cart.cartItems.length,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CardTotalOrder(),
            ),
          ],
        ),
      ),
    );
  }
}

class CardTotalOrder extends StatefulWidget {
  const CardTotalOrder({
    Key key,
  }) : super(key: key);

  @override
  _CardTotalOrderState createState() => _CardTotalOrderState();
}

class _CardTotalOrderState extends State<CardTotalOrder> {
  var isLoading = false;
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total:",
              style: productTitle.copyWith(fontSize: 20),
            ),
            SizedBox(
              width: 10,
            ),
            Chip(
              label: Text(
                convertCurrency(cart.totalPrice),
                style: productTitle.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              backgroundColor: mainColor,
            ),
            Spacer(),
            FlatButton(
              textColor: mainColor,
              onPressed: (cart.totalItem == 0)
                  ? null
                  : () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        await Provider.of<OrderProvider>(context, listen: false)
                            .addOrder(
                          cart.cartItems.values.toList(),
                          cart.totalPrice,
                        );
                        cart.clear();
                        Navigator.of(context)
                            .pushReplacementNamed(OrderScreen.routeName);
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Error"),
                            content: Text(e),
                            actions: [
                              FlatButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                      setState(() {
                        isLoading = false;
                      });
                    },
              child: isLoading
                  ? SizedBox(
                      height: 50,
                      width: 50,
                      child: SpinKitFadingCircle(
                        color: accentColor,
                      ),
                    )
                  : Text("ORDER NOW"),
            ),
          ],
        ),
      ),
    );
  }
}
