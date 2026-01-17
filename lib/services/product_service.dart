import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../models/category.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  List<Product> _products = [];
  bool _loaded = false;

  Future<List<Product>> loadProducts() async {
    if (_loaded) return _products;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      _products = jsonList
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
      _loaded = true;
      return _products;
    } catch (error) {
      print('Error loading products: $error');
      return [];
    }
  }

  Product? getProductBySlug(String slug) {
    try {
      return _products.firstWhere((p) => p.slug == slug);
    } catch (e) {
      return null;
    }
  }

  Product? getProductById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getProductsByCategory(String categorySlug) {
    return _products.where((product) {
      return product.categories.any((cat) => cat.slug == categorySlug);
    }).toList();
  }

  List<Product> getProductsByTag(String tagSlug) {
    return _products.where((product) {
      return product.tags.any((tag) => tag['slug'] == tagSlug);
    }).toList();
  }

  List<Category> getAllCategories() {
    final Map<String, Category> categoriesMap = {};
    for (var product in _products) {
      for (var category in product.categories) {
        if (!categoriesMap.containsKey(category.slug)) {
          categoriesMap[category.slug] = category;
        }
      }
    }
    return categoriesMap.values.toList();
  }

  List<Map<String, dynamic>> getAllTags() {
    final Map<String, Map<String, dynamic>> tagsMap = {};
    for (var product in _products) {
      for (var tag in product.tags) {
        final slug = tag['slug'] as String?;
        if (slug != null && !tagsMap.containsKey(slug)) {
          tagsMap[slug] = tag;
        }
      }
    }
    return tagsMap.values.toList();
  }

  List<Product> getRelatedProducts(int productId, {int limit = 4}) {
    final currentProduct = getProductById(productId);
    if (currentProduct == null ||
        currentProduct.categories.isEmpty) {
      return [];
    }

    final categorySlugs =
        currentProduct.categories.map((cat) => cat.slug).toList();

    final related = _products.where((product) {
      if (product.id == productId) return false;
      return product.categories.any((cat) => categorySlugs.contains(cat.slug));
    }).toList();

    return related.take(limit).toList();
  }

  List<Product> get allProducts => List.unmodifiable(_products);
}

