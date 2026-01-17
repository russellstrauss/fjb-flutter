import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/product_service.dart';
import '../models/category.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';
import '../utils/image_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  List<Category> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _productService.loadProducts();
    setState(() {
      _categories = _productService.getAllCategories();
      _loading = false;
    });
  }

  String _getCategoryImage(Category category) {
    switch (category.slug) {
      case 'ice-dye':
      case 'ice-dyes':
        return '/assets/images/ice-dye.jpg';
      case 'reverse-dye':
      case 'reverse-dyes':
        return '/assets/images/reverse-dye.jpg';
      default:
        final products = _productService.getProductsByCategory(category.slug);
        if (products.isNotEmpty && products[0].images.isNotEmpty) {
          return products[0].images[0];
        }
        return '/assets/images/all-jewelry.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppHeader(hideLogo: true),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1140),
                margin: const EdgeInsets.symmetric(horizontal: 15),
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Large logo
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 40),
                              child: ImageLoader.loadImage(
                                '/assets/images/fjb-cotton-logo.svg',
                                fit: BoxFit.contain,
                                width: 400,
                                height: 400,
                              ),
                            ),
                          ),
                          const Text(
                            'Welcome to Farmer John\'s Botanicals!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Farmer John\'s Botanicals makes the world a more colorful place by specializing in natural fiber fashion lines and textiles.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Make your wardrobe slay with Farmer J!',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 40),
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              _CategoryCard(
                                title: 'All Dyes',
                                image: '/assets/images/all-dyes.jpg',
                                onTap: () => context.push('/shop'),
                              ),
                              ..._categories.map((category) => _CategoryCard(
                                    title: category.name,
                                    image: _getCategoryImage(category),
                                    onTap: () => context.push('/shop?category=${category.slug}'),
                                  )),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 250, maxWidth: 500),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageLoader.loadImage(image, fit: BoxFit.cover),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withOpacity(0.3),
              ),
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
