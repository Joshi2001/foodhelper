import 'package:e_commerce/Models/public_model.dart';
import 'package:e_commerce/Models/product.dart';
import 'package:e_commerce/Screens/AdvertisingBannerCarousel.dart';
import 'package:e_commerce/Screens/whichlist/provider/whichlist_provider.dart';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:e_commerce/UI/Widgets/Atoms/card_product_list.dart';
import 'package:e_commerce/UI/Widgets/Atoms/wistlist_button.dart';
import 'package:e_commerce/UI/Widgets/similar/productDetailScreenSimple.dart';
import 'package:e_commerce/UI/Widgets/Organisms/bottom_cart_container.dart';
import 'package:e_commerce/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

const Color _subSubColor = Color(0xFF1565C0);

class SubCategoryScreen extends StatefulWidget {
  final String categoryId;
  const SubCategoryScreen({super.key, required this.categoryId});

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  int _selectedSubIndex = 0;
  int _selectedSubSubIndex = 1;

  double _minPrice = 0;
  double _maxPrice = 10000;
  String? _selectedBrand;
  String? _selectedWeight;

  AppCategory? _getCategory(Home home) {
    try {
      return home.appCategories.firstWhere((c) => c.id == widget.categoryId);
    } catch (_) {
      return null;
    }
  }

  AppSubCategory? _getSelectedSub(AppCategory category) {
    if (category.subcategories.isEmpty) return null;
    if (_selectedSubIndex >= category.subcategories.length) return null;
    return category.subcategories[_selectedSubIndex];
  }

  List<Product> _getAllCurrentProducts(AppCategory category) {
    final sub = _getSelectedSub(category);
    if (sub == null) return [];
    if (sub.subSubCategories.isNotEmpty) {
      final idx = _selectedSubSubIndex - 1;
      if (idx >= 0 && idx < sub.subSubCategories.length) {
        return sub.subSubCategories[idx].products;
      }
      return sub.subSubCategories.first.products;
    }
    return sub.products;
  }

  List<Product> _getVisibleProducts(AppCategory category) {
    final all = _getAllCurrentProducts(category);
    final dynamicMax = _getDynamicMaxPrice(all);
    return all.where((p) {
      final price = p.salePrice.toDouble();
      if (price < _minPrice || price > _maxPrice) return false;
      if (_selectedBrand != null) {
        if ((p.brand?.trim() ?? '') != _selectedBrand) return false;
      }
      if (_selectedWeight != null) {
        final w =
            p.weight != null ? '${p.weight!.value}${p.weight!.unit}' : null;
        if (w != _selectedWeight) return false;
      }
      return true;
    }).toList();
  }

