import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:toko_online/providers/order_provider.dart';
import 'package:toko_online/shared/theme.dart';
import 'package:toko_online/widgets/app_drawer.dart';
import 'package:toko_online/widgets/order_item.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = "/order-screen";

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Future _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture =
        Provider.of<OrderProvider>(context, listen: false).fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Daftar Pesanan"),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: SpinKitFadingCircle(
                color: accentColor,
              ));
            } else if (snapshot.error != null) {
              return Center(
                child: Text("An Error Occured"),
              );
            } else {
              return Consumer<OrderProvider>(
                builder: (context, order, child) => ListView.builder(
                  itemBuilder: (context, index) {
                    final itemOrder = order.productOrder[index];
                    return OrderItem(itemOrder);
                  },
                  itemCount: order.productOrder.length,
                ),
              );
            }
          },
        ));
  }
}
