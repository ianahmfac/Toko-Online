import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:toko_online/helpers/custom_route.dart';
import 'package:toko_online/providers/auth.dart';
import 'package:toko_online/providers/cart_provider.dart';
import 'package:toko_online/providers/order_provider.dart';
import 'package:toko_online/providers/product_provider.dart';
import 'package:toko_online/providers/user_provider.dart';
import 'package:toko_online/screens/auth_screen.dart';
import 'package:toko_online/screens/cart_screen.dart';
import 'package:toko_online/screens/edit_product_screen.dart';
import 'package:toko_online/screens/order_screen.dart';
import 'package:toko_online/screens/product_detail_screen.dart';
import 'package:toko_online/screens/product_overview_screen.dart';
import 'package:toko_online/screens/splash_screen.dart';
import 'package:toko_online/screens/user_product_screen.dart';
import 'package:toko_online/shared/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting("id_ID", null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProxyProvider<Auth, ProductProvider>(
          create: null,
          update: (context, auth, previousProduct) => ProductProvider(
              auth.token,
              auth.userId,
              previousProduct == null ? [] : previousProduct.products),
        ),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProxyProvider<Auth, OrderProvider>(
          create: null,
          update: (context, auth, previousOrder) => OrderProvider(
              auth.token,
              auth.userId,
              previousOrder == null ? [] : previousOrder.productOrder),
        ),
        ChangeNotifierProxyProvider<Auth, UserProvider>(
          create: null,
          update: (context, auth, previous) =>
              UserProvider(auth.token, auth.userId),
        ),
      ],
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus.unfocus();
        },
        child: Consumer<Auth>(
          builder: (context, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Toko Online",
            theme: ThemeData(
              primarySwatch: mainColor,
              accentColor: accentColor,
              fontFamily: "Lato",
              // pageTransitionsTheme: PageTransitionsTheme(builders: {
              //   TargetPlatform.android: CustomPageTransitionBuilder(),
              //   TargetPlatform.iOS: CustomPageTransitionBuilder(),
              // }),
            ),
            home: auth.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoSignIn(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SplashScreen();
                      }
                      return AuthScreen();
                    },
                  ),
            routes: {
              ProductDetailScreen.nameRoute: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrderScreen.routeName: (ctx) => OrderScreen(),
              UserProductScreen.routeName: (ctx) => UserProductScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
            },
          ),
        ),
      ),
    );
  }
}
