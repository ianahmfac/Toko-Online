import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_online/providers/product.dart';
import 'package:toko_online/providers/product_provider.dart';
import 'package:toko_online/screens/edit_product_screen.dart';
import 'package:toko_online/shared/theme.dart';

class UserProductItem extends StatelessWidget {
  final Product product;
  UserProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(product.imageUrl),
          ),
          title: Text(product.title),
          trailing: Container(
            width: 100,
            child: Row(
              children: [
                IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: mainColor,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                          EditProductScreen.routeName,
                          arguments: product.id);
                    }),
                IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _buildShowCupertinoDialog(context, scaffold);
                    }),
              ],
            ),
          ),
        ),
        Divider(),
      ],
    );
  }

  _buildShowCupertinoDialog(
      BuildContext context, ScaffoldState scaffold) async {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Konfirmasi Hapus Produk"),
          content: Text("Ingin Menghapus ${product.title} dari produk kamu?"),
          actions: [
            CupertinoButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoButton(
              child: Text("Hapus"),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await Provider.of<ProductProvider>(context, listen: false)
                      .deleteItem(product.id);
                } catch (e) {
                  scaffold.showSnackBar(SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
