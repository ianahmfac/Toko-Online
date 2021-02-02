import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_online/providers/auth.dart';
import 'package:toko_online/providers/cart_provider.dart';
import 'package:toko_online/providers/product.dart';
import 'package:toko_online/screens/product_detail_screen.dart';
import 'package:toko_online/shared/theme.dart';
import 'package:toko_online/shared/value.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(
      context,
      listen: false,
    );
    final auth = Provider.of<Auth>(context, listen: false);

    final cart = Provider.of<CartProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          ProductDetailScreen.nameRoute,
          arguments: product.id,
        );
      },
      child: Card(
        elevation: 16,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: GridTile(
          child: _buildImage(product),
          header: _buildFavoriteButton(product, auth),
          footer: _buildProductInformation(product, cart, context),
        ),
      ),
    );
  }

  Widget _buildImage(Product product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Hero(
        tag: product.id,
        child: FadeInImage(
          placeholder: AssetImage("assets/images/product-placeholder.png"),
          image: NetworkImage(product.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProductInformation(
      Product product, CartProvider cart, BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: GridTileBar(
        title: Text(
          product.title,
          style: productTitle,
        ),
        subtitle: Text(convertCurrency(product.price)),
        backgroundColor: Colors.black38,
        trailing: IconButton(
          icon: Icon(
            Icons.add_shopping_cart,
            color: accentColor,
          ),
          onPressed: () {
            cart.addCartItem(
              product.id,
              product.title,
              product.price,
              product.imageUrl,
            );
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
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(Product product, Auth auth) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => product.setFavorite(auth.token, auth.userId),
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white70,
          ),
          child: Consumer<Product>(
            builder: (context, product, child) => Icon(
              (product.isFavorite) ? Icons.favorite : Icons.favorite_border,
              color: accentColor,
            ),
          ),
        ),
      ),
    );
  }
}
