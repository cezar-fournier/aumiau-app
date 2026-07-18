import 'dart:math' as math;

class PartnerClinic {
  const PartnerClinic({
    required this.id,
    required this.name,
    required this.kind,
    required this.address,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.services,
    this.phone = '',
    this.whatsapp = '',
    this.acceptsUrgency = false,
    this.isDemonstration = false,
  });

  final String id;
  final String name;
  final String kind;
  final String address;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final List<String> services;
  final String phone;
  final String whatsapp;
  final bool acceptsUrgency;
  final bool isDemonstration;

  double distanceFrom(double latitude, double longitude) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(this.latitude - latitude);
    final dLon = _toRadians(this.longitude - longitude);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRadians(latitude)) *
            math.cos(_toRadians(this.latitude)) *
            math.pow(math.sin(dLon / 2), 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _toRadians(double value) => value * math.pi / 180;
}

class PrivateVeterinaryContact {
  const PrivateVeterinaryContact({
    required this.id,
    required this.name,
    required this.kind,
    required this.specialty,
    required this.phone,
    required this.whatsapp,
    required this.address,
    required this.city,
    required this.state,
    required this.notes,
    this.latitude,
    this.longitude,
  });

  final int? id;
  final String name;
  final String kind;
  final String specialty;
  final String phone;
  final String whatsapp;
  final String address;
  final String city;
  final String state;
  final String notes;
  final double? latitude;
  final double? longitude;
}

/// Catálogo local de demonstração. Em produção, será substituído pelo
/// catálogo de parceiros publicado pelo backend e pelo painel administrativo.
class PartnerDirectory {
  static const demonstrationPartners = <PartnerClinic>[
    PartnerClinic(
      id: 'demo-amigo-fiel',
      name: 'Clínica parceira AuMiau · Exemplo',
      kind: 'Clínica veterinária',
      address: 'Centro, Manaus - AM',
      city: 'Manaus',
      state: 'AM',
      latitude: -3.1190,
      longitude: -60.0217,
      services: ['Consulta', 'Vacinação', 'Atendimento rápido'],
      acceptsUrgency: true,
      isDemonstration: true,
    ),
    PartnerClinic(
      id: 'demo-petvida',
      name: 'Profissional parceiro AuMiau · Exemplo',
      kind: 'Atendimento veterinário',
      address: 'Adrianópolis, Manaus - AM',
      city: 'Manaus',
      state: 'AM',
      latitude: -3.1014,
      longitude: -60.0120,
      services: ['Consulta', 'Orientação preventiva'],
      acceptsUrgency: false,
      isDemonstration: true,
    ),
  ];

  static List<PartnerClinic> search({
    String query = '',
    bool urgencyOnly = false,
    double? latitude,
    double? longitude,
  }) {
    final normalized = query.trim().toLowerCase();
    final result = demonstrationPartners.where((partner) {
      if (urgencyOnly && !partner.acceptsUrgency) return false;
      if (normalized.isEmpty) return true;
      final searchable = [
        partner.name,
        partner.kind,
        partner.address,
        partner.city,
        ...partner.services,
      ].join(' ').toLowerCase();
      return searchable.contains(normalized);
    }).toList();

    if (latitude == null || longitude == null) return result;
    result.sort(
      (a, b) => a
          .distanceFrom(latitude, longitude)
          .compareTo(b.distanceFrom(latitude, longitude)),
    );
    return result;
  }
}
