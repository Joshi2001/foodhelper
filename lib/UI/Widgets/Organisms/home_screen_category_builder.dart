import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:e_commerce/UI/Widgets/Atoms/category_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreenCategoryWidget extends StatefulWidget {
  const HomeScreenCategoryWidget({super.key});

  @override
  State<HomeScreenCategoryWidget> createState() =>
      _HomeScreenCategoryWidgetState();
}

class _HomeScreenCategoryWidgetState extends State<HomeScreenCategoryWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final home = context.read<Home>();
      if (home.allAppCategories.isEmpty && !home.isLoadingAllCategories) {
        home.fetchAllCategoriesFromAPI();
      }
      if (home.appCategories.isEmpty && !home.isLoadingAppCategories) {
        home.fetchAndGroupProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Home>(
      builder: (context, home, _) {

        if (home.isLoadingAllCategories && home.allAppCategories.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CupertinoActivityIndicator(radius: 15)),
            ),
          );
        }
        final categoriesToShow = home.appCategories;
        
        if (categoriesToShow.isEmpty && !home.isLoadingAppCategories) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No categories available')),
            ),
          );
        }

        return SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // Matching the top orange shade
                  Color(0xFFFFF3E0),
                  Color(0xFFFFF3E0), // Gradually fading to white for products
                ],
                stops: [0.0, 0.9],    // Smooth transition
              ),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              itemCount: categoriesToShow.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final category = categoriesToShow[index];
                return Container(
                  // decoration: BoxDecoration(
                  //   color: Colors.white,
                  //   borderRadius: BorderRadius.circular(20),
                  //   boxShadow: [
                  //     BoxShadow(
                  //       color: Colors.black.withOpacity(0.06),
                  //       blurRadius: 12,
                  //       offset: const Offset(0, 4),
                  //     ),
                  //   ],
                  // ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: CategoryWidget(category: category),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}