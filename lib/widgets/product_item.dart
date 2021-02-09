import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/utils/app_routes.dart';

class ProductItem extends StatelessWidget {
  final Product product;

  ProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageURL),
      ),
      title: Text(product.title),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.PRODUCT_FORM,
                  arguments: product,
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              color: Theme.of(context).errorColor,
              onPressed: () {
                return showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Excluir Produto'),
                    content: Text(
                        'Você gostaria realmente de excluir esse produto?'),
                    actions: [
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text('Cancelar')),
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text(
                            'Excluir',
                            style: TextStyle(
                              color: Theme.of(context).errorColor,
                            ),
                          )),
                    ],
                  ),
                ).then((_) async {
                  try {
                    await Provider.of<Products>(context, listen: false)
                        .removeProduct(product.id);
                  } on HttpException catch (error) {
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Text(error.toString()),
                      ),
                    );
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
