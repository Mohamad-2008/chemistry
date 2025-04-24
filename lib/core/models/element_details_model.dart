class ElementDetailsModel {
  final String name;
  final String symbol;
  final int number;
  final String atomicMass;
  final String category;
  final int xpos;
  final int ypos;
  final String phase;
  final String summary;
  final String appearance;
  final String discoveredBy;
  final String namedBy;
  final String source;
  final String imageUrl;
  final double? electronegativity;
  final double? ionizationEnergy;
  final double? atomicRadius;
  final double? covalentRadius;
  final String? electronConfiguration;
  final List<int>? oxidationStates;
  final String? halfLife;
  final Map<String, dynamic> physicalProperties;
  final Map<String, dynamic> chemicalProperties;
  final Map<String, dynamic> atomicProperties;
  final Map<String, dynamic> otherProperties;

  ElementDetailsModel({
    required this.name,
    required this.symbol,
    required this.number,
    required this.atomicMass,
    required this.category,
    required this.xpos,
    required this.ypos,
    required this.phase,
    required this.summary,
    required this.appearance,
    required this.discoveredBy,
    required this.namedBy,
    required this.source,
    required this.imageUrl,
    this.electronegativity,
    this.ionizationEnergy,
    this.atomicRadius,
    this.covalentRadius,
    this.electronConfiguration,
    this.oxidationStates,
    this.halfLife,
    required this.physicalProperties,
    required this.chemicalProperties,
    required this.atomicProperties,
    required this.otherProperties,
  });

  factory ElementDetailsModel.fromJson(Map<String, dynamic> json) {
    return ElementDetailsModel(
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      number: json['number'] ?? 0,
      atomicMass: json['atomic_mass']?.toString() ?? '0.0',
      category: json['category'] ?? '',
      xpos: json['xpos'] ?? 0,
      ypos: json['ypos'] ?? 0,
      phase: json['phase'] ?? '',
      summary: json['summary'] ?? '',
      appearance: json['appearance'] ?? '',
      discoveredBy: json['discovered_by'] ?? '',
      namedBy: json['named_by'] ?? '',
      source: json['source'] ?? '',
      imageUrl: json['image']?['url'] ?? '',
      electronegativity: json['electronegativity_pauling'] as double?,
      ionizationEnergy: (json['ionization_energies'] as List<dynamic>?)?.isNotEmpty ?? false
          ? (json['ionization_energies'][0] as num?)?.toDouble()
          : null,
      atomicRadius: null, // JSON فعلی این داده را ندارد
      covalentRadius: null, // JSON فعلی این داده را ندارد
      electronConfiguration: json['electron_configuration_semantic'] as String?,
      oxidationStates: null, // JSON فعلی این داده را ندارد
      halfLife: null, // JSON فعلی این داده را ندارد
      physicalProperties: {
        'density': json['density'],
        'melt': json['melt'],
        'boil': json['boil'],
        'molar_heat': json['molar_heat'],
      },
      chemicalProperties: {
        'electron_affinity': json['electron_affinity'],
      },
      atomicProperties: {
        'shells': json['shells'],
      },
      otherProperties: {
        'cpk-hex': json['cpk-hex'],
      },
    );
  }
}