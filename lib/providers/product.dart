import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final _baseUrl =
      'https://fluttershop-d968a-default-rtdb.firebaseio.com/userFavorites';
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageURL;
  bool isFavorite;

  Product({
    this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageURL,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite(String token, String userId) async {
    isFavorite = !isFavorite;
    notifyListeners();

    final response = await http.put('$_baseUrl/$userId/$id.json?auth=$token',
        body: json.encode(isFavorite));

    if (response.statusCode >= 400) {
      isFavorite = !isFavorite;
      notifyListeners();
    }
  }
}
