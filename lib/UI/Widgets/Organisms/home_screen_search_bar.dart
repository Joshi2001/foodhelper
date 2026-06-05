import 'dart:async';
import 'package:e_commerce/Services/api/apiservice.dart';
import 'package:e_commerce/UI/Widgets/similar/productDetailScreenSimple.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../../app_colors.dart';
import '../../../Models/product.dart';
import '../../custom_sliver_delegate.dart';

class HomeScreenSearchBar extends StatefulWidget {
  final ApiService apiService;

  const HomeScreenSearchBar({super.key, required this.apiService});

  @override
  State<HomeScreenSearchBar> createState() => _HomeScreenSearchBarState();
}

class _HomeScreenSearchBarState extends State<HomeScreenSearchBar> {
  final List<String> hints = [
    "Search 'atta'",
    "Search 'sugar'",
    "Search 'oil'",
    "Search 'bread'",
    "Search 'milk'",
  ];

  int hintIndex = 0;
  late Timer hintTimer;

  late stt.SpeechToText speech;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  bool isListening = false;

  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  bool isSearching = false;
  bool showDropdown = false;
  bool isLoading = true;

  OverlayEntry? _overlayEntry;
  final GlobalKey _searchBarKey = GlobalKey();
  
  // Add this to track if overlay is visible
  bool _isOverlayVisible = false;

  @override
  void initState() {
    super.initState();

    hintTimer = Timer.periodic(Duration(seconds: 3), (_) {
      if (!isSearching && mounted) {
        setState(() => hintIndex = (hintIndex + 1) % hints.length);
      }
    });

    speech = stt.SpeechToText();
    searchController.addListener(_onSearchChanged);

    searchFocusNode.addListener(() {
      if (searchFocusNode.hasFocus && searchController.text.isNotEmpty) {
        _showDropdownOverlay();
      } else if (!searchFocusNode.hasFocus) {
        _removeOverlay();
      }
    });

    _loadAllProducts();
  }

