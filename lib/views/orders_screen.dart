import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/orders.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/order_widget.dart';

class OrdersScreen extends StatelessWidget {
  Future<void> _refreshOrder(BuildContext context) {
    return Provider.of<Orders>(context, listen: false).loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Pedidos'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).loadOrders(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Consumer<Orders>(
                builder: (ctx, orders, child) => RefreshIndicator(
                      child: ListView.builder(
                        itemCount: orders.itemCount,
                        itemBuilder: (ctx, i) => OrderWidget(
                          orders.items[i],
                        ),
                      ),
                      onRefresh: () => _refreshOrder(context),
                    ));
          }
        },
      ),
    );
  }
}
