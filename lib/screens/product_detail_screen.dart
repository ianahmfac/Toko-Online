import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_online/providers/auth.dart';
import 'package:toko_online/providers/cart_provider.dart';
import 'package:toko_online/providers/product.dart';
import 'package:toko_online/providers/product_provider.dart';
import 'package:toko_online/shared/theme.dart';
import 'package:toko_online/shared/value.dart';
import 'package:toko_online/widgets/badge.dart';

import 'cart_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  static const nameRoute = "/product-detail";

  @override
  Widget build(BuildContext context) {
    final String id = ModalRoute.of(context).settings.arguments;
    final product = Provider.of<ProductProvider>(
      context,
      listen: false, // Jika tidak ingin ada pembaharuan pada tampilan / rebuild
    ).findById(id);
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, cart, product, id),
              _buildSliverList(product),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
              color: mainColor,
              child: ChangeNotifierProvider.value(
                value: product,
                child: StackActionButton(cart: cart),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverList(Product product) {
    return SliverList(
      delegate: SliverChildListDelegate([
        SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                convertCurrency(product.price),
                style: productTitle.copyWith(fontSize: 20),
              ),
              SizedBox(
                height: 8,
              ),
              Text(product.title),
              Divider(
                color: Colors.grey,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "Deskripsi Produk",
                style: productTitle.copyWith(fontSize: 14),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                product.description,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text(
                "Penjual",
                style: productTitle.copyWith(fontSize: 14),
              ),
              SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: mainColor,
                    child: Text(getInitials(product.sellerName)),
                  ),
                  title: Text(product.sellerName),
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 500),
      ]),
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, CartProvider cart, Product product, String id) {
    return SliverAppBar(
      actions: [
        Badge(
          child: IconButton(
            // Child di luar builder tidak akan direbuild
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).pushNamed(CartScreen.routeName);
            },
          ),
          value: cart.totalItem.toString(),
        ),
      ],
      title: Text(product.title),
      expandedHeight: 300,
      pinned: true,
      excludeHeaderSemantics: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          height: 300,
          width: double.infinity,
          child: Hero(
            tag: id,
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class StackActionButton extends StatelessWidget {
  const StackActionButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final auth = Provider.of<Auth>(context, listen: false);
    return SafeArea(
      top: false,
      child: Row(
        children: [
          Expanded(
            child: OutlineButton(
              borderSide: BorderSide(color: Colors.white, width: 2),
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: () {
                cart.addCartItem(
                    product.id, product.title, product.price, product.imageUrl);
                showingSnackBar(
                  context,
                  "Berhasil menambahkan ${product.title} pada keranjang belanja",
                  "BATALKAN",
                  () {
                    if (cart.cartItems[product.id].quantity > 1)
                      cart.decreaseCartItem(product.id);
                    else
                      cart.removeItem(product.id);
                  },
                );
              },
              child: Text(
                "+ Keranjang",
                style: productTitle,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              (product.isFavorite) ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              product.setFavorite(auth.token, auth.userId);
            },
          )
        ],
      ),
    );
  }
}
