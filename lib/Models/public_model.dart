import 'package:e_commerce/Models/product.dart';

class AppCategory {
  final String id;
  final String name;
  final String image;
  final List<AppSubCategory> subcategories;

  AppCategory({
    required this.id,
    required this.name,
    required this.image,
    required this.subcategories,
  });
}

class AppSubCategory {
  final String id;
  final String name;
  final String image;
  final List<AppSubSubCategory> subSubCategories;
  final List<Product> products;

  AppSubCategory({
    required this.id,
    required this.name,
    required this.image,
    required this.subSubCategories,
    required this.products,
  });
}

class AppSubSubCategory {
  final String id;
  final String name;
  final String image;
  final List<Product> products;

  AppSubSubCategory({
    required this.id,
    required this.name,
    required this.image,
    required this.products,
  });
}

class ProductGrouper {
  static List<AppCategory> groupProducts(List<Product> allProducts) {
    final Map<String, _CategoryBuilder> categoryMap = {};

    for (final product in allProducts) {
      if (product.status != 'active') continue;

      final cat = product.category;
      if (cat == null) continue;

      final catId = cat.id;
      final catBuilder = categoryMap.putIfAbsent(
        catId,
        () => _CategoryBuilder(id: catId, name: cat.name, image: cat.image),
      );

      final sub = product.subcategory;
      final subSub = product.subSubcategory;

      if (sub == null || sub.id == null || sub.name == null) {
        catBuilder.directProducts.add(product);
        continue;
      }

      final subBuilder = catBuilder.subMap.putIfAbsent(
        sub.id!,
        () => _SubBuilder(
          id: sub.id!,
          name: sub.name!,
          image: sub.image ?? '',
        ),
      );

      if (subSub == null || subSub.id == null || subSub.name == null) {
        subBuilder.directProducts.add(product);
        continue;
      }

      final subSubBuilder = subBuilder.subSubMap.putIfAbsent(
        subSub.id!,
        () => _SubSubBuilder(
          id: subSub.id!,
          name: subSub.name!,
          image: subSub.image ?? '',
        ),
      );

      subSubBuilder.products.add(product);
    }

    return categoryMap.values.map((c) => c.build()).toList();
  }
}

// ── Internal builders ─────────────────────────────────────────────────────────

class _CategoryBuilder {
  final String id, name, image;
  final Map<String, _SubBuilder> subMap = {};
  final List<Product> directProducts = [];

  _CategoryBuilder({required this.id, required this.name, required this.image});

  AppCategory build() {
    final subs = subMap.values.map((s) => s.build()).toList();

    // Agar kuch products ka koi subcategory nahi hai
    // unhe "All" naam ki ek default sub mein daal do
    if (directProducts.isNotEmpty) {
      subs.insert(
        0,
        AppSubCategory(
          id: '${id}_direct',
          name: 'All',
          image: '',
          subSubCategories: [],
          products: directProducts,
        ),
      );
    }

    return AppCategory(
      id: id,
      name: name,
      image: image,
      subcategories: subs,
    );
  }
}

class _SubBuilder {
  final String id, name, image;
  final Map<String, _SubSubBuilder> subSubMap = {};
  final List<Product> directProducts = [];

  _SubBuilder({required this.id, required this.name, required this.image});

  AppSubCategory build() => AppSubCategory(
        id: id,
        name: name,
        image: image,
        subSubCategories: subSubMap.values.map((s) => s.build()).toList(),
        products: directProducts,
      );
}

class _SubSubBuilder {
  final String id, name, image;
  final List<Product> products = [];

  _SubSubBuilder({required this.id, required this.name, required this.image});

  AppSubSubCategory build() => AppSubSubCategory(
        id: id,
        name: name,
        image: image,
        products: products,
      );
}
