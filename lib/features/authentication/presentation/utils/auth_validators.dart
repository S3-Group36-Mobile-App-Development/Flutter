class AuthValidators {
  AuthValidators._();

  static final RegExp _emailRegExp = RegExp(
    r'^[\w.\-+]+@([\w\-]+\.)+[\w\-]{2,}$',
  );

  static String? name(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Ingresa tu nombre.';
    }

    if (text.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres.';
    }

    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }

    if (!_emailRegExp.hasMatch(text)) {
      return 'Ingresa un correo válido (ejemplo@correo.com).';
    }

    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña.';
    }

    return null;
  }

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa una contraseña.';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }

    return null;
  }
}
