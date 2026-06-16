import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> get products => _products;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;

  Future<void> fetchProducts({String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Uri url;
      if (category != null && category.isNotEmpty) {
        url = Uri.parse(
          'https://utasbot.dev/kit305_2026/product?category=$category',
        );
      } else {
        url = Uri.parse('https://utasbot.dev/kit305_2026/product');
      }

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> productsJson = jsonResponse['data'];

        final List<Product> products = productsJson
            .map((product) => Product.fromJson(product))
            .toList();

        _products = products;
      } else {
        _error = 'Failed to load products: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> fetchProductById(String id) async {
    try {
      final url = Uri.parse('https://utasbot.dev/kit305_2026/product/$id');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final productJson = jsonResponse['data'];
        return Product.fromJson(productJson);
      }
    } catch (e) {
      debugPrint('Error fetching product $id: $e');
    }
    return null;
  }
}
