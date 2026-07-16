/// Gera o payload EMVCo do Pix Copia e Cola para pagamentos provisórios.
///
/// A confirmação do pagamento não é feita neste serviço. O backend deve
/// validar o comprovante antes de conceder qualquer entitlement Family.
class PixService {
  static const merchantKey = '04368187000131';
  static const merchantName = 'C A INFORMATICA';
  static const merchantCity = 'BRASIL';

  static String buildPayload({
    required double amount,
    required String txid,
    String key = merchantKey,
    String name = merchantName,
    String city = merchantCity,
  }) {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'deve ser maior que zero');
    }

    final merchantAccountInformation = [
      _tlv('00', 'BR.GOV.BCB.PIX'),
      _tlv('01', _normalizeKey(key)),
    ].join();
    final normalizedTxid = _normalizeTxid(txid);
    final payloadWithoutCrc = [
      _tlv('00', '01'),
      _tlv('26', merchantAccountInformation),
      _tlv('52', '0000'),
      _tlv('53', '986'),
      _tlv('54', amount.toStringAsFixed(2)),
      _tlv('58', 'BR'),
      _tlv('59', _ascii(name, 25)),
      _tlv('60', _ascii(city, 15)),
      _tlv('62', _tlv('05', normalizedTxid)),
      '6304',
    ].join();

    return '$payloadWithoutCrc${_crc16(payloadWithoutCrc)}';
  }

  static String _tlv(String id, String value) {
    return '$id${value.length.toString().padLeft(2, '0')}$value';
  }

  static String _normalizeKey(String value) {
    final normalized = value.replaceAll(RegExp(r'[^0-9A-Za-z@._+\-]'), '');
    if (normalized.isEmpty || normalized.length > 77) {
      throw ArgumentError.value(value, 'key', 'chave Pix inválida');
    }
    return normalized;
  }

  static String _normalizeTxid(String value) {
    final normalized = value.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
    if (normalized.isEmpty || normalized.length > 25) {
      throw ArgumentError.value(value, 'txid', 'txid inválido');
    }
    return normalized;
  }

  static String _ascii(String value, int maxLength) {
    const replacements = {
      'Á': 'A',
      'À': 'A',
      'Ã': 'A',
      'Â': 'A',
      'É': 'E',
      'Ê': 'E',
      'Í': 'I',
      'Ó': 'O',
      'Ô': 'O',
      'Õ': 'O',
      'Ú': 'U',
      'Ç': 'C',
      'á': 'A',
      'à': 'A',
      'ã': 'A',
      'â': 'A',
      'é': 'E',
      'ê': 'E',
      'í': 'I',
      'ó': 'O',
      'ô': 'O',
      'õ': 'O',
      'ú': 'U',
      'ç': 'C',
    };
    final normalized = value
        .split('')
        .map((char) => replacements[char] ?? char)
        .join();
    return normalized.substring(0, normalized.length.clamp(0, maxLength));
  }

  static String _crc16(String value) {
    var crc = 0xFFFF;
    for (final byte in value.codeUnits) {
      crc ^= byte << 8;
      for (var bit = 0; bit < 8; bit++) {
        crc = (crc & 0x8000) != 0
            ? ((crc << 1) ^ 0x1021) & 0xFFFF
            : (crc << 1) & 0xFFFF;
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}
