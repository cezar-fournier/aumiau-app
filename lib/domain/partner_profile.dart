class PartnerProfileDraft {
  const PartnerProfileDraft({
    required this.businessName,
    required this.partnerType,
    required this.document,
    required this.documentType,
    required this.responsibleName,
    required this.responsibleCpf,
    required this.crmvUf,
    required this.crmvNumber,
    required this.artNumber,
    required this.phone,
    required this.whatsapp,
    required this.address,
    required this.postalCode,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.services,
    required this.acceptsUrgency,
    required this.termsAccepted,
    this.submittedOnline = false,
  });

  final String businessName;
  final String partnerType;
  final String document;
  final String documentType;
  final String responsibleName;
  final String responsibleCpf;
  final String crmvUf;
  final String crmvNumber;
  final String artNumber;
  final String phone;
  final String whatsapp;
  final String address;
  final String postalCode;
  final String city;
  final String state;
  final double? latitude;
  final double? longitude;
  final List<String> services;
  final bool acceptsUrgency;
  final bool termsAccepted;
  final bool submittedOnline;

  Map<String, dynamic> toJson() => {
    'businessName': businessName.trim(),
    'partnerType': partnerType.trim().toLowerCase(),
    'cnpj': document.trim(),
    'documentType': documentType.trim().toLowerCase(),
    'responsibleName': responsibleName.trim(),
    'responsibleCpf': responsibleCpf.trim(),
    'crmvUf': crmvUf.trim().toUpperCase(),
    'crmvNumber': crmvNumber.trim(),
    'artNumber': artNumber.trim(),
    'phone': phone.trim(),
    'whatsapp': whatsapp.trim(),
    'address': address.trim(),
    'postalCode': postalCode.trim(),
    'city': city.trim(),
    'state': state.trim().toUpperCase(),
    'latitude': latitude,
    'longitude': longitude,
    'services': services
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(),
    'acceptsUrgency': acceptsUrgency,
    'termsAccepted': termsAccepted,
    '_submittedOnline': submittedOnline,
  };

  PartnerProfileDraft copyWith({bool? submittedOnline}) => PartnerProfileDraft(
    businessName: businessName,
    partnerType: partnerType,
    document: document,
    documentType: documentType,
    responsibleName: responsibleName,
    responsibleCpf: responsibleCpf,
    crmvUf: crmvUf,
    crmvNumber: crmvNumber,
    artNumber: artNumber,
    phone: phone,
    whatsapp: whatsapp,
    address: address,
    postalCode: postalCode,
    city: city,
    state: state,
    latitude: latitude,
    longitude: longitude,
    services: services,
    acceptsUrgency: acceptsUrgency,
    termsAccepted: termsAccepted,
    submittedOnline: submittedOnline ?? this.submittedOnline,
  );

  static PartnerProfileDraft? fromJson(Map<String, dynamic> json) {
    final businessName = json['businessName']?.toString().trim() ?? '';
    final document = json['cnpj']?.toString().trim() ?? '';
    if (businessName.isEmpty || document.isEmpty) return null;
    final rawServices = json['services'];
    return PartnerProfileDraft(
      businessName: businessName,
      partnerType: json['partnerType']?.toString() ?? 'clinic',
      document: document,
      documentType: json['documentType']?.toString() ?? '',
      responsibleName: json['responsibleName']?.toString() ?? '',
      responsibleCpf: json['responsibleCpf']?.toString() ?? '',
      crmvUf: json['crmvUf']?.toString() ?? '',
      crmvNumber: json['crmvNumber']?.toString() ?? '',
      artNumber: json['artNumber']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      whatsapp: json['whatsapp']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      services: rawServices is List
          ? rawServices.map((value) => value.toString()).toList()
          : const [],
      acceptsUrgency: json['acceptsUrgency'] == true,
      termsAccepted: json['termsAccepted'] == true,
      submittedOnline: json['_submittedOnline'] == true,
    );
  }
}
