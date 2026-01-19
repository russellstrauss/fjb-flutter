import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../widgets/product_card.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';

class ShopScreen extends StatefulWidget {
	final String? category;

	const ShopScreen({super.key, this.category});

	@override
	State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
	final ProductService _productService = ProductService();
	List<Product> _products = [];
	List<Category> _categories = [];
	bool _loading = true;

	@override
	void initState() {
		super.initState();
		_loadData();
	}

	Future<void> _loadData() async {
		await _productService.loadProducts(forceReload: true);
		setState(() {
			_categories = _productService.getAllCategories();
			_updateFilteredProducts();
			_loading = false;
		});
	}

	void _updateFilteredProducts() {
		if (widget.category != null && widget.category!.isNotEmpty) {
			_products = _productService.getProductsByCategory(widget.category!);
		} else {
			_products = _productService.allProducts;
		}
	}

	@override
	void didUpdateWidget(ShopScreen oldWidget) {
		super.didUpdateWidget(oldWidget);
		if (oldWidget.category != widget.category) {
			_updateFilteredProducts();
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				children: [
					const AppHeader(),
					Expanded(
						child: SingleChildScrollView(
							child: Container(
								constraints: const BoxConstraints(maxWidth: 1140),
								margin: const EdgeInsets.symmetric(horizontal: 15),
								padding: const EdgeInsets.symmetric(vertical: 20),
								child: _loading
										? const Center(child: CircularProgressIndicator())
										: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													// Category filters
													SingleChildScrollView(
														scrollDirection: Axis.horizontal,
														child: Row(
															children: [
																_CategoryChip(
																	label: 'All Dyes',
																	isSelected: widget.category == null,
																	onTap: () => context.go('/shop'),
																),
																const SizedBox(width: 10),
																..._categories.map((category) => Padding(
																			padding: const EdgeInsets.only(right: 10),
																			child: _CategoryChip(
																				label: category.name,
																				isSelected: widget.category == category.slug,
																				onTap: () => context.go('/shop?category=${category.slug}'),
																			),
																		)),
															],
														),
													),
													const SizedBox(height: 30),
													// Product grid
													_products.isEmpty
															? const Center(
																	child: Padding(
																		padding: EdgeInsets.all(40),
																		child: Text('No products found'),
																	),
																)
															: GridView.builder(
																	shrinkWrap: true,
																	physics: const NeverScrollableScrollPhysics(),
																	gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
																		crossAxisCount: MediaQuery.of(context).size.width > 960
																				? 4
																				: MediaQuery.of(context).size.width > 720
																						? 3
																						: 2,
																		childAspectRatio: 0.75,
																		crossAxisSpacing: 20,
																		mainAxisSpacing: 20,
																	),
																	itemCount: _products.length,
																	itemBuilder: (context, index) {
																		return ProductCard(product: _products[index]);
																	},
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

class _CategoryChip extends StatelessWidget {
	final String label;
	final bool isSelected;
	final VoidCallback onTap;

	const _CategoryChip({
		required this.label,
		required this.isSelected,
		required this.onTap,
	});

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			child: Container(
				padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
				decoration: BoxDecoration(
					color: isSelected ? Colors.black : Colors.grey.shade200,
					borderRadius: BorderRadius.circular(20),
				),
				child: Text(
					label,
					style: TextStyle(
						color: isSelected ? Colors.white : Colors.black,
						fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
					),
				),
			),
		);
	}
}
