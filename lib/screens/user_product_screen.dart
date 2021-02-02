import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:toko_online/providers/product_provider.dart';
import 'package:toko_online/shared/theme.dart';
import 'package:toko_online/widgets/app_drawer.dart';
import 'package:toko_online/widgets/user_product_item.dart';

import 'edit_product_screen.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = "/user-product-screen";

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductProvider>(context, listen: false).fetchData(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Produk Kamu"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) =>
            (snapshot.connectionState == ConnectionState.waiting)
                ? Center(
                    child: SpinKitFadingCircle(
                      color: accentColor,
                    ),
                  )
                : Consumer<ProductProvider>(
                    builder: (context, products, _) => RefreshIndicator(
                      onRefresh: () => _refreshProducts(context),
                      child: ListView.builder(
                        itemCount: products.products.length,
                        itemBuilder: (context, index) {
                          final product = products.products[index];
                          return UserProductItem(product);
                        },
                      ),
                    ),
                  ),
      ),
    );
  }
}