  void _showDropdownOverlay() {
    // Don't show if already visible
    if (_isOverlayVisible) return;
    
    _removeOverlay();

    if (!mounted || searchController.text.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        final RenderBox? renderBox =
            _searchBarKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox == null) return;

        final Offset offset = renderBox.localToGlobal(Offset.zero);
        final double height = renderBox.size.height;

        _overlayEntry = OverlayEntry(
          builder: (context) => _buildDropdownOverlay(offset, height),
        );

        Overlay.of(context).insert(_overlayEntry!);
        _isOverlayVisible = true;
      } catch (e) {
        debugPrint("Error showing overlay: $e");
      }
    });
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOverlayVisible = false;
    }
  }

  Widget _buildDropdownOverlay(Offset offset, double searchBarHeight) {
    return GestureDetector(
      // This will catch taps outside the dropdown
      onTap: () {
        _removeOverlay();
        searchFocusNode.unfocus();
      },
      child: Stack(
        children: [
          // Transparent background to capture taps outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _removeOverlay();
                searchFocusNode.unfocus();
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Dropdown content
          Positioned(
            top: offset.dy + searchBarHeight + 5,
            left: offset.dx + 16,
            right: offset.dx + 72,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(14),
              shadowColor: Colors.black12,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 280),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : _buildDropdownList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadAllProducts() async {
    try {
      setState(() => isLoading = true);
      final products = await widget.apiService.getAllProducts();
      if (mounted) {
        setState(() {
          allProducts = products;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      debugPrint("❌ Search load failed: $e");
    }
  }

  void _onSearchChanged() {
    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        showDropdown = false;
        filteredProducts = [];
      });
      _removeOverlay();
      return;
    }

    final startsWith = allProducts
        .where((p) => p.name.toLowerCase().startsWith(query))
        .toList();

    final contains = allProducts
        .where((p) =>
            p.name.toLowerCase().contains(query) &&
            !p.name.toLowerCase().startsWith(query))
        .toList();

    setState(() {
      isSearching = true;
      filteredProducts = [...startsWith, ...contains];
      showDropdown = true;
    });

    if (searchFocusNode.hasFocus) {
      if (_overlayEntry != null) {
        _overlayEntry!.markNeedsBuild();
      } else {
        _showDropdownOverlay();
      }
    }
  }

  void _onProductSelected(Product product) async {
    // Remove overlay immediately
    _removeOverlay();
    
    // Clear focus
    searchFocusNode.unfocus();
    FocusScope.of(context).unfocus();
    
    // Clear text
    searchController.clear();
    
    // Reset state
    if (mounted) {
      setState(() {
        showDropdown = false;
        isSearching = false;
        filteredProducts = [];
      });
    }
    
    // Small delay to ensure overlay is completely removed
    await Future.delayed(Duration(milliseconds: 100));
    
    // Navigate
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailScreenSimple(
            productId: product.id,
          ),
        ),
      );
    }
  }

  void toggleListening() async {
    if (!isListening) {
      try {
        bool available = await speech.initialize(
          onStatus: (status) {
            debugPrint("Speech status: $status");

            if (status == "done" || status == "notListening") {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _closeDialogSafely();
                if (mounted) {
                  setState(() => isListening = false);
                }
              });
            }
          },
          onError: (error) {
            debugPrint("Speech error: $error");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _closeDialogSafely();
              if (mounted) {
                setState(() => isListening = false);
              }
            });
          },
        );

        if (available && mounted) {
          setState(() => isListening = true);
          _showListeningDialog();

          speech.listen(
            onResult: (result) {
              if (mounted) {
                setState(() {
                  searchController.text = result.recognizedWords;
                });
              }

              if (result.finalResult) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _closeDialogSafely();
                  if (mounted) {
                    setState(() => isListening = false);
                  }
                  speech.stop();
                });
              }
            },
            listenOptions: stt.SpeechListenOptions(
              listenMode: stt.ListenMode.search,
              partialResults: true,
            ),
          );
        }
      } catch (e) {
        debugPrint("Speech initialization error: $e");
        if (mounted) {
          setState(() => isListening = false);
        }
      }
    } else {
      if (mounted) {
        setState(() => isListening = false);
      }
      speech.stop();
      _closeDialogSafely();
    }
  }

  void _closeDialogSafely() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final navigator = Navigator.of(context, rootNavigator: true);
        if (navigator.canPop()) {
          navigator.pop();
        }
      }
    });
  }

  @override
  void dispose() {
    hintTimer.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    searchFocusNode.dispose();
    _removeOverlay();

    if (isListening) {
      speech.stop();
    }
    speech.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
        minHeight: 60,
        maxHeight: 60,
        child: Container(
          key: _searchBarKey,
          color: Color(0xFFFFF3E0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(child: _buildSearchField()),
              const SizedBox(width: 10),
              _buildMicButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: toggleListening,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isListening
              ? Colors.red.withOpacity(0.25)
              : Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: isListening
                ? Colors.red.withOpacity(0.5)
                : Colors.white.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Icon(
          isListening ? Icons.mic : Icons.mic_none_rounded,
          color: Colors.black,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextFormField(
      controller: searchController,
      focusNode: searchFocusNode,
      style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
      textInputAction: TextInputAction.search,
      onFieldSubmitted: (_) {
        searchFocusNode.unfocus();
        _removeOverlay();
        setState(() => showDropdown = false);
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        prefixIcon: isLoading
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryOrangeColor,
                  ),
                ),
              )
            : Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close_rounded,
                    color: Colors.grey.shade400, size: 18),
                onPressed: () {
                  searchController.clear();
                  _removeOverlay();
                  setState(() {
                    showDropdown = false;
                    isSearching = false;
                    filteredProducts = [];
                  });
                },
              )
            : null,
        hint: isSearching
            ? null
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Row(
                  key: ValueKey(hintIndex),
                  children: [
                    TypewriterAnimatedTextKit(
                      key: ValueKey(hints[hintIndex]),
                      text: [hints[hintIndex]],
                      speed: const Duration(milliseconds: 80),
                      repeatForever: false,
                      textStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primaryOrangeColor.withOpacity(0.5),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownList() {
    final query = searchController.text.trim().toLowerCase();
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: filteredProducts.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: Colors.grey.shade100,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onProductSelected(product),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.imagePath.isNotEmpty
                      ? Image.network(
                          product.imagePath,
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _productIconBox(),
                        )
                      : _productIconBox(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHighlightedText(product.name, query),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "₹${product.salePrice.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryOrangeColor,
                            ),
                          ),
                          if (product.weight != null) ...[
                            Text(
                              " ${product.weight!.value}${product.weight!.unit}",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                          if (product.category_name.isNotEmpty) ...[
                            SizedBox(
                              width: 80,
                              child: Text(
                                product.category_name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade400,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.north_west_rounded,
                    size: 14, color: Colors.grey.shade300),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _productIconBox() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primaryOrangeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.shopping_basket_outlined,
        color: AppColors.primaryOrangeColor,
        size: 20,
      ),
    );
  }

  Widget _buildHighlightedText(String name, String query) {
    final lowerName = name.toLowerCase();
    final matchIndex = lowerName.indexOf(query);

    if (matchIndex == -1 || query.isEmpty) {
      return Text(
        name,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade800,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        children: [
          if (matchIndex > 0)
            TextSpan(
              text: name.substring(0, matchIndex),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600),
            ),
          TextSpan(
            text: name.substring(matchIndex, matchIndex + query.length),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryOrangeColor,
            ),
          ),
          if (matchIndex + query.length < name.length)
            TextSpan(
              text: name.substring(matchIndex + query.length),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search_off_rounded, color: Colors.grey.shade300, size: 20),
          const SizedBox(width: 10),
          Text(
            "No products found",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showListeningDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic, color: Colors.red, size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Listening...",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  "Speak the product name",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() => isListening = false);
      }
    });
  }
}
// import 'dart:async';
// import 'package:e_commerce/Services/api/apiservice.dart';
// import 'package:e_commerce/UI/Widgets/similar/productDetailScreenSimple.dart';
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:animated_text_kit/animated_text_kit.dart';
// import '../../../app_colors.dart';
// import '../../../Models/product.dart';
// import '../../custom_sliver_delegate.dart';

// class HomeScreenSearchBar extends StatefulWidget {
//   final ApiService apiService;

//   const HomeScreenSearchBar({super.key, required this.apiService});

//   @override
//   State<HomeScreenSearchBar> createState() => _HomeScreenSearchBarState();
// }

// class _HomeScreenSearchBarState extends State<HomeScreenSearchBar> {
//   final List<String> hints = [
//     "Search 'atta'",
//     "Search 'sugar'",
//     "Search 'oil'",
//     "Search 'bread'",
//     "Search 'milk'",
//   ];

//   int hintIndex = 0;
//   late Timer hintTimer;

//   late stt.SpeechToText speech;
//   final TextEditingController searchController = TextEditingController();
//   final FocusNode searchFocusNode = FocusNode();
//   bool isListening = false;

//   List<Product> allProducts = [];
//   List<Product> filteredProducts = [];
//   bool isSearching = false;
//   bool showDropdown = false;
//   bool isLoading = true;

//   OverlayEntry? _overlayEntry;
//   final GlobalKey _searchBarKey = GlobalKey(); // Add this key

//   @override
//   void initState() {
//     super.initState();

//     hintTimer = Timer.periodic(Duration(seconds: 3), (_) {
//       if (!isSearching && mounted) {
//         setState(() => hintIndex = (hintIndex + 1) % hints.length);
//       }
//     });

//     speech = stt.SpeechToText();
//     searchController.addListener(_onSearchChanged);

//     searchFocusNode.addListener(() {
//       if (searchFocusNode.hasFocus && searchController.text.isNotEmpty) {
//         _showDropdownOverlay();
//       } else if (!searchFocusNode.hasFocus) {
//         _removeOverlay();
//       }
//     });

//     _loadAllProducts();
//   }

//   void _showDropdownOverlay() {
//     _removeOverlay();

//     if (!mounted || searchController.text.isEmpty) return;

//     // Use addPostFrameCallback to ensure the widget is built
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;

//       try {
//         // Get the position of the search bar using the global key
//         final RenderBox? renderBox =
//             _searchBarKey.currentContext?.findRenderObject() as RenderBox?;
//         if (renderBox == null) return;

//         final Offset offset = renderBox.localToGlobal(Offset.zero);
//         final double height = renderBox.size.height;

//         _overlayEntry = OverlayEntry(
//           builder: (context) => _buildDropdownOverlay(offset, height),
//         );

//         Overlay.of(context).insert(_overlayEntry!);
//       } catch (e) {
//         debugPrint("Error showing overlay: $e");
//       }
//     });
//   }

//   void _removeOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }

//   Widget _buildDropdownOverlay(Offset offset, double searchBarHeight) {
//     return Positioned(
//       top:
//           offset.dy + searchBarHeight + 5, // Position just below the search bar
//       left: offset.dx + 16,
//       right: offset.dx + 72, // Account for mic button
//       child: Material(
//         elevation: 8,
//         borderRadius: BorderRadius.circular(14),
//         shadowColor: Colors.black12,
//         child: Container(
//           constraints: const BoxConstraints(maxHeight: 280),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: Colors.grey.shade100),
//           ),
//           child: filteredProducts.isEmpty
//               ? _buildEmptyState()
//               : _buildDropdownList(),
//         ),
//       ),
//     );
//   }

//   Future<void> _loadAllProducts() async {
//     try {
//       setState(() => isLoading = true);
//       final products = await widget.apiService.getAllProducts();
//       if (mounted) {
//         setState(() {
//           allProducts = products;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) setState(() => isLoading = false);
//       debugPrint("❌ Search load failed: $e");
//     }
//   }

//   void _onSearchChanged() {
//     final query = searchController.text.trim().toLowerCase();

//     if (query.isEmpty) {
//       setState(() {
//         isSearching = false;
//         showDropdown = false;
//         filteredProducts = [];
//       });
//       _removeOverlay();
//       return;
//     }

//     // starts-with pehle aayenge, contains baad mein
//     final startsWith = allProducts
//         .where((p) => p.name.toLowerCase().startsWith(query))
//         .toList();

//     final contains = allProducts
//         .where((p) =>
//             p.name.toLowerCase().contains(query) &&
//             !p.name.toLowerCase().startsWith(query))
//         .toList();

//     setState(() {
//       isSearching = true;
//       filteredProducts = [...startsWith, ...contains];
//       showDropdown = true;
//     });

//     // Update or show overlay
//     if (searchFocusNode.hasFocus) {
//       if (_overlayEntry != null) {
//         _overlayEntry!.markNeedsBuild();
//       } else {
//         _showDropdownOverlay();
//       }
//     }
//   }

//   void _onProductSelected(Product product) {
//     // Close overlay first
//     _removeOverlay();

//     // Clear focus
//     searchFocusNode.unfocus();
//     FocusScope.of(context).unfocus();

//     // Clear text
//     searchController.clear();

//     // Update state
//     if (mounted) {
//       setState(() {
//         showDropdown = false;
//         isSearching = false;
//       });
//     }

//     // Navigate after a short delay
//     Future.delayed(Duration(milliseconds: 150), () {
//       if (mounted) {
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (_) => ProductDetailScreenSimple(
//               productId: product.id,
//             ),
//           ),
//         );
//       }
//     });
//   }

//   void toggleListening() async {
//     if (!isListening) {
//       try {
//         bool available = await speech.initialize(
//           onStatus: (status) {
//             debugPrint("Speech status: $status");

//             if (status == "done" || status == "notListening") {
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 _closeDialogSafely();
//                 if (mounted) {
//                   setState(() => isListening = false);
//                 }
//               });
//             }
//           },
//           onError: (error) {
//             debugPrint("Speech error: $error");
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _closeDialogSafely();
//               if (mounted) {
//                 setState(() => isListening = false);
//               }
//             });
//           },
//         );

//         if (available && mounted) {
//           setState(() => isListening = true);
//           _showListeningDialog();

//           speech.listen(
//             onResult: (result) {
//               if (mounted) {
//                 setState(() {
//                   searchController.text = result.recognizedWords;
//                 });
//               }

//               if (result.finalResult) {
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   _closeDialogSafely();
//                   if (mounted) {
//                     setState(() => isListening = false);
//                   }
//                   speech.stop();
//                 });
//               }
//             },
//             listenOptions: stt.SpeechListenOptions(
//               listenMode: stt.ListenMode.search,
//               partialResults: true,
//             ),
//           );
//         }
//       } catch (e) {
//         debugPrint("Speech initialization error: $e");
//         if (mounted) {
//           setState(() => isListening = false);
//         }
//       }
//     } else {
//       if (mounted) {
//         setState(() => isListening = false);
//       }
//       speech.stop();
//       _closeDialogSafely();
//     }
//   }

//   void _closeDialogSafely() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         final navigator = Navigator.of(context, rootNavigator: true);
//         if (navigator.canPop()) {
//           navigator.pop();
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     hintTimer.cancel();
//     searchController.removeListener(_onSearchChanged);
//     searchController.dispose();
//     searchFocusNode.dispose();
//     _removeOverlay();

//     if (isListening) {
//       speech.stop();
//     }
//     speech.cancel();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SliverPersistentHeader(
//       pinned: true,
//       delegate: SliverAppBarDelegate(
//         minHeight: 60,
//         maxHeight: 60,
//         child: Container(
//           key: _searchBarKey, // Add the key here
//           color:  Color(0xFFFFF3E0),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           child: Row(
//             children: [
//               Expanded(child: _buildSearchField()),
//               const SizedBox(width: 10),
//               _buildMicButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMicButton() {
//     return GestureDetector(
//       onTap: toggleListening,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: isListening
//               ? Colors.red.withOpacity(0.25)
//               : Colors.white.withOpacity(0.2),
//           shape: BoxShape.circle,
//           border: Border.all(
//             color: isListening
//                 ? Colors.red.withOpacity(0.5)
//                 : Colors.white.withOpacity(0.4),
//             width: 1.5,
//           ),
//         ),
//         child: Icon(
//           isListening ? Icons.mic : Icons.mic_none_rounded,
//           color: Colors.black,
//           size: 22,
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchField() {
//     return TextFormField(
//       controller: searchController,
//       focusNode: searchFocusNode,
//       style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
//       textInputAction: TextInputAction.search,
//       onFieldSubmitted: (_) {
//         searchFocusNode.unfocus();
//         _removeOverlay();
//         setState(() => showDropdown = false);
//       },
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: Colors.white,
//         isDense: true,
//         contentPadding: const EdgeInsets.symmetric(vertical: 10),
//         prefixIcon: isLoading
//             ? Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: AppColors.primaryOrangeColor,
//                   ),
//                 ),
//               )
//             : Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
//         suffixIcon: searchController.text.isNotEmpty
//             ? IconButton(
//                 icon: Icon(Icons.close_rounded,
//                     color: Colors.grey.shade400, size: 18),
//                 onPressed: () {
//                   searchController.clear();
//                   _removeOverlay();
//                   setState(() {
//                     showDropdown = false;
//                     isSearching = false;
//                   });
//                 },
//               )
//             : null,
//         hint: isSearching
//             ? null
//             : AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 300),
//                 child: Row(
//                   key: ValueKey(hintIndex),
//                   children: [
//                     TypewriterAnimatedTextKit(
//                       key: ValueKey(hints[hintIndex]),
//                       text: [hints[hintIndex]],
//                       speed: const Duration(milliseconds: 80),
//                       repeatForever: false,
//                       textStyle: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey.shade400,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(
//             color: AppColors.primaryOrangeColor.withOpacity(0.5),
//             width: 1.5,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdownList() {
//     final query = searchController.text.trim().toLowerCase();
//     return ListView.separated(
//       shrinkWrap: true,
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       itemCount: filteredProducts.length,
//       separatorBuilder: (_, __) => Divider(
//         height: 1,
//         color: Colors.grey.shade100,
//         indent: 16,
//         endIndent: 16,
//       ),
//       itemBuilder: (context, index) {
//         final product = filteredProducts[index];
//         return GestureDetector(
//           behavior: HitTestBehavior.opaque,
//           onTap: () => _onProductSelected(product),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: product.imagePath.isNotEmpty
//                       ? Image.network(
//                           product.imagePath,
//                           width: 42,
//                           height: 42,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) => _productIconBox(),
//                         )
//                       : _productIconBox(),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildHighlightedText(product.name, query),
//                       const SizedBox(height: 2),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Text(
//                             "₹${product.salePrice.toStringAsFixed(0)}",
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.primaryOrangeColor,
//                             ),
//                           ),
//                           if (product.weight != null) ...[
//                             Text(
//                               " ${product.weight!.value}${product.weight!.unit}",
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: Colors.grey.shade400,
//                               ),
//                             ),
//                           ],
//                           if (product.category_name.isNotEmpty) ...[
//                             SizedBox(
//                               width: 80,
//                               child: Text(
//                                 product.category_name,
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   color: Colors.grey.shade400,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 2,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Icon(Icons.north_west_rounded,
//                     size: 14, color: Colors.grey.shade300),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _productIconBox() {
//     return Container(
//       width: 42,
//       height: 42,
//       decoration: BoxDecoration(
//         color: AppColors.primaryOrangeColor.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Icon(
//         Icons.shopping_basket_outlined,
//         color: AppColors.primaryOrangeColor,
//         size: 20,
//       ),
//     );
//   }

//   Widget _buildHighlightedText(String name, String query) {
//     final lowerName = name.toLowerCase();
//     final matchIndex = lowerName.indexOf(query);

//     if (matchIndex == -1 || query.isEmpty) {
//       return Text(
//         name,
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//           color: Colors.grey.shade800,
//         ),
//       );
//     }

//     return RichText(
//       text: TextSpan(
//         children: [
//           if (matchIndex > 0)
//             TextSpan(
//               text: name.substring(0, matchIndex),
//               style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w400,
//                   color: Colors.grey.shade600),
//             ),
//           TextSpan(
//             text: name.substring(matchIndex, matchIndex + query.length),
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//               color: AppColors.primaryOrangeColor,
//             ),
//           ),
//           if (matchIndex + query.length < name.length)
//             TextSpan(
//               text: name.substring(matchIndex + query.length),
//               style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w400,
//                   color: Colors.grey.shade600),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//       child: Row(
//         children: [
//           Icon(Icons.search_off_rounded, color: Colors.grey.shade300, size: 20),
//           const SizedBox(width: 10),
//           Text(
//             "No products found",
//             style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showListeningDialog() {
//     if (!mounted) return;

//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierColor: Colors.black54,
//       builder: (BuildContext dialogContext) {
//         return Dialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.mic, color: Colors.red, size: 36),
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   "Listening...",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   "Speak the product name",
//                   style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
//                 ),
//                 const SizedBox(height: 20),
//                 const CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     ).then((_) {
//       if (mounted) {
//         setState(() => isListening = false);
//       }
//     });
//   }
// }

// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:speech_to_text/speech_to_text.dart' as stt;
// // import 'package:animated_text_kit/animated_text_kit.dart';
// // import '../../../app_colors.dart';
// // import '../../custom_sliver_delegate.dart';

// // class HomeScreenSearchBar extends StatefulWidget {
// //   const HomeScreenSearchBar({super.key});

// //   @override
// //   State<HomeScreenSearchBar> createState() => _HomeScreenSearchBarState();
// // }

// // class _HomeScreenSearchBarState extends State<HomeScreenSearchBar> {
// //   final List<String> hints = [
// //     "Search 'atta' ",
// //     "Search 'sugar'",
// //     "Search 'oil'",
// //     "Search 'bread'",
// //     "Search 'milk'",
// //   ];

// //   int hintIndex = 0;
// //   late Timer timer;

// //   // 🎤 Speech To Text
// //   late stt.SpeechToText speech;
// //   TextEditingController searchController = TextEditingController();
// //   bool isListening = false;
// //   Timer? listenTimeoutTimer;

// //   @override
// //   void initState() {
// //     super.initState();

// //     /// 🔁 CHANGE HINT EVERY 3 SECONDS
// //     timer = Timer.periodic(Duration(seconds: 3), (_) {
// //       setState(() {
// //         hintIndex = (hintIndex + 1) % hints.length;
// //       });
// //     });

// //     /// 🎤 INITIALIZE SPEECH
// //     speech = stt.SpeechToText();
// //   }

// //   @override
// //   void dispose() {
// //     timer.cancel();
// //     super.dispose();
// //   }
// //   void toggleListening() async {
// //     if (!isListening) {
// //       bool available = await speech.initialize(
// //         onStatus: (status) {
// //           if (status == "done" || status == "notListening") {
// //             closeDialogSafely(context);
// //             setState(() => isListening = false);
// //           }
// //         },
// //         onError: (error) {
// //           closeDialogSafely(context);
// //           setState(() => isListening = false);
// //         },
// //       );

// //       if (available) {
// //         setState(() => isListening = true);
// //         showListeningDialog(context);

// //         speech.listen(onResult: (result) {
// //           setState(() {
// //             searchController.text = result.recognizedWords;
// //           });

// //           if (result.finalResult) {
// //             closeDialogSafely(context);
// //             setState(() => isListening = false);
// //             speech.stop();
// //           }
// //         });
// //       }
// //     } else {
// //       setState(() => isListening = false);
// //       speech.stop();
// //       closeDialogSafely(context);
// //     }
// //   }
// //   void closeDialogSafely(BuildContext context) {
// //     final navigator = Navigator.of(context, rootNavigator: true);
// //     if (navigator.canPop()) navigator.pop();
// //   }


// //   @override
// //   Widget build(BuildContext context) {
// //     return SliverPersistentHeader(
// //       pinned: true,
// //       delegate: SliverAppBarDelegate(
// //         minHeight: 60,
// //         maxHeight: 60,
// //         child: Container(
// //           color: AppColors.primaryOrangeColor,
// //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
// //           child: Row(
// //             children: [
// //               Expanded(child: _buildSearchField(context)),
// //               SizedBox(width: 10),

// //               // 🎤 Mic Button
// //               GestureDetector(
// //                 onTap: toggleListening,
// //                 child: Container(
// //                   padding: const EdgeInsets.all(6),
// //                   decoration: BoxDecoration(
// //                     color: isListening
// //                         ? Colors.red.withOpacity(0.2)
// //                         : Colors.white.withOpacity(0.2),
// //                     shape: BoxShape.circle,
// //                     border: Border.all(
// //                       color: Colors.white.withOpacity(0.3),
// //                       width: 1.5,
// //                     ),
// //                   ),
// //                   child: Icon(
// //                     isListening ? Icons.mic : Icons.mic_none_rounded,
// //                     color: Colors.white,
// //                     size: 22,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   void showListeningDialog(BuildContext context) {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (context) {
// //         return Dialog(
// //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //           child: Container(
// //             padding: const EdgeInsets.all(20),
// //             width: 260,
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Icon(Icons.mic, color: Colors.red, size: 40),
// //                 SizedBox(height: 12),
// //                 Text(
// //                   "Listening...",
// //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
// //                 ),
// //                 SizedBox(height: 6),
// //                 Text(
// //                   "Speak something",
// //                   style: TextStyle(fontSize: 14, color: Colors.grey),
// //                 ),
// //                 SizedBox(height: 16),

// //                 // Animated dots
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: List.generate(
// //                     3,
// //                         (i) => Padding(
// //                       padding: const EdgeInsets.symmetric(horizontal: 3),
// //                       child: AnimatedContainer(
// //                         duration: Duration(milliseconds: 400),
// //                         height: 8,
// //                         width: 8,
// //                         decoration: BoxDecoration(
// //                           color: Colors.orange.withOpacity(i == hintIndex ? 1 : 0.3),
// //                           shape: BoxShape.circle,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 )
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }


// //   Widget _buildSearchField(BuildContext context) {
// //     return TextFormField(
// //       controller: searchController,
// // style: TextStyle(color: Colors.grey.shade600),
// //       decoration: InputDecoration(
// //         // alignLabelWithHint: false,
// //         // floatingLabelBehavior:   FloatingLabelBehavior.never,
// //         filled: true,

// //         fillColor: Colors.white,
// //         prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
// //       // hintTextDirection: Hi,

// //       //   hintTextDirection: TextDirection.ltr,
// //         hint: AnimatedSwitcher(

// //           duration: Duration(milliseconds: 300),

// //           child: Row(
// //      mainAxisAlignment: MainAxisAlignment.start,
// //             children: [
// //               TypewriterAnimatedTextKit(

// //                 key: ValueKey(hints[hintIndex]),

// //                 text: [hints[hintIndex]],
// //                 speed: Duration(milliseconds: 100),
// //                 repeatForever: false,
// //                 textStyle: TextStyle(
// //                   fontSize: 14,
// //                   color: Colors.grey.shade500,

// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),

// //         // ✨ TYPING ANIMATION
// //         // label: AnimatedSwitcher(
// //         //   duration: Duration(milliseconds: 300),
// //         //   child: TypewriterAnimatedTextKit(
// //         //     key: ValueKey(hints[hintIndex]),
// //         //     text: [hints[hintIndex]],
// //         //     speed: Duration(milliseconds:500),
// //         //     repeatForever: false,
// //         //     textStyle: TextStyle(
// //         //       fontSize: 14,
// //         //       color: Colors.grey.shade500,
// //         //     ),
// //         //   ),
// //         // ),

// //         border: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(12),
// //           borderSide: BorderSide.none,
// //         ),
// //         isDense: true,
// //       ),
// //     );
// //   }
// // }
