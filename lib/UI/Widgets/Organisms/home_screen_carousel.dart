import 'dart:async';
import 'package:e_commerce/Services/Providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BannerItem2 {
  final String imageUrl;
  final bool isNetwork; 

  const BannerItem2({
    required this.imageUrl,
    this.isNetwork = true,
  });
}

class HomeScreenCarousel extends StatelessWidget {
  const HomeScreenCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Provider.of<Home>(context);
    final banners = home.simpleBanners;

    return SliverToBoxAdapter(
      child: CarouselBanner(
        banners: banners,
        height: 150,
      ),
    );
  }
}

class CarouselBanner extends StatefulWidget {
  final List<BannerItem2> banners;
  final double height;

  const CarouselBanner({
    super.key,
    required this.banners,
    this.height = 100,
  });

  @override
  State<CarouselBanner> createState() => _CarouselBannerState();
}

class _CarouselBannerState extends State<CarouselBanner> {
  final PageController _pageController =
      PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(1);
      }
    });
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _currentPage++;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // ✅ Network ya Asset image automatically decide karta hai
  Widget _buildImage(BannerItem2 banner) {
    if (banner.isNetwork) {
      return Image.network(
        banner.imageUrl,
        fit: BoxFit.fill,
        // Loading indicator jab tak image load ho
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        banner.imageUrl,
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, size: 50),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        padEnds: true,
        itemCount: null, // Infinite scroll
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        itemBuilder: (context, index) {
          final realIndex = index % widget.banners.length;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: _buildImage(widget.banners[realIndex]),
            ),
          );
        },
      ),
    );
  }
}
