import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_online/providers/cart_provider.dart';
import 'package:toko_online/shared/theme.dart';
import 'package:toko_online/shared/value.dart';

class CartItem extends StatelessWidget {
  const CartItem({
    Key key,
    @required this.cartItem,
  }) : super(key: key);

  final Cart cartItem;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Dismissible(
      key: ValueKey(cartItem.id),
      background: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        color: Colors.red,
        child: Icon(
          Icons.delete,
          size: 40,
          color: Colors.white,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text("Hapus Item"),
              content: Text("Apakah ingin mengapus item ini?"),
              actions: [
                CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text("No")),
                CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text("Yes")),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        cart.removeItem(cartItem.productId);
      },
      child: Card(
        margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Image.network(
                cartItem.imageUrl,
                height: 100,
                width: 75,
                fit: BoxFit.cover,
              ),
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      convertCurrency(cartItem.price * cartItem.quantity),
                      style: productTitle,
                    ),
                    _buildItemCounter(cart),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCounter(CartProvider cart) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildMinusIcon(cart),
        SizedBox(
          width: 8,
        ),
        Text(
          cartItem.quantity.toString(),
          style: productTitle,
        ),
        SizedBox(
          width: 8,
        ),
        _buildPlusIcon(cart),
      ],
    );
  }

  Widget _buildPlusIcon(CartProvider cart) {
    return GestureDetector(
      onTap: () {
        cart.addCartItem(
          cartItem.productId,
          cartItem.title,
          cartItem.price,
          cartItem.imageUrl,
        );
      },
      child: Container(
        height: 20,
        width: 20,
        decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor),
        child: Icon(
          Icons.add,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildMinusIcon(CartProvider cart) {
    return GestureDetector(
      onTap: (cartItem.quantity == 1)
          ? () {
              cart.removeItem(cartItem.productId);
            }
          : () {
              cart.decreaseCartItem(cartItem.productId);
            },
      child: Container(
        height: 20,
        width: 20,
        decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor),
        child: Icon(
          Icons.remove,
          size: 16,
        ),
      ),
    );
  }
}
