import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  String _token;
  String _userId;

  Products([this._token, this._items = const [], this._userId]);

  // bool _showFavoriteOnly = false;

  List<Product> get items => [..._items];

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  int get itemsCount {
    return _items.length;
  }

  // void showFavoriteOnly() {
  //   _showFavoriteOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoriteOnly = false;
  //   notifyListeners();
  // }

  Future<void> loadProducts() async {
    final response =
        await http.get('${env['BASE_API_URL']}/products.json?auth=$_token');

    final favResponse = await http
        .get('${env['BASE_API_URL']}/userFavorites/$_userId.json?auth=$_token');

    final favMap = json.decode(favResponse.body);

    Map<String, dynamic> data = json.decode(response.body);
    _items.clear();
    if (data != null) {
      data.forEach((productId, productData) {
        final isFavorite = favMap == null ? false : favMap[productId] ?? false;
        _items.add(
          Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            imageURL: productData['imageURL'],
            isFavorite: isFavorite,
          ),
        );
      });
    }
    notifyListeners();

    return Future.value();
  }

  Future<void> addProduct(Product newProduct) async {
    final response = await http.post(
      '${env['BASE_API_URL']}/products.json?auth=$_token',
      body: json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'price': newProduct.price,
        'imageURL': newProduct.imageURL,
      }),
    );

    _items.add(
      Product(
        id: json.decode(response.body)['name'],
        title: newProduct.title,
        description: newProduct.description,
        price: newProduct.price,
        imageURL: newProduct.imageURL,
      ),
    );
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    if (product == null || product.id == null) {
      return;
    }

    final index = _items.indexWhere((prod) => prod.id == product.id);

    if (index >= 0) {
      await http.patch(
          "${env['BASE_API_URL']}/products/${product.id}.json?auth=$_token",
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageURL': product.imageURL,
          }));
      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> removeProduct(String id) async {
    final index = _items.indexWhere((prod) => prod.id == id);

    if (index >= 0) {
      final product = _items[index];

      _items.remove(product);
      notifyListeners();

      final response = await http.delete(
          "${env['BASE_API_URL']}/products/${product.id}.json?auth=$_token");

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw HttpException('Ocorreu um erro na exclusão do produto!');
      }
    }
  }
}
