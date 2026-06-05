import 'package:e_commerce/Screens/AdvertisingBannerCarousel.dart';
import 'package:e_commerce/Screens/location.dart';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:e_commerce/Services/api/apiservice.dart';
import 'package:e_commerce/UI/Widgets/Organisms/bottom_cart_container.dart';
import 'package:e_commerce/UI/Widgets/Organisms/home_screen_category_builder.dart';
import 'package:e_commerce/UI/Widgets/Organisms/home_screen_search_bar.dart';
import 'package:e_commerce/UI/Widgets/similar/subcategoryProductSections.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final home = context.read<Home>();
    
      home.fetchAndGroupProducts();
      home.fetchAllSubcategoriesWithProducts();
      home.fetchSimpleBanners();
      home.fetchAdvertisingBanners();
    });
  }

  Future<void> _retryAll(Home home) async {
    home.resetMaintenance();
    await Future.wait([
      home.fetchAndGroupProducts(), 
      home.fetchAllSubcategoriesWithProducts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<Home>();

    if (home.isMaintenance) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.build_circle_outlined,
                      size: 52,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Under Maintenance',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    home.maintenanceMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.blueGrey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We\'ll be back soon. Thank you for your patience.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: home.isLoadingCategories || home.isLoadingProducts
                          ? null
                          : () => _retryAll(home),
                      icon: home.isLoadingCategories || home.isLoadingProducts
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(
                        home.isLoadingCategories || home.isLoadingProducts
                            ? 'Checking...'
                            : 'Retry',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3D7C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: const Color(0xFFFFE0B2),
        elevation: 0,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _retryAll(home),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── AppBar ──
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  expandedHeight: 120,
                  collapsedHeight: 120,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFE0B2), Color(0xFFFFF3E0), Color(0xFFFFF3E0)],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "FoodHelper",
                                  style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.w900,
                                    color: Color(0xFF1A3D7C), fontStyle: FontStyle.italic,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.person, color: Color(0xFF2C3E50), size: 30),
                                  onPressed: () => Navigator.of(context).pushNamed('/profile'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Icon(Icons.circle, color: Colors.red, size: 8),
                                SizedBox(width: 8),
                                Text("Deliver to",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A3D7C))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const LocationPicker(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                HomeScreenSearchBar(
                  apiService: ApiService(baseUrl: "https://grocerrybackend.onrender.com"),
                ),

                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFF3E0), Color(0xFFFFF3E0), Color(0xFFFFF3E0)],
                      ),
                    ),
                    child: Column(
                      children: [
                        if (home.simpleBanners.isNotEmpty)
                          SizedBox(
                            height: 160,
                            child: PageView.builder(
                              itemCount: home.simpleBanners.length,
                              itemBuilder: (context, index) {
                                final banner = home.simpleBanners[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    image: DecorationImage(
                                      image: NetworkImage(banner.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                          child: Column(
                            children: [
                              const Text(
                                'SHOP BY CATEGORIES',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w900,
                                  color: Color(0xFF2C3E50), letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Freshly picked essentials, categorized for your ease.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13, color: Colors.blueGrey[400], fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const HomeScreenCategoryWidget(),

                // const SliverToBoxAdapter(
                //   child: Padding(
                //     padding: EdgeInsets.only(top: 10, bottom: 5),
                //     child: AdvertisingBannerCarousel(
                //       height: 150,
                //       margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                //     ),
                //   ),
                // ),

                const SubcategoryProductSections(),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),

          if (home.hasItems)
            const Positioned(
              left: 0, right: 0, bottom: 0,
              child: SafeArea(child: BottomStickyContainer()),
            ),
        ],
      ),
    );
  }
}
