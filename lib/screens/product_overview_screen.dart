import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:toko_online/providers/cart_provider.dart';
import 'package:toko_online/providers/product_provider.dart';
import 'package:toko_online/providers/user_provider.dart';
import 'package:toko_online/screens/cart_screen.dart';
import 'package:toko_online/shared/theme.dart';
import 'package:toko_online/widgets/app_drawer.dart';
import 'package:toko_online/widgets/badge.dart';
import 'package:toko_online/widgets/product_grid.dart';

enum FilterOptions {
  Favorite,
  ShowAll,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _isFavoriteShowing = false;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    Provider.of<ProductProvider>(context, listen: false)
        .fetchData()
        .then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context, listen: false).fetchUser();
    return Scaffold(
      appBar: AppBar(
        title: (_isFavoriteShowing) ? Text("Favorite") : Text("Toko Online"),
        actions: [
          Consumer<CartProvider>(
            builder: (context, value, child) => Badge(
              child: child,
              value: value.totalItem.toString(),
            ),
            child: IconButton(
              // Child di luar builder tidak akan direbuild
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
          PopupMenuButton(
            onSelected: (FilterOptions value) {
              setState(() {
                switch (value) {
                  case FilterOptions.ShowAll:
                    _isFavoriteShowing = false;
                    break;
                  case FilterOptions.Favorite:
                    _isFavoriteShowing = true;
                    break;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: FilterOptions.ShowAll,
                child: ListTile(
                  leading: Icon(Icons.dashboard),
                  title: Text("Show All"),
                ),
              ),
              PopupMenuItem(
                value: FilterOptions.Favorite,
                child: ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text("Favorite"),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: accentColor,
              ),
            )
          : ProductGrid(_isFavoriteShowing),
    );
  }
}
