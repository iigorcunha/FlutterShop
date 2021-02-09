import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shop/providers/cart.dart';

import 'package:http/http.dart' as http;

class Order {
  final String id;
  final double total;
  final List<CartItem> products;
  final DateTime date;

  Order({
    this.id,
    this.total,
    this.products,
    this.date,
  });
}

class Orders with ChangeNotifier {
  String _token;
  String _userId;

  List<Order> _items = [];

  Orders([this._token, this._userId, this._items = const []]);

  List<Order> get items {
    return [..._items];
  }

  int get itemCount {
    return _items.length;
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final response = await http.post(
        '${env['BASE_API_URL']}/orders/$_userId.json?auth=$_token',
        body: json.encode({
          'total': cart.totalAmount,
          'date': date.toIso8601String(),
          'products': cart.items.values
              .map((cartItem) => {
                    'id': cartItem.id,
                    'productId': cartItem.productId,
                    'title': cartItem.title,
                    'quantity': cartItem.quantity,
                    'price': cartItem.price,
                  })
              .toList(),
        }));

    _items.insert(
      0,
      Order(
        id: json.decode(response.body)['name'],
        total: double.parse(cart.totalAmount),
        date: date,
        products: cart.items.values.toList(),
      ),
    );

    notifyListeners();
  }

  Future<void> loadOrders() async {
    List<Order> loadedItems = [];
    final response = await http
        .get('${env['BASE_API_URL']}/orders/$_userId.json?auth=$_token');
    Map<String, dynamic> data = json.decode(response.body);

    loadedItems.clear();
    if (data != null) {
      data.forEach((orderId, orderData) {
        loadedItems.add(
          Order(
            id: orderId,
            total: double.parse(orderData['total']),
            date: DateTime.parse(orderData['date']),
            products: (orderData['products'] as List<dynamic>).map(
              (item) {
                return CartItem(
                  id: item['id'],
                  productId: item['productId'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price'],
                );
              },
            ).toList(),
          ),
        );
      });
      notifyListeners();
    }

    _items = loadedItems.reversed.toList();

    return Future.value();
  }
}
