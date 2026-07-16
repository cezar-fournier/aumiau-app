enum AumiauEdition { freeOffline, family }

enum AumiauCapability {
  multiplePets,
  cloudSync,
  expandedHistory,
  addressAndGps,
  homeVetVisits,
}

class ProductPlan {
  const ProductPlan({
    required this.code,
    required this.edition,
    required this.displayName,
    required this.maxPets,
    required this.maxReminders,
    required this.capabilities,
  });

  final String code;
  final AumiauEdition edition;
  final String displayName;
  final int? maxPets;
  final int? maxReminders;
  final Set<AumiauCapability> capabilities;

  bool has(AumiauCapability capability) => capabilities.contains(capability);

  bool canAddPet(int currentCount) =>
      maxPets == null || currentCount < maxPets!;

  bool canAddReminder(int currentCount) =>
      maxReminders == null || currentCount < maxReminders!;

  bool get isFreeOffline => edition == AumiauEdition.freeOffline;
  bool get isFamily => edition == AumiauEdition.family;
}

class ProductCatalog {
  static const freeOffline = ProductPlan(
    code: 'free_offline',
    edition: AumiauEdition.freeOffline,
    displayName: 'AuMiau Free Offline',
    maxPets: 1,
    maxReminders: 1,
    capabilities: <AumiauCapability>{},
  );

  static const familyCapabilities = <AumiauCapability>{
    AumiauCapability.multiplePets,
    AumiauCapability.cloudSync,
    AumiauCapability.expandedHistory,
    AumiauCapability.addressAndGps,
  };

  static const family = ProductPlan(
    code: 'family',
    edition: AumiauEdition.family,
    displayName: 'AuMiau Family',
    maxPets: null,
    maxReminders: null,
    capabilities: familyCapabilities,
  );

  static const familyMonthly = ProductPlan(
    code: 'family_monthly',
    edition: AumiauEdition.family,
    displayName: 'AuMiau Family mensal',
    maxPets: null,
    maxReminders: null,
    capabilities: familyCapabilities,
  );

  static const familyYearly = ProductPlan(
    code: 'family_yearly',
    edition: AumiauEdition.family,
    displayName: 'AuMiau Family anual',
    maxPets: null,
    maxReminders: null,
    capabilities: familyCapabilities,
  );

  static ProductPlan fromCode(String? code) {
    switch (code) {
      case 'family':
        return family;
      case 'family_monthly':
        return familyMonthly;
      case 'family_yearly':
        return familyYearly;
      case 'free_offline':
      case 'Gratuito':
      case 'gratuito':
      default:
        return freeOffline;
    }
  }
}
