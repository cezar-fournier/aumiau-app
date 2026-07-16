import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../data/app_database.dart';

class BackupService {
  static const _format = 'aumiau-backup';

  static Future<Uint8List> buildBackup(AppDatabase database) async {
    final snapshot = await database.exportSnapshot();
    final json = const JsonEncoder.withIndent('  ').convert(snapshot);
    return Uint8List.fromList(utf8.encode(json));
  }

  static Future<String?> saveBackup(AppDatabase database) async {
    final bytes = await buildBackup(database);
    return FilePicker.saveFile(
      dialogTitle: 'Salvar backup do AuMiau',
      fileName: _fileName(),
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: bytes,
    );
  }

  static Future<ShareResult> shareBackup(AppDatabase database) async {
    final bytes = await buildBackup(database);
    return SharePlus.instance.share(
      ShareParams(
        title: 'Backup do AuMiau',
        text: 'Backup dos dados locais do AuMiau.',
        files: [
          XFile.fromData(
            bytes,
            name: _fileName(),
            mimeType: 'application/json',
          ),
        ],
      ),
    );
  }

  static Future<void> restoreBackup(AppDatabase database) async {
    final result = await FilePicker.pickFiles(
      dialogTitle: 'Selecionar backup do AuMiau',
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.single.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw const FormatException('Não foi possível ler o arquivo selecionado.');
    }

    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map) {
      throw const FormatException('O arquivo não contém um backup válido.');
    }
    final snapshot = Map<String, dynamic>.from(decoded);
    if (snapshot['format'] != _format) {
      throw const FormatException('Este arquivo não é um backup do AuMiau.');
    }
    await database.restoreSnapshot(snapshot);
  }

  static String _fileName() {
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return 'aumiau-backup-$stamp.json';
  }
}
