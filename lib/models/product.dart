enum ProductCategory {
  upper('Atasan'),
  lower('Bawahan'),
  feet('Alas kaki'),
  accessory('Aksesoris');

  const ProductCategory(this.label);
  final String label;
}

/// Satu produk di katalog toko.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.categoryName,
    this.imageUrl,
    this.reason = '',
  });

  factory Product.fromJson(Map<String, dynamic> json, {String reason = ''}) {
    final rawCategory = json['category'];
    final categoryMap = rawCategory is Map
        ? Map<String, dynamic>.from(rawCategory)
        : {};
    final categoryName =
        (categoryMap['name'] ??
                json['category_name'] ??
                json['categoryName'] ??
                '')
            .toString()
            .trim();
    final category = _categoryFromValue(
      rawCategory,
      fallbackName: categoryName,
    );
    final rawPrice = json['price'];
    final rawId = json['id'];

    return Product(
      id: rawId?.toString() ?? '',
      name: (json['name'] ?? 'Produk').toString(),
      category: category,
      categoryName: categoryName.isNotEmpty
          ? categoryName
          : _fallbackCategoryName(category),
      price: _parseInt(rawPrice),
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? json['image_path'],
      reason: reason,
    );
  }

  static ProductCategory _categoryFromValue(
    dynamic rawCategory, {
    String fallbackName = '',
  }) {
    final categoryMap = rawCategory is Map
        ? Map<String, dynamic>.from(rawCategory)
        : {};
    final value =
        categoryMap['body_zone'] ??
        categoryMap['zone'] ??
        categoryMap['name'] ??
        rawCategory;
    final normalized = (value ?? fallbackName ?? 'upper')
        .toString()
        .trim()
        .toLowerCase();

    switch (normalized) {
      case 'upper':
      case 'atasan':
      case 'top':
        return ProductCategory.upper;
      case 'lower':
      case 'bawahan':
      case 'bottom':
        return ProductCategory.lower;
      case 'feet':
      case 'shoes':
      case 'sepatu':
      case 'sendal':
        return ProductCategory.feet;
      case 'outer':
      case 'luaran':
      case 'jaket':
      case 'outerwear':
        return ProductCategory.upper;
      case 'accessory':
      case 'aksesori':
      case 'topi':
      case 'kacamata':
        return ProductCategory.accessory;
      default:
        return ProductCategory.upper;
    }
  }

  static String _fallbackCategoryName(ProductCategory category) {
    switch (category) {
      case ProductCategory.upper:
        return 'atasan';
      case ProductCategory.lower:
        return 'bawahan';
      case ProductCategory.feet:
        return 'alas_kaki';
      case ProductCategory.accessory:
        return 'aksesori';
    }
  }

  String? get tryOnFieldName {
    final normalizedName = categoryName.toLowerCase();

    switch (normalizedName) {
      case 'topi':
        return 'topi_id';
      case 'kacamata':
        return 'kacamata_id';
      default:
        switch (category) {
          case ProductCategory.upper:
            return 'atasan_id';
          case ProductCategory.lower:
            return 'bawahan_id';
          case ProductCategory.feet:
            return 'alas_kaki_id';
          case ProductCategory.accessory:
            return null;
        }
    }
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String)
      return int.tryParse(value.replaceAll('.', '').replaceAll(',', '')) ?? 0;
    return 0;
  }

  final String id;
  final String name;
  final ProductCategory category;
  final String categoryName;
  final int price; // dalam rupiah
  final String? imageUrl; // isi dengan foto produk asli dari katalog
  final String reason;
}
