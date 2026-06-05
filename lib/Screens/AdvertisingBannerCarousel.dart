import 'dart:async';
import 'dart:convert';
import 'package:e_commerce/Models/public_model.dart';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:e_commerce/UI/Widgets/Atoms/asdfg.dart';
import 'package:e_commerce/UI/Widgets/similar/productDetailScreenSimple.dart';
import 'package:e_commerce/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AdvertisingBannerCarousel extends StatefulWidget {
  final double height;
  final EdgeInsetsGeometry margin;
  final String? filterByReferenceName;
  final List<String>? filterByBannerTypes;

  const AdvertisingBannerCarousel({
    super.key,
    this.height = 100,
    this.margin = const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
    this.filterByReferenceName,
    this.filterByBannerTypes,
  });

  @override
  State<AdvertisingBannerCarousel> createState() =>
      _AdvertisingBannerCarouselState();
}

class _AdvertisingBannerCarouselState extends State<AdvertisingBannerCarousel> {
  List<BannerItem> _banners = [];
  bool _loading = true;
  bool _hasError = false;
  final PageController _pageController = PageController(viewportFraction: 0.95);
  int _currentPage = 0;
  Timer? _timer;

  static const String _apiUrl =
      'https://grocerrybackend.onrender.com/api/advertising-banner';

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List data = json['data'] ?? [];

        final items = data.where((b) {
          final isActive = b['status'] == 'active';
          final hasImage = (b['image'] ?? '').toString().isNotEmpty &&
              (b['image'] ?? '').toString().startsWith('http');

          final bannerRefName = (b['referenceName'] ?? '')
              .toString()
              .trim()
              .toLowerCase();
          final filterName =
              widget.filterByReferenceName?.toLowerCase().trim() ?? '';

          final matchesReference =
              filterName.isEmpty ? true : bannerRefName == filterName;

          final matchesBannerType = widget.filterByBannerTypes == null ||
              widget.filterByBannerTypes!.isEmpty
              ? true
              : widget.filterByBannerTypes!
                  .any((type) => type.toLowerCase() ==
                      (b['bannerType'] ?? '').toString().toLowerCase());

          return isActive && hasImage && matchesReference && matchesBannerType;
        }).map((b) {
          String referenceId = '';

          if (b['referenceId'] != null) {
            if (b['referenceId'] is Map) {
              referenceId = b['referenceId']['_id']?.toString() ?? '';
            } else {
              referenceId = b['referenceId'].toString();
            }
          }

          return BannerItem(
            image: b['image']?.toString() ?? '',
            title: b['title']?.toString() ?? '',
            redirectUrl: b['redirectUrl']?.toString() ?? '',
            bannerType: b['bannerType']?.toString() ?? '',
            referenceId: referenceId,
            referenceName: b['referenceName']?.toString() ?? '',
            redirectType: b['redirectType']?.toString() ?? '',
          );
        }).toList();

