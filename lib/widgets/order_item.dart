import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toko_online/providers/cart_provider.dart';
import 'package:toko_online/providers/order_provider.dart';
import 'package:toko_online/shared/theme.dart';
import 'package:toko_online/shared/value.dart';

class OrderItem extends StatelessWidget {
  final Order orderItem;
  OrderItem(this.orderItem);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: _buildListItem(),
      ),
    );
  }

  Widget _buildListItem() {
    return ExpansionTile(
      leading: Container(
        width: 35,
        height: double.infinity,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(shape: BoxShape.circle, color: mainColor),
        child: Icon(Icons.payment, color: Colors.white),
      ),
      title: Text(convertCurrency(orderItem.amount)),
      subtitle: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 14,
            color: Colors.grey,
          ),
          SizedBox(width: 4),
          Text(
            DateFormat("d MMMM yyyy - H:mm", "id_ID")
                .format(orderItem.dateTime),
          ),
        ],
      ),
      children: orderItem.productCart
          .map(
            (product) => _buildExpandedItem(product),
          )
          .toList(),
    );
  }

  Widget _buildExpandedItem(Cart product) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
            height: double.infinity,
            width: 75,
          ),
          title: Text(
            product.title,
          ),
          subtitle: Text("${product.quantity} barang"),
          trailing: Text(
            convertCurrency(product.price),
            style: productTitle.copyWith(color: mainColor),
          ),
        ),
      ),
    );
  }
}
