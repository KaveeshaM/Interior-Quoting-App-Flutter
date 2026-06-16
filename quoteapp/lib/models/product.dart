class Product {
  final String id;
  final String name;
  final String description;
  final double pricePerSqm;
  final String imageUrl;
  final List<String> colours;
  final double? minWidth;
  final double? maxWidth;
  final int? maxPanels;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerSqm,
    required this.imageUrl,
    required this.colours,
    this.minWidth,
    this.maxWidth,
    this.maxPanels,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pricePerSqm: (json['price_per_sqm'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      colours: List<String>.from(json['variants'] ?? []),
      minWidth: json['min_width'] != null
          ? (json['min_width'] as num).toDouble()
          : null,
      maxWidth: json['max_width'] != null
          ? (json['max_width'] as num).toDouble()
          : null,
      maxPanels: json['max_panels'] as int?,
    );
  }
}