        if (mounted) {
          setState(() {
            _banners = items;
            _loading = false;
          });

          if (items.length > 1) _startAutoScroll();
        }
      } else {
        _setError();
      }
    } catch (e) {
      print('Error fetching banners: $e');
      _setError();
    }
  }

  void _setError() {
    if (mounted) setState(() {
      _loading = false;
      _hasError = true;
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _banners.isEmpty) return;
      final next = (_currentPage + 1) % _banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 800),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && _banners.isEmpty) return const SizedBox.shrink();
    if (_hasError) return const SizedBox.shrink();

    if (_loading) {
      return Container(
        margin: widget.margin,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: widget.margin,
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _BannerTile(
              banner: _banners[i],
              height: widget.height,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (_banners.length > 1)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _banners.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: _currentPage == index ? 12 : 6,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _currentPage == index
                        ? AppColors.primaryOrangeColor
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _BannerTile extends StatelessWidget {
  final BannerItem banner;
  final double height;
  final EdgeInsetsGeometry margin;
  final BorderRadius borderRadius;

  const _BannerTile({
    required this.banner,
    required this.height,
    required this.margin,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _handleNavigation(context);
      },
      child: Container(
        margin: margin,
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Image.network(
            banner.image,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey.shade50,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(strokeWidth: 2),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade100,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image, size: 36, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context) {
    try {
      final home = Provider.of<Home>(context, listen: false);
      
      print('=== BANNER NAVIGATION ===');
      print('Banner Type: ${banner.bannerType}');
      print('Reference ID: ${banner.referenceId}');
      print('Reference Name: ${banner.referenceName}');
      print('Redirect Type: ${banner.redirectType}');
      
      switch (banner.bannerType.toLowerCase()) {
        case "product":
          if (banner.referenceId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreenSimple(
                  productId: banner.referenceId,
                ),
              ),
            );
          } else {
            _showError(context, 'Product not available');
          }
          break;

        case "category":
        case "category-page":
        case "home-category":
          // Try by referenceName first (since your API has "Fruits")
          if (banner.referenceName.isNotEmpty) {
            _navigateToCategoryByName(context, home, banner.referenceName);
          } 
          // Then try by referenceId
          else if (banner.referenceId.isNotEmpty) {
            _navigateToCategory(context, home, banner.referenceId);
          } 
          else {
            _showError(context, 'Category not available');
          }
          break;

        case "url":
          if (banner.redirectUrl.isNotEmpty) {
            print('Opening URL: ${banner.redirectUrl}');
            // Add url_launcher package if needed
          } else {
            _showError(context, 'Link not available');
          }
          break;

        default:
          _showError(context, 'Coming soon');
      }
    } catch (e) {
      print('Navigation error: $e');
      _showError(context, 'Something went wrong');
    }
  }

  void _navigateToCategory(BuildContext context, Home home, String referenceId) {
    print('Searching category by ID: $referenceId');
    
    AppCategory? targetCategory;
    
    for (final category in home.appCategories) {
      if (category.id == referenceId) {
        targetCategory = category;
        break;
      }
      
      for (final sub in category.subcategories) {
        if (sub.id == referenceId) {
          targetCategory = category;
          break;
        }
        for (final subSub in sub.subSubCategories) {
          if (subSub.id == referenceId) {
            targetCategory = category;
            break;
          }
        }
        if (targetCategory != null) break;
      }
      if (targetCategory != null) break;
    }
    
    if (targetCategory != null) {
      print('Found category: ${targetCategory.name}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubCategoryScreen(categoryId: targetCategory!.id),
        ),
      );
    } else {
      print('Category not found for ID: $referenceId');
      _showError(context, 'Category not found');
    }
  }

  void _navigateToCategoryByName(BuildContext context, Home home, String name) {
    print('Searching category by name: $name');
    
    // Find category by name (case-insensitive)
    AppCategory? foundCategory;
    
    for (final category in home.appCategories) {
      if (category.name.toLowerCase() == name.toLowerCase()) {
        foundCategory = category;
        break;
      }
      
      // Check subcategories
      for (final sub in category.subcategories) {
        if (sub.name.toLowerCase() == name.toLowerCase()) {
          foundCategory = category;
          break;
        }
        // Check sub-sub categories
        for (final subSub in sub.subSubCategories) {
          if (subSub.name.toLowerCase() == name.toLowerCase()) {
            foundCategory = category;
            break;
          }
        }
        if (foundCategory != null) break;
      }
      if (foundCategory != null) break;
    }
    
    if (foundCategory != null) {
      print('Found category: ${foundCategory.name} with ID: ${foundCategory.id}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubCategoryScreen(categoryId: foundCategory!.id),
        ),
      );
    } else {
      print('Category not found for name: $name');
      _showError(context, 'Category "$name" not found');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class BannerItem {
  final String image;
  final String title;
  final String redirectUrl;
  final String bannerType;
  final String referenceId;
  final String referenceName;
  final String redirectType;

  const BannerItem({
    required this.image,
    required this.title,
    required this.redirectUrl,
    required this.bannerType,
    required this.referenceId,
    this.referenceName = '',
    this.redirectType = '',
  });
}
// import 'dart:async';
// import 'dart:convert';
// import 'package:e_commerce/Models/public_model.dart';
// import 'package:e_commerce/Services/Providers/product_provider.dart';
// import 'package:e_commerce/UI/Widgets/Atoms/asdfg.dart';
// import 'package:e_commerce/UI/Widgets/similar/productDetailScreenSimple.dart';
// import 'package:e_commerce/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';

// class AdvertisingBannerCarousel extends StatefulWidget {
//   final double height;
//   final EdgeInsetsGeometry margin;
//   final String? filterByReferenceName;
//   final List<String>? filterByBannerTypes;

//   const AdvertisingBannerCarousel({
//     super.key,
//     this.height = 100,
//     this.margin = const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
//     this.filterByReferenceName,
//     this.filterByBannerTypes,
//   });

//   @override
//   State<AdvertisingBannerCarousel> createState() =>
//       _AdvertisingBannerCarouselState();
// }

// class _AdvertisingBannerCarouselState extends State<AdvertisingBannerCarousel> {
//   List<BannerItem> _banners = [];
//   bool _loading = true;
//   bool _hasError = false;
//   final PageController _pageController = PageController(viewportFraction: 0.95);
//   int _currentPage = 0;
//   Timer? _timer;

//   static const String _apiUrl =
//       'https://grocerrybackend.onrender.com/api/advertising-banner';

//   @override
//   void initState() {
//     super.initState();
//     _fetchBanners();
//   }

//   Future<void> _fetchBanners() async {
//     try {
//       final response = await http.get(Uri.parse(_apiUrl));

//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);
//         final List data = json['data'] ?? [];

//         final items = data.where((b) {
//           final isActive = b['status'] == 'active';
//           final hasImage = (b['image'] ?? '').toString().isNotEmpty &&
//               (b['image'] ?? '').toString().startsWith('http');

//           final bannerRefName = (b['referenceName'] ?? '')
//               .toString()
//               .trim()
//               .toLowerCase();
//           final filterName =
//               widget.filterByReferenceName?.toLowerCase().trim() ?? '';

//           final matchesReference =
//               filterName.isEmpty ? true : bannerRefName == filterName;

//           final matchesBannerType = widget.filterByBannerTypes == null ||
//               widget.filterByBannerTypes!.isEmpty
//               ? true
//               : widget.filterByBannerTypes!
//                   .any((type) => type.toLowerCase() ==
//                       (b['bannerType'] ?? '').toString().toLowerCase());

//           return isActive && hasImage && matchesReference && matchesBannerType;
//         }).map((b) {
//           String referenceId = '';

//           if (b['referenceId'] != null) {
//             if (b['referenceId'] is Map) {
//               referenceId = b['referenceId']['_id']?.toString() ?? '';
//             } else {
//               referenceId = b['referenceId'].toString();
//             }
//           }

//           return BannerItem(
//             image: b['image']?.toString() ?? '',
//             title: b['title']?.toString() ?? '',
//             redirectUrl: b['redirectUrl']?.toString() ?? '',
//             bannerType: b['bannerType']?.toString() ?? '',
//             referenceId: referenceId,
//             referenceName: b['referenceName']?.toString() ?? '',
//             redirectType: b['redirectType']?.toString() ?? '',
//           );
//         }).toList();

//         if (mounted) {
//           setState(() {
//             _banners = items;
//             _loading = false;
//           });

//           if (items.length > 1) _startAutoScroll();
//         }
//       } else {
//         _setError();
//       }
//     } catch (e) {
//       _setError();
//     }
//   }

//   void _setError() {
//     if (mounted) setState(() {
//       _loading = false;
//       _hasError = true;
//     });
//   }

//   void _startAutoScroll() {
//     _timer = Timer.periodic(const Duration(seconds: 4), (_) {
//       if (!mounted || _banners.isEmpty) return;
//       final next = (_currentPage + 1) % _banners.length;
//       _pageController.animateToPage(
//         next,
//         duration: const Duration(milliseconds: 800),
//         curve: Curves.fastOutSlowIn,
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_loading && _banners.isEmpty) return const SizedBox.shrink();
//     if (_hasError) return const SizedBox.shrink();

//     if (_loading) {
//       return Container(
//         margin: widget.margin,
//         height: widget.height,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: const Center(
//           child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
//         ),
//       );
//     }

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           margin: widget.margin,
//           height: widget.height,
//           child: PageView.builder(
//             controller: _pageController,
//             itemCount: _banners.length,
//             onPageChanged: (i) => setState(() => _currentPage = i),
//             itemBuilder: (_, i) => _BannerTile(
//               banner: _banners[i],
//               height: widget.height,
//               margin: const EdgeInsets.symmetric(horizontal: 5),
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//         if (_banners.length > 1)
//           Container(
//             margin: const EdgeInsets.only(top: 4),
//             height: 4,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(
//                 _banners.length,
//                 (index) => Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 2),
//                   width: _currentPage == index ? 12 : 6,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(2),
//                     color: _currentPage == index
//                         ? AppColors.primaryOrangeColor
//                         : Colors.grey.shade300,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         const SizedBox(height: 4),
//       ],
//     );
//   }
// }

// class _BannerTile extends StatelessWidget {
//   final BannerItem banner;
//   final double height;
//   final EdgeInsetsGeometry margin;
//   final BorderRadius borderRadius;

//   const _BannerTile({
//     required this.banner,
//     required this.height,
//     required this.margin,
//     required this.borderRadius,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         _handleNavigation(context);
//       },
//       child: Container(
//         margin: margin,
//         height: height,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: borderRadius,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: borderRadius,
//           child: Image.network(
//             banner.image,
//             width: double.infinity,
//             height: height,
//             fit: BoxFit.cover,
//             loadingBuilder: (_, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return Container(
//                 color: Colors.grey.shade50,
//                 alignment: Alignment.center,
//                 child: const CircularProgressIndicator(strokeWidth: 2),
//               );
//             },
//             errorBuilder: (_, __, ___) => Container(
//               color: Colors.grey.shade100,
//               alignment: Alignment.center,
//               child: const Icon(Icons.broken_image, size: 36, color: Colors.grey),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleNavigation(BuildContext context) {
//     try {
//       final home = Provider.of<Home>(context, listen: false);
      
//       switch (banner.bannerType.toLowerCase()) {
//         case "product":
//           if (banner.referenceId.isNotEmpty) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => ProductDetailScreenSimple(
//                   productId: banner.referenceId,
//                 ),
//               ),
//             );
//           } else {
//             _showError(context, 'Product not available');
//           }
//           break;

//         case "category":
//         case "category-page":
//         case "home-category":
//           if (banner.referenceName.isNotEmpty) {
//             _navigateToCategoryByName(context, home, banner.referenceName);
//           } else if (banner.referenceId.isNotEmpty) {
//             _navigateToCategory(context, home, banner.referenceId);
//           } else {
//             _showError(context, 'Category not available');
//           }
//           break;

//         case "url":
//           if (banner.redirectUrl.isNotEmpty) {
//             // Add url_launcher package if needed
//           } else {
//             _showError(context, 'Link not available');
//           }
//           break;

//         default:
//           _showError(context, 'Coming soon');
//       }
//     } catch (e) {
//       _showError(context, 'Something went wrong');
//     }
//   }

//   void _navigateToCategory(BuildContext context, Home home, String referenceId) {
//     AppCategory? targetCategory;
    
//     for (final category in home.appCategories) {
//       if (category.id == referenceId) {
//         targetCategory = category;
//         break;
//       }
      
//       for (final sub in category.subcategories) {
//         if (sub.id == referenceId) {
//           targetCategory = category;
//           break;
//         }
//         for (final subSub in sub.subSubCategories) {
//           if (subSub.id == referenceId) {
//             targetCategory = category;
//             break;
//           }
//         }
//         if (targetCategory != null) break;
//       }
//       if (targetCategory != null) break;
//     }
    
//     if (targetCategory != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => SubCategoryScreen(categoryId: targetCategory!.id),
//         ),
//       );
//     } else {
//       _showError(context, 'Category not found');
//     }
//   }

//   void _navigateToCategoryByName(BuildContext context, Home home, String name) {
//     final category = home.appCategories.firstWhere(
//       (c) => c.name.toLowerCase() == name.toLowerCase(),
//       orElse: () => null as AppCategory,
//     );
    
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => SubCategoryScreen(categoryId: category.id),
//       ),
//     );
//     }

//   void _showError(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }

// class BannerItem {
//   final String image;
//   final String title;
//   final String redirectUrl;
//   final String bannerType;
//   final String referenceId;
//   final String referenceName;
//   final String redirectType;

//   const BannerItem({
//     required this.image,
//     required this.title,
//     required this.redirectUrl,
//     required this.bannerType,
//     required this.referenceId,
//     this.referenceName = '',
//     this.redirectType = '',
//   });
// }