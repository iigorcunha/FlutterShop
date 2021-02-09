class AuthException implements Exception {
  static const Map<String, String> errors = {
    'EMAIL_EXISTS': 'O e-mail já existe',
    'OPERATION_NOT_ALLOWED': 'Esta operação não é permitida',
    'TOO_MANY_ATTEMPS_TRY_LATER':
        'Muitas tentativas de acesso tente mais tarde!',
    'EMAIL_NOT_FOUND': 'E-mail não encontrado',
    'INVALID_PASSWORD': 'A senha está invalida',
    'USER_DISABLED': 'O usuário está desabilitado',
  };

  final String key;

  AuthException(this.key);

  @override
  String toString() {
    if (errors.containsKey(key)) {
      return errors[key];
    } else {
      return 'Ocorreu um algum erro';
    }
  }
}
