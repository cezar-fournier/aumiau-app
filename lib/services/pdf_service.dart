import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfPetData {
  const PdfPetData({
    required this.name,
    required this.species,
    required this.breed,
    required this.weight,
    required this.vaccines,
    required this.weights,
  });

  final String name;
  final String species;
  final String breed;
  final double weight;
  final List<PdfVaccineData> vaccines;
  final List<PdfWeightData> weights;
}

class PdfVaccineData {
  const PdfVaccineData({
    required this.name,
    required this.appliedAt,
    required this.nextDoseAt,
    required this.clinicName,
  });

  final String name;
  final String appliedAt;
  final String nextDoseAt;
  final String clinicName;
}

class PdfWeightData {
  const PdfWeightData({
    required this.weight,
    required this.measuredAt,
    required this.note,
  });

  final String weight;
  final String measuredAt;
  final String note;
}

class PdfTimelineData {
  const PdfTimelineData({
    required this.title,
    required this.subtitle,
    required this.date,
  });

  final String title;
  final String subtitle;
  final String date;
}

class PdfService {
  const PdfService._();

  static Future<void> exportHealthHistory({
    required List<PdfPetData> pets,
    required List<PdfTimelineData> timeline,
  }) async {
    await Printing.layoutPdf(
      name: 'aumiau-historico.pdf',
      onLayout: (_) => buildHealthHistoryPdf(pets: pets, timeline: timeline),
    );
  }

  static Future<Uint8List> buildHealthHistoryPdf({
    required List<PdfPetData> pets,
    required List<PdfTimelineData> timeline,
  }) => _buildDocument(pets: pets, timeline: timeline);

  static Future<Uint8List> _buildDocument({
    required List<PdfPetData> pets,
    required List<PdfTimelineData> timeline,
  }) async {
    final document = pw.Document();
    final muted = PdfColor.fromHex('#6B7A73');
    final forest = PdfColor.fromHex('#1E4D40');
    final mango = PdfColor.fromHex('#FFB627');
    final fontData = await rootBundle.load(
      'assets/fonts/NotoSans-Variable.ttf',
    );
    final documentFont = pw.Font.ttf(fontData);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: documentFont, bold: documentFont),
        margin: const pw.EdgeInsets.fromLTRB(32, 34, 32, 36),
        header: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 18),
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: mango, width: 2)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'AuMiau',
                style: pw.TextStyle(
                  color: forest,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Histórico de saúde dos pets',
                style: pw.TextStyle(color: muted, fontSize: 9),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: pw.TextStyle(color: muted, fontSize: 8),
          ),
        ),
        build: (context) => [
          pw.Text(
            'Resumo dos pets',
            style: pw.TextStyle(
              color: forest,
              fontSize: 17,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          ...pets.map(
            (pet) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 14),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#E7E3D8')),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    pet.name,
                    style: pw.TextStyle(
                      color: forest,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    '${pet.species} · ${pet.breed} · Peso atual: ${pet.weight.toStringAsFixed(1)} kg',
                    style: pw.TextStyle(color: muted, fontSize: 9),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Vacinas',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  if (pet.vaccines.isEmpty)
                    pw.Text(
                      'Nenhuma vacina registrada.',
                      style: pw.TextStyle(color: muted, fontSize: 9),
                    )
                  else
                    ...pet.vaccines.map(
                      (vaccine) => pw.Text(
                        '• ${vaccine.name} · aplicada em ${vaccine.appliedAt} · próxima dose: ${vaccine.nextDoseAt} · ${vaccine.clinicName}',
                        style: pw.TextStyle(fontSize: 9),
                      ),
                    ),
                  pw.SizedBox(height: 7),
                  pw.Text(
                    'Registros de peso',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  if (pet.weights.isEmpty)
                    pw.Text(
                      'Nenhum registro detalhado.',
                      style: pw.TextStyle(color: muted, fontSize: 9),
                    )
                  else
                    ...pet.weights
                        .take(8)
                        .map(
                          (entry) => pw.Text(
                            '• ${entry.measuredAt}: ${entry.weight}${entry.note.isEmpty ? '' : ' · ${entry.note}'}',
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Linha do tempo unificada',
            style: pw.TextStyle(
              color: forest,
              fontSize: 17,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          if (timeline.isEmpty)
            pw.Text(
              'Nenhuma atividade registrada.',
              style: pw.TextStyle(color: muted, fontSize: 9),
            )
          else
            ...timeline.map(
              (entry) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 6),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColor.fromHex('#E7E3D8')),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 68,
                      child: pw.Text(
                        entry.date,
                        style: pw.TextStyle(color: muted, fontSize: 8),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            entry.title,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                          pw.Text(
                            entry.subtitle,
                            style: pw.TextStyle(color: muted, fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    return document.save();
  }
}
