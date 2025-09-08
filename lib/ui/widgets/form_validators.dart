class FormValidators {
  static String? requiredField(String? v, {String fieldName = 'Campo'}) {
    if (v == null || v.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Correo es obligatorio';
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$');
    if (!emailRegex.hasMatch(v.trim())) return 'Correo no válido';
    return null;
  }

  static String? minLength(String? v, int min, {String fieldName = 'Campo'}) {
    if ((v ?? '').length < min) {
      return '$fieldName debe tener al menos $min caracteres';
    }
    return null;
  }
}
