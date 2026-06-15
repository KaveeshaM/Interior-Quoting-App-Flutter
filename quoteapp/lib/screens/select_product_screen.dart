import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class SelectProductScreen extends StatefulWidget {
  final String currentProductId;
  final String? currentColour;
  final Function(Product, String) onProductSelected;

  const SelectProductScreen({
    super.key,
    required this.currentProductId,
    required this.currentColour,
    required this.onProductSelected,
  });

  @override
  State<SelectProductScreen> createState() => _SelectProductScreenState();
}

class _SelectProductScreenState extends State<SelectProductScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Product')),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productProvider.error != null
          ? Center(child: Text('Error: ${productProvider.error}'))
          : productProvider.products.isEmpty
          ? const Center(child: Text('No products available'))
          : ListView.builder(
              itemCount: productProvider.products.length,
              itemBuilder: (context, index) {
                final product = productProvider.products[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      // Product image
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: product.imageUrl.isNotEmpty
                            ? Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.broken_image),
                              )
                            : const Icon(Icons.image),
                      ),
                      // Product details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product.pricePerSqm.toStringAsFixed(2)} AUD/m²',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Set button
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onProductSelected(product, '');
                            Navigator.pop(context);
                          },
                          child: const Text('Set'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
