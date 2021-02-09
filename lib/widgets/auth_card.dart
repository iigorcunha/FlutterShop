import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/firebase_exception.dart';
import 'package:shop/providers/auth.dart';

enum AuthMode {
  Signup,
  Login,
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  GlobalKey<FormState> _form = GlobalKey();
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  final _passwordController = TextEditingController();
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ocorreu um erro'),
        content: Text(msg),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_form.currentState.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _form.currentState.save();

    Auth auth = Provider.of<Auth>(context, listen: false);

    try {
      if (_authMode == AuthMode.Login) {
        await auth.login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        await auth.signup(
          _authData['email'],
          _authData['password'],
        );
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog('Ocorreu um erro inesperado');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else if (_authMode == AuthMode.Signup) {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10.0,
        ),
      ),
      child: Container(
        height: _authMode == AuthMode.Login ? 270 : 330,
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'E-mail',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value.isEmpty || !value.contains('@')) {
                    return "Informe um e-mail valido";
                  }
                  return null;
                },
                onSaved: (value) => _authData['email'] = value,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Senha',
                ),
                obscureText: true,
                validator: (value) {
                  if (value.isEmpty || value.length < 5) {
                    return "Informe uma senha valido";
                  }
                  return null;
                },
                onSaved: (value) => _authData['password'] = value,
              ),
              if (_authMode == AuthMode.Signup)
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                  ),
                  obscureText: true,
                  controller: _passwordController,
                  validator: _authMode == AuthMode.Signup
                      ? (value) {
                          if (value != _passwordController.text) {
                            return "As senhas são diferentes!";
                          }
                          return null;
                        }
                      : null,
                ),
              SizedBox(
                height: 20,
              ),
              if (_isLoading)
                CircularProgressIndicator()
              else
                RaisedButton(
                  onPressed: _submit,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).primaryTextTheme.button.color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                      _authMode == AuthMode.Login ? 'ENTRAR' : 'REGISTRAR'),
                ),
              FlatButton(
                onPressed: _switchAuthMode,
                child: Text(
                  _authMode == AuthMode.Login
                      ? 'ALTERNAR P/ REGISTRAR'
                      : 'ALTERNAR P/ LOGIN',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
