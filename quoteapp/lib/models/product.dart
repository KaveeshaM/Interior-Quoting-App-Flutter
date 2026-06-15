class Product {
  final String id;
  final String name;
  final String description;
  final double pricePerSqm; // price per square metre
  final String imageUrl;
  final List<String> colours; // colour variants

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerSqm,
    required this.imageUrl,
    required this.colours,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pricePerSqm: (json['pricePerSqm'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      colours: List<String>.from(json['colours'] ?? []),
    );
  }
}
