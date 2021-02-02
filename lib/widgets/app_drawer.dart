import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_online/providers/auth.dart';
import 'package:toko_online/providers/user_provider.dart';
import 'package:toko_online/screens/order_screen.dart';
import 'package:toko_online/screens/user_product_screen.dart';
import 'package:toko_online/shared/value.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Consumer<UserProvider>(
            builder: (context, value, _) => UserAccountsDrawerHeader(
              accountName: Text(value.name ?? ""),
              accountEmail: Text(value.email ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Center(
                  child: Text(
                    getInitials(value.name),
                    style: TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ),
          ),
          MenuTile(
            title: "Belanja",
            icon: Icons.shopping_bag,
            onTapped: () {
              Navigator.of(context).pushReplacementNamed("/");
            },
          ),
          MenuTile(
            title: "Daftar Pesanan",
            icon: Icons.payment,
            onTapped: () {
              Navigator.of(context).pushReplacementNamed(OrderScreen.routeName);
            },
          ),
          MenuTile(
            title: "Kelola Produk",
            icon: Icons.edit,
            onTapped: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductScreen.routeName);
            },
          ),
          MenuTile(
            title: "Keluar",
            icon: Icons.logout,
            onTapped: () {
              showCupertinoDialog(
                context: context,
                builder: (ctx) => CupertinoAlertDialog(
                  title: Text("Perhatian!"),
                  content: Text("Apakah ingin keluar dari akun ini?"),
                  actions: [
                    CupertinoButton(
                        child: Text("Batal"),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        }),
                    CupertinoButton(
                        child: Text("Keluar"),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                          Provider.of<Auth>(context, listen: false).signOut();
                          Navigator.of(context).pushReplacementNamed("/");
                        }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function onTapped;

  MenuTile({
    @required this.title,
    @required this.icon,
    @required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(leading: Icon(icon), title: Text(title), onTap: onTapped),
        Divider(),
      ],
    );
  }
}
