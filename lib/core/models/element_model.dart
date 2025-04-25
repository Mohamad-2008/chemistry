class ElementModel {
  final String name;
  final String symbol;
  final int number;
  final int xpos;
  final int ypos;
  final String category;
  final double atomicMass;
  final String phase;
  final double? meltingPoint;
  final double? boilingPoint;

  ElementModel({
    required this.name,
    required this.symbol,
    required this.number,
    required this.xpos,
    required this.ypos,
    required this.category,
    required this.atomicMass,
    required this.phase,
    this.meltingPoint,
    this.boilingPoint,
  });

  factory ElementModel.fromJson(Map<String, dynamic> json) {
    return ElementModel(
      name: json['name'] ?? 'Unknown',
      symbol: json['symbol'] ?? '',
      number: json['number'] ?? 0,
      xpos: json['xpos'] ?? 0,
      ypos: json['ypos'] ?? 0,
      category: json['category'] ?? 'unknown',
      atomicMass: (json['atomic_mass'] as num?)?.toDouble() ?? 0.0,
      phase: json['phase'] ?? 'Unknown',
      meltingPoint: (json['melt'] as num?)?.toDouble(),
      boilingPoint: (json['boil'] as num?)?.toDouble(),
    );
  }
}