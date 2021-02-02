import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_online/providers/product_provider.dart';
import 'package:toko_online/widgets/product_item.dart';

class ProductGrid extends StatelessWidget {
  final bool showFavs;

  ProductGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final data = Provider.of<ProductProvider>(context);
    final products = (showFavs) ? data.favoriteProducts : data.products;

    if (products.isEmpty) {
      return Center(
        child: Text("Empty Product!"),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await data.fetchData();
      },
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                orientation == Orientation.portrait ? 2 : 3, // have 2 columns
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7),
        itemBuilder: (context, index) {
          final product = products[index];
          return ChangeNotifierProvider.value(
            value:
                product, // Gunakan parameter value apabila bukan object provider yang di-listening
            child: ProductItem(),
          );
        },
      ),
    );
  }
}