  List<String> _getAvailableBrands(AppCategory category) {
    final sub = _getSelectedSub(category);
    if (sub == null) return [];
    final all = [
      ...sub.products,
      ...sub.subSubCategories.expand((s) => s.products)
    ];
    return all
        .map((p) => p.brand?.trim() ?? '')
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> _getAvailableWeights(AppCategory category) {
    final sub = _getSelectedSub(category);
    if (sub == null) return [];
    final all = [
      ...sub.products,
      ...sub.subSubCategories.expand((s) => s.products)
    ];
    return all
        .where((p) => p.weight != null)
        .map((p) => '${p.weight!.value}${p.weight!.unit}')
        .toSet()
        .toList()
      ..sort();
  }

  double _getDynamicMaxPrice(List<Product> products) {
    if (products.isEmpty) return 10000;
    final max =
        products.map((p) => p.salePrice).reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble().clamp(1000, 100000);
  }

  bool _hasActiveFilters(List<Product> products) {
    final dynamicMax = _getDynamicMaxPrice(products);
    return _minPrice > 0 ||
        _maxPrice < dynamicMax ||
        _selectedBrand != null ||
        _selectedWeight != null;
  }

  int _getActiveFilterCount(List<Product> products) {
    final dynamicMax = _getDynamicMaxPrice(products);
    return (_minPrice > 0 || _maxPrice < dynamicMax ? 1 : 0) +
        (_selectedBrand != null ? 1 : 0) +
        (_selectedWeight != null ? 1 : 0);
  }

  void _resetFilters(List<Product> products) {
    setState(() {
      _minPrice = 0;
      _maxPrice = _getDynamicMaxPrice(products);
      _selectedBrand = null;
      _selectedWeight = null;
    });
  }

  void _showFilterSheet(BuildContext context, AppCategory category,
      List<Product> currentProducts) {
    final maxP = _getDynamicMaxPrice(currentProducts);
    double tempMin = _minPrice;
    double tempMax = _maxPrice < maxP ? _maxPrice : maxP;
    String? tempBrand = _selectedBrand;
    String? tempWeight = _selectedWeight;
    final brands = _getAvailableBrands(category);
    final weights = _getAvailableWeights(category);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          int tempActiveCount = 0;
          if (tempMin > 0 || tempMax < maxP) tempActiveCount++;
          if (tempBrand != null) tempActiveCount++;
          if (tempWeight != null) tempActiveCount++;

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.75),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 5),
                  width: 35,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 10, 5),
                  child: Row(
                    children: [
                      const Text('Filters',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setModalState(() {
                          tempMin = 0;
                          tempMax = maxP;
                          tempBrand = null;
                          tempWeight = null;
                        }),
                        child: const Text('Reset',
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Price Range',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('₹${tempMin.toInt()} - ₹${tempMax.toInt()}',
                                style: TextStyle(
                                    color: AppColors.primaryOrangeColor,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 16),
                          ),
                          child: RangeSlider(
                            values: RangeValues(tempMin, tempMax),
                            min: 0,
                            max: maxP > 0 ? maxP : 1,
                            activeColor: AppColors.primaryOrangeColor,
                            inactiveColor:
                                AppColors.primaryOrangeColor.withOpacity(0.1),
                            onChanged: (v) => setModalState(() {
                              tempMin = v.start;
                              tempMax = v.end;
                            }),
                          ),
                        ),
                        if (brands.isNotEmpty) ...[
                          const SizedBox(height: 15),
                          const Text('Brand',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: brands.map((brand) {
                              final isSel = tempBrand == brand;
                              return _buildAnimatedChip(
                                label: brand,
                                isSelected: isSel,
                                color: AppColors.primaryOrangeColor,
                                onTap: () => setModalState(
                                    () => tempBrand = isSel ? null : brand),
                              );
                            }).toList(),
                          ),
                        ],
                        if (weights.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text('Weight',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: weights.map((wt) {
                              final isSel = tempWeight == wt;
                              return _buildAnimatedChip(
                                label: wt,
                                isSelected: isSel,
                                color: const Color(0xFF2E7D32),
                                onTap: () => setModalState(
                                    () => tempWeight = isSel ? null : wt),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5))
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: const Text('Cancel',
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _minPrice = tempMin;
                              _maxPrice = tempMax;
                              _selectedBrand = tempBrand;
                              _selectedWeight = tempWeight;
                            });
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrangeColor,
                            minimumSize: const Size(0, 48),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              tempActiveCount > 0
                                  ? 'Apply ($tempActiveCount)'
                                  : 'Apply Filters',
                              key: ValueKey(tempActiveCount),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedChip(
      {required String label,
      required bool isSelected,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 14, color: Colors.white),
              const SizedBox(width: 5)
            ],
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Home>(
      builder: (context, home, _) {
        final category = _getCategory(home);

        if (category == null) {
          return Scaffold(
            appBar: AppBar(
                backgroundColor: AppColors.primaryOrangeColor,
                foregroundColor: Colors.white,
                title: const Text('Category')),
            body: const Center(child: Text('Category not found')),
          );
        }

        final subs = category.subcategories;

        if (subs.isEmpty) {
          return Scaffold(
            appBar: AppBar(
                title: Text(category.name),
                backgroundColor: AppColors.primaryOrangeColor,
                foregroundColor: Colors.white),
            body: const Center(child: Text('No subcategories available')),
          );
        }

        if (_selectedSubIndex >= subs.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedSubIndex = 0;
              _selectedSubSubIndex =
                  subs[0].subSubCategories.isNotEmpty ? 1 : 0;
            });
          });
        }

        final safeSubIndex = _selectedSubIndex.clamp(0, subs.length - 1);
        final currentProducts = _getAllCurrentProducts(category);
        final visibleProducts = _getVisibleProducts(category);
        final hasFilters = _hasActiveFilters(currentProducts);
        final filterCount = _getActiveFilterCount(currentProducts);
        final dynamicMax = _getDynamicMaxPrice(currentProducts);

        return Scaffold(
          appBar: AppBar(
              title: Text(category.name),
              backgroundColor: AppColors.primaryOrangeColor,
              foregroundColor: Colors.white),
          body: Row(
            children: [
              // Left sidebar - Subcategories
              Container(
                width: 70,
                color: Colors.grey.shade100,
                child: ListView.builder(
                  itemCount: subs.length,
                  itemBuilder: (_, i) {
                    final sub = subs[i];
                    final isSubSelected = i == safeSubIndex;
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() {
                            _selectedSubIndex = i;
                            _selectedSubSubIndex =
                                subs[i].subSubCategories.isNotEmpty ? 1 : 0;
                            _minPrice = 0;
                            _maxPrice = 10000;
                            _selectedBrand = null;
                            _selectedWeight = null;
                          }),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 6),
                            decoration: BoxDecoration(
                              color: isSubSelected
                                  ? AppColors.primaryOrangeColor
                                      .withOpacity(0.12)
                                  : Colors.transparent,
                              border: Border(
                                left: BorderSide(
                                  color: isSubSelected
                                      ? AppColors.primaryOrangeColor
                                      : Colors.transparent,
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                if (sub.image.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(sub.image,
                                        height: 40,
                                        width: 55,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                            Icons.category,
                                            size: 30,
                                            color: Colors.grey.shade400)),
                                  )
                                else
                                  Icon(Icons.category,
                                      size: 30, color: Colors.grey.shade400),
                                const SizedBox(height: 4),
                                Text(sub.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSubSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSubSelected
                                            ? AppColors.primaryOrangeColor
                                            : Colors.grey.shade700)),
                              ],
                            ),
                          ),
                        ),
                        if (isSubSelected && sub.subSubCategories.isNotEmpty)
                          ...List.generate(
                              sub.subSubCategories.length,
                              (j) => _buildSubSubItem(
                                    label: sub.subSubCategories[j].name,
                                    image: sub.subSubCategories[j].image,
                                    isSelected: _selectedSubSubIndex == j + 1,
                                    onTap: () => setState(
                                        () => _selectedSubSubIndex = j + 1),
                                  )),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 4),

                    AdvertisingBannerCarousel(
                      height: 100,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      filterByReferenceName: category.name,
                      filterByBannerTypes: const ['category-page', 'category'],
                    ),

                    if (_getSelectedSub(category) != null &&
                        _getSelectedSub(category)!.name.isNotEmpty &&
                        _getSelectedSub(category)!.name != category.name)
                      const SizedBox(height: 4),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.grey.shade100, width: 1)),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => _showFilterSheet(
                                  context, category, currentProducts),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: hasFilters
                                      ? AppColors.primaryOrangeColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: hasFilters
                                          ? AppColors.primaryOrangeColor
                                          : Colors.grey.shade300),
                                  boxShadow: hasFilters
                                      ? [
                                          BoxShadow(
                                              color: AppColors
                                                  .primaryOrangeColor
                                                  .withOpacity(0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2))
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.tune_rounded,
                                        size: 15,
                                        color: hasFilters
                                            ? Colors.white
                                            : Colors.black87),
                                    const SizedBox(width: 5),
                                    Text('Filter',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: hasFilters
                                                ? Colors.white
                                                : Colors.black87)),
                                    if (hasFilters) ...[
                                      const SizedBox(width: 5),
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                        alignment: Alignment.center,
                                        child: Text('$filterCount',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors
                                                    .primaryOrangeColor)),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            if (hasFilters) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => _resetFilters(currentProducts),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.shade300)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.close,
                                          size: 13,
                                          color: Colors.grey.shade600),
                                      const SizedBox(width: 3),
                                      Text('Clear all',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 6),
                            if (_minPrice > 0 || _maxPrice < dynamicMax)
                              _buildActiveChip(
                                  Icons.currency_rupee,
                                  '₹${_minPrice.toInt()}-₹${_maxPrice.toInt()}',
                                  AppColors.primaryOrangeColor,
                                  onRemove: () => setState(() {
                                        _minPrice = 0;
                                        _maxPrice = dynamicMax;
                                      })),
                            if (_selectedBrand != null)
                              _buildActiveChip(Icons.storefront_outlined,
                                  _selectedBrand!, AppColors.primaryOrangeColor,
                                  onRemove: () =>
                                      setState(() => _selectedBrand = null)),
                            if (_selectedWeight != null)
                              _buildActiveChip(Icons.scale_outlined,
                                  _selectedWeight!, const Color(0xFF2E7D32),
                                  onRemove: () =>
                                      setState(() => _selectedWeight = null)),
                          ],
                        ),
                      ),
                    ),

                    // Filter count message
                    if (hasFilters)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        color: Colors.orange.shade50,
                        child: Text(
                          '${visibleProducts.length} product${visibleProducts.length == 1 ? '' : 's'} found',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryOrangeColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),

                    // Product grid
                    Expanded(
                      child: visibleProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off,
                                      size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text('No products found',
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 6),
                                  TextButton(
                                    onPressed: () =>
                                        _resetFilters(currentProducts),
                                    child: Text('Clear filters',
                                        style: TextStyle(
                                            color:
                                                AppColors.primaryOrangeColor)),
                                  ),
                                ],
                              ),
                            )
                          : MasonryGridView.count(
                              padding: const EdgeInsets.all(10),
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              itemCount: visibleProducts.length,
                              itemBuilder: (_, i) => _ProductTile(
                                product: visibleProducts[i],
                                home: home,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: home.hasItems
              ? const BottomStickyContainer()
              : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildActiveChip(IconData icon, String label, Color color,
      {required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(Icons.close, size: 9, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSubItem(
      {required String label,
      String? image,
      required bool isSelected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(left: 8, top: 1, bottom: 1),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? _subSubColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _subSubColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            if (image != null && image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(image,
                    height: 32,
                    width: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.grid_view,
                        size: 20,
                        color:
                            isSelected ? _subSubColor : Colors.grey.shade400)),
              )
            else
              Icon(Icons.grid_view,
                  size: 20,
                  color: isSelected ? _subSubColor : Colors.grey.shade400),
            const SizedBox(height: 3),
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? _subSubColor : Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final Home home;

  const _ProductTile({required this.product, required this.home});

  bool _isValidImage(String? url) =>
      url != null && url.trim().isNotEmpty && url.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final quantity = home.getQuantity(product.id);

    double getDisplayPrice() {
      if (quantity > 0) {
        final range = product.getDiscountRangeForQuantity(quantity);
        if (range != null && range.price > 0) return range.price;
      }
      return product.salePrice;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      ProductDetailScreenSimple(productId: product.id))),
          child: Container(
            width: constraints.maxWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 140,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(7),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 5,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: _isValidImage(product.imagePath)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  product.imagePath,
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => _placeholder(),
                                ),
                              )
                            : _placeholder(),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: WishlistButton(
                          productId: product.id,
                          productType: product.source,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(product.name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                              height: 1.25)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.weight != null
                                  ? '${product.weight!.value} ${product.weight!.unit}'
                                  : '',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          quantity == 0
                              ? GestureDetector(
                                  onTap: () {
                                    home.incrementQuantity(product.id);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF003D73),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Add',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF003D73),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          home.decrementQuantity(product.id);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 8,
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '$quantity',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          home.incrementQuantity(product.id);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 8,
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '₹${getDisplayPrice().toInt()}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.black),
                          ),
                          const SizedBox(width: 4),
                          if (product.mrp > product.salePrice)
                            Flexible(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                runSpacing: 2,
                                children: [
                                  Text('₹${product.mrp.toInt()}',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade500,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationThickness: 2)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Text(
                                      '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                                      style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => showBulkDiscountPopup(
                          context,
                          product.bulkPricing,
                          product,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.15),
                            ),
                          ),
                          child: Text(
                            'See Bulk Price',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _placeholder() => Center(
      child: Icon(Icons.image_outlined, size: 28, color: Colors.grey.shade200));
}
