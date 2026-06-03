import 'package:flutter/material.dart';
import '../data/repositories/product_repository.dart';
import '../data/models/product_model.dart';
import '../data/models/category_model.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  final ProductRepository productRepository;
  ProductProvider({required this.productRepository});

  ProductStatus _status = ProductStatus.initial;
  List<ProductModel> _products = [];
  List<ProductModel> _featured = [];
  List<CategoryModel> _categories = [];
  String? _errorMessage;
  String? _selectedCategoryId;
  String _searchQuery = '';

  ProductStatus get status => _status;
  List<ProductModel> get featured => _featured;
  List<CategoryModel> get categories => _categories;
  String? get errorMessage => _errorMessage;
  String? get selectedCategoryId => _selectedCategoryId;

  List<ProductModel> get filteredProducts {
    var list = _products;
    if (_selectedCategoryId != null) {
      list = list.where((p) => p.categoryId == _selectedCategoryId).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return list;
  }

  Future<void> loadAll() async {
    _status = ProductStatus.loading;
    notifyListeners();
    try {
      final results = await Future.wait([
        productRepository.getProducts(),
        productRepository.getFeaturedProducts(),
        productRepository.getCategories(),
      ]);
      _products = results[0] as List<ProductModel>;
      _featured = results[1] as List<ProductModel>;
      _categories = results[2] as List<CategoryModel>;
      _status = ProductStatus.loaded;
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadByCategory(String? categoryId) async {
    _selectedCategoryId = categoryId;
    _status = ProductStatus.loading;
    notifyListeners();
    try {
      _products = await productRepository.getProducts(categoryId: categoryId);
      _status = ProductStatus.loaded;
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }
}