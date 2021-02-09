import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';

class ProductFormScreen extends StatefulWidget {
  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageURLFocusNode = FocusNode();
  final _imageURLController = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageURLFocusNode.addListener(_updateImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_formData.isEmpty) {
      final product = ModalRoute.of(context).settings.arguments as Product;

      if (product != null) {
        _formData['id'] = product.id;
        _formData['title'] = product.title;
        _formData['description'] = product.description;
        _formData['price'] = product.price;
        _formData['imageURL'] = product.imageURL;

        _imageURLController.text = _formData['imageURL'];
      } else {
        _formData['price'] = '';
      }
    }
  }

  void _updateImage() {
    if (isvalidImageURL(_imageURLController.text)) {
      setState(() {});
    }
  }

  bool isvalidImageURL(String url) {
    bool isValidProtocol = url.toLowerCase().startsWith('http://') ||
        url.toLowerCase().startsWith('https://');

    bool endsWithPng = url.toLowerCase().endsWith('.png');
    bool endsWithJpg = url.toLowerCase().endsWith('.jpg');
    bool endsWithJpeg = url.toLowerCase().endsWith('.jpeg');

    return (isValidProtocol) && (endsWithPng || endsWithJpg || endsWithJpeg);
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageURLFocusNode.removeListener(_updateImage);
    _imageURLFocusNode.dispose();
  }

  Future<void> _saveForm() async {
    bool isValid = _form.currentState.validate();

    if (!isValid) {
      return;
    }

    _form.currentState.save();

    final newProduct = Product(
      id: _formData['id'],
      title: _formData['title'],
      description: _formData['description'],
      price: _formData['price'],
      imageURL: _formData['imageURL'],
    );

    setState(() {
      _isLoading = true;
    });

    final products = Provider.of<Products>(context, listen: false);

    try {
      if (_formData['id'] == null) {
        await products.addProduct(newProduct);
        setState(() {
          _isLoading = false;
        });
      } else {
        await products.updateProduct(newProduct);
      }
      Navigator.of(context).pop();
    } catch (error) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ocorreu um erro'),
          content: Text('Ocorreu um erro ao salvar o produto!'),
          actions: [
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Ok'),
            )
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulário de produto'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Título',
                      ),
                      initialValue: _formData['title'],
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) => _formData['title'] = value,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.trim().isEmpty) {
                          return 'Informe um título válido!!';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Preço',
                      ),
                      initialValue: _formData['price'].toString(),
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFocusNode,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) =>
                          _formData['price'] = double.parse(value),
                      validator: (value) {
                        bool isEmpty = value.trim().isEmpty;
                        var newPrice = double.tryParse(value);
                        bool isInvalid = newPrice == null || newPrice <= 0;
                        if (isEmpty || isInvalid) {
                          return 'Informe um preço!!';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                      ),
                      initialValue: _formData['description'],
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) => _formData['description'] = value,
                      validator: (value) {
                        if (value.trim().isEmpty) {
                          return 'Informe uma descrição!!';
                        }

                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'URL da imagem',
                            ),
                            controller: _imageURLController,
                            keyboardType: TextInputType.url,
                            focusNode: _imageURLFocusNode,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) => _formData['imageURL'] = value,
                            validator: (value) {
                              bool emptyUrl = value.trim().isEmpty;
                              bool invalidUrl = !isvalidImageURL(value);
                              if (emptyUrl || invalidUrl) {
                                return 'Informe uma URL válida!!';
                              }

                              return null;
                            },
                          ),
                        ),
                        Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.only(
                              top: 8.0,
                              left: 10.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: _imageURLController.text.isEmpty
                                ? Text('Informe a URL')
                                : Image.network(
                                    _imageURLController.text,
                                    fit: BoxFit.cover,
                                  ))
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
