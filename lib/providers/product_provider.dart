import 'dart:io';
import 'package:flutter/material.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/storage_repository.dart';
import '../data/models/product_model.dart';
import '../data/models/category_model.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  final ProductRepository productRepository;
  final StorageRepository storageRepository;

  ProductProvider({
    required this.productRepository,
    required this.storageRepository,
  });

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

  /// Todos los productos sin filtrar (para panel admin)
  List<ProductModel> get allProducts => _products;

  List<ProductModel> get filteredProducts {
    var list = _products;
    if (_selectedCategoryId != null) {
      list = list.where((p) => p.categoryId == _selectedCategoryId).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return list;
  }

  Future<void> loadAll() async {
    if (_status == ProductStatus.loading) return;

    _status = ProductStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('ProductProvider: loadAll iniciando...');
      final results = await Future.wait([
        productRepository.getProducts(),
        productRepository.getFeaturedProducts(),
        productRepository.getCategories(),
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('ProductProvider: ⏰ TIMEOUT');
          return [<ProductModel>[], <ProductModel>[], <CategoryModel>[]];
        },
      );

      _products = results[0] as List<ProductModel>;
      _featured = results[1] as List<ProductModel>;
      _categories = results[2] as List<CategoryModel>;
      _status = ProductStatus.loaded;

      debugPrint(
        'ProductProvider: loadAll OK — '
        '${_products.length} productos, '
        '${_featured.length} destacados, '
        '${_categories.length} categorías',
      );
    } catch (e, st) {
      debugPrint('ProductProvider ERROR: $e');
      debugPrintStack(stackTrace: st);
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
      _products = await productRepository
          .getProducts(categoryId: categoryId)
          .timeout(const Duration(seconds: 10));
      _status = ProductStatus.loaded;
    } catch (e, st) {
      debugPrint('ProductProvider loadByCategory ERROR: $e');
      debugPrintStack(stackTrace: st);
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

  // ── CRUD Admin ─────────────────────────────────────────────────────────────

  /// Crea un nuevo producto en Firestore, opcionalmente sube imagen a Storage.
  Future<void> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String categoryId,
    required String categoryName,
    double? discountPrice,
    File? imageFile,
  }) async {
    List<String> imageUrls = [];

    if (imageFile != null) {
      // Necesitamos el id antes de subir; generamos uno temporal
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final url = await storageRepository.uploadProductImage(tempId, imageFile);
      imageUrls = [url];
    }

    final product = ProductModel(
      id: '', // Firestore lo asigna
      name: name,
      description: description,
      price: price,
      discountPrice: discountPrice,
      imageUrls: imageUrls,
      categoryId: categoryId,
      categoryName: categoryName,
      stock: stock,
      isActive: true,
      createdAt: DateTime.now(),
    );

    await productRepository.createProduct(product);
    await loadAll(); // Refresca la lista
  }

  /// Actualiza un producto existente. Si hay nueva imagen la sube primero.
  Future<void> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String categoryId,
    required String categoryName,
    double? discountPrice,
    File? newImageFile,
    List<String> existingImageUrls = const [],
  }) async {
    List<String> imageUrls = List.from(existingImageUrls);

    if (newImageFile != null) {
      final url =
          await storageRepository.uploadProductImage(productId, newImageFile);
      imageUrls = [url]; // Reemplaza la imagen
    }

    final data = {
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'imageUrls': imageUrls,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'stock': stock,
    };

    await productRepository.updateProduct(productId, data);
    await loadAll();
  }

  /// Elimina un producto de Firestore (soft delete = isActive: false)
  Future<void> deleteProduct(String productId) async {
    await productRepository.deleteProduct(productId);
    await loadAll();
  }
}
