String normalizeAccountEmail(String email) => email.trim().toLowerCase();

String accountStorageId(String email) {
  final normalized = normalizeAccountEmail(email);
  var hash = 0xcbf29ce484222325;
  for (final byte in normalized.codeUnits) {
    hash ^= byte;
    hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}

String accountDatabaseName(String email) =>
    'aumiau_account_${accountStorageId(email)}';

String accountPartnerDraftKey(String email) =>
    'aumiau.partner.registration_draft.${accountStorageId(email)}';
