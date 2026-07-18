class BrazilDocuments {
  const BrazilDocuments._();

  static String digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  static String formatCpfCnpj(String value) {
    final raw = digits(value);
    if (raw.length <= 11) {
      final limited = raw.substring(0, raw.length.clamp(0, 11));
      if (limited.length <= 3) return limited;
      if (limited.length <= 6) {
        return '${limited.substring(0, 3)}.${limited.substring(3)}';
      }
      if (limited.length <= 9) {
        return '${limited.substring(0, 3)}.${limited.substring(3, 6)}.${limited.substring(6)}';
      }
      return '${limited.substring(0, 3)}.${limited.substring(3, 6)}.${limited.substring(6, 9)}-${limited.substring(9)}';
    }
    final limited = raw.substring(0, raw.length.clamp(0, 14));
    if (limited.length <= 2) return limited;
    if (limited.length <= 5) {
      return '${limited.substring(0, 2)}.${limited.substring(2)}';
    }
    if (limited.length <= 8) {
      return '${limited.substring(0, 2)}.${limited.substring(2, 5)}.${limited.substring(5)}';
    }
    if (limited.length <= 12) {
      return '${limited.substring(0, 2)}.${limited.substring(2, 5)}.${limited.substring(5, 8)}/${limited.substring(8)}';
    }
    return '${limited.substring(0, 2)}.${limited.substring(2, 5)}.${limited.substring(5, 8)}/${limited.substring(8, 12)}-${limited.substring(12)}';
  }

  static bool isValidCpf(String value) {
    final cpf = digits(value);
    if (cpf.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return false;
    }
    var sum = 0;
    for (var index = 0; index < 9; index++) {
      sum += int.parse(cpf[index]) * (10 - index);
    }
    var digit = (sum * 10) % 11;
    if (digit == 10) digit = 0;
    if (digit != int.parse(cpf[9])) return false;

    sum = 0;
    for (var index = 0; index < 10; index++) {
      sum += int.parse(cpf[index]) * (11 - index);
    }
    digit = (sum * 10) % 11;
    if (digit == 10) digit = 0;
    return digit == int.parse(cpf[10]);
  }

  static bool isValidCnpj(String value) {
    final cnpj = digits(value);
    if (cnpj.length != 14 || RegExp(r'^(\d)\1{13}$').hasMatch(cnpj)) {
      return false;
    }
    final firstWeights = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    final secondWeights = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int checkDigit(List<int> weights, int length) {
      var sum = 0;
      for (var index = 0; index < length; index++) {
        sum += int.parse(cnpj[index]) * weights[index];
      }
      final remainder = sum % 11;
      return remainder < 2 ? 0 : 11 - remainder;
    }

    final first = checkDigit(firstWeights, 12);
    final second = checkDigit(secondWeights, 13);
    return first == int.parse(cnpj[12]) && second == int.parse(cnpj[13]);
  }

  static bool isValidCpfOrCnpj(String value) {
    final raw = digits(value);
    return raw.length == 11 ? isValidCpf(raw) : isValidCnpj(raw);
  }

  static String? errorFor(String value) {
    final raw = digits(value);
    if (raw.isEmpty) return 'Informe o CPF ou CNPJ.';
    if (raw.length != 11 && raw.length != 14) {
      return 'Digite um CPF com 11 ou CNPJ com 14 números.';
    }
    if (!isValidCpfOrCnpj(raw)) return 'CPF ou CNPJ inválido.';
    return null;
  }
}
