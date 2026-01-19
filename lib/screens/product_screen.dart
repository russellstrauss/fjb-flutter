import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../models/product.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';
import '../widgets/related_products.dart';
import '../utils/dialog.dart';
import '../utils/image_loader.dart';

class ProductScreen extends StatefulWidget {
	final String slug;

	const ProductScreen({super.key, required this.slug});

	@override
	State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
	final ProductService _productService = ProductService();
	final CartService _cartService = CartService();
	Product? _product;
	bool _loading = true;
	int _selectedImageIndex = 0;
	String? _selectedSize;
	bool _showSizeError = false;
	bool _showImageViewer = false;

	@override
	void initState() {
		super.initState();
		_loadProduct();
	}

	Future<void> _loadProduct() async {
		await _productService.loadProducts();
		setState(() {
			_product = _productService.getProductBySlug(widget.slug);
			_loading = false;
		});
	}

	String _formatPrice(double price) {
		return '\$${price.toStringAsFixed(2)}';
	}

	String _formatDescription(String? text) {
		if (text == null || text.isEmpty) return '';
		return text.replaceAll('\r\n', '\n').replaceAll('\n', '\n');
	}

	Future<void> _addToCart() async {
		if (_product == null) return;

		// Check if size is required
		if (_product!.sizes != null && _product!.sizes!.isNotEmpty && (_selectedSize == null || _selectedSize!.isEmpty)) {
			setState(() {
				_showSizeError = true;
			});
			return;
		}

		setState(() {
			_showSizeError = false;
		});

		// Create variation if size is selected
		Map<String, dynamic>? variation;
		if (_selectedSize != null && _selectedSize!.isNotEmpty) {
			variation = {'size': _selectedSize};
		}

		await _cartService.addItem(_product!, variation: variation);

		if (!mounted) return;

		final result = await showAlertDialog(
			context: context,
			title: 'Success',
			message: 'Product added to cart!',
			confirmText: 'Check Out Now',
			cancelText: 'Continue Shopping',
			showCancel: true,
		);

		if (result == true) {
			context.push('/checkout');
		}

		// Reset size selection
		if (_product!.sizes != null && _product!.sizes!.isNotEmpty) {
			setState(() {
				_selectedSize = null;
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		if (_loading) {
			return const Scaffold(
				body: Center(child: CircularProgressIndicator()),
			);
		}

		if (_product == null) {
			return Scaffold(
				appBar: AppBar(title: const Text('Product Not Found')),
				body: Center(
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							const Text('Product not found'),
							const SizedBox(height: 20),
							ElevatedButton(
								onPressed: () => context.push('/shop'),
								child: const Text('Continue Shopping'),
							),
						],
					),
				),
			);
		}

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
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										// Product details
										Row(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												// Image gallery
												Expanded(
													flex: 1,
													child: Column(
														children: [
															// Main image
															GestureDetector(
																onTap: () {
																	setState(() {
																		_showImageViewer = true;
																	});
																},
																child: Container(
																	height: 500,
																	width: double.infinity,
																	decoration: BoxDecoration(
																		border: Border.all(color: Colors.black, width: 1),
																	),
																	child: ClipRect(
																		child: ImageLoader.loadImage(
																			_product!.images[_selectedImageIndex],
																			fit: BoxFit.cover,
																		),
																	),
																),
															),
															if (_product!.images.length > 1) ...[
																const SizedBox(height: 10),
																// Thumbnail gallery
																SizedBox(
																	height: 80,
																	child: ListView.builder(
																		scrollDirection: Axis.horizontal,
																		itemCount: _product!.images.length,
																		itemBuilder: (context, index) {
																			final isSelected = index == _selectedImageIndex;
																			return GestureDetector(
																				onTap: () {
																					setState(() {
																						_selectedImageIndex = index;
																					});
																				},
																				child: Container(
																					width: 80,
																					height: 80,
																					margin: const EdgeInsets.only(right: 10),
																					decoration: BoxDecoration(
																						border: Border.all(
																							color: isSelected ? Colors.black : Colors.grey.shade300,
																							width: 1,
																						),
																					),
																					child: ClipRect(
																						child: ImageLoader.loadImage(
																							_product!.images[index],
																							fit: BoxFit.cover,
																						),
																					),
																				),
																			);
																		},
																	),
																),
															],
														],
													),
												),
												const SizedBox(width: 40),
												// Product info
												Expanded(
													flex: 1,
													child: Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Text(
																_product!.name,
																style: const TextStyle(
																	fontSize: 32,
																	fontWeight: FontWeight.bold,
																),
															),
															const SizedBox(height: 20),
															Row(
																children: [
																	if (_product!.salePrice != null)
																		Text(
																			_formatPrice(_product!.salePrice!),
																			style: const TextStyle(
																				fontSize: 24,
																				fontWeight: FontWeight.bold,
																				color: Colors.red,
																			),
																		),
																	if (_product!.salePrice != null) const SizedBox(width: 10),
																	Text(
																		_formatPrice(_product!.price),
																		style: TextStyle(
																			fontSize: _product!.salePrice != null ? 18 : 24,
																			fontWeight: FontWeight.bold,
																			decoration: _product!.salePrice != null ? TextDecoration.lineThrough : null,
																			color: _product!.salePrice != null ? Colors.grey : Colors.black,
																		),
																	),
																],
															),
															const SizedBox(height: 20),
															if (_product!.shortDescription != null) ...[
																Text(
																	_formatDescription(_product!.shortDescription),
																	style: const TextStyle(fontSize: 16),
																),
																const SizedBox(height: 20),
															],
															if (_product!.colors != null && _product!.colors!.isNotEmpty) ...[
																const Text(
																	'Color Palette',
																	style: TextStyle(
																		fontSize: 18,
																		fontWeight: FontWeight.bold,
																	),
																),
																const SizedBox(height: 10),
																Wrap(
																	spacing: 10,
																	runSpacing: 10,
																	children: _product!.colors!.map((color) {
																		return Chip(label: Text(color));
																	}).toList(),
																),
																const SizedBox(height: 20),
															],
															if (_product!.sizes != null && _product!.sizes!.isNotEmpty) ...[
																Column(
																	crossAxisAlignment: CrossAxisAlignment.start,
																	children: [
																		const Text(
																			'Size: *',
																			style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
																		),
																		const SizedBox(height: 5),
																		DropdownButtonFormField<String>(
																			value: _selectedSize,
																			decoration: InputDecoration(
																				errorText: _showSizeError ? 'Please select a size' : null,
																				border: const OutlineInputBorder(),
																			),
																			hint: const Text('Select a size'),
																			items: _product!.sizes!.map((size) {
																				return DropdownMenuItem(
																					value: size,
																					child: Text(size),
																				);
																			}).toList(),
																			onChanged: (value) {
																				setState(() {
																					_selectedSize = value;
																					_showSizeError = false;
																				});
																			},
																		),
																		const SizedBox(height: 20),
																	],
																),
															],
															ElevatedButton(
																onPressed: _addToCart,
																style: ElevatedButton.styleFrom(
																	backgroundColor: Colors.black,
																	foregroundColor: Colors.white,
																	padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
																	minimumSize: const Size(double.infinity, 50),
																),
																child: const Text('Add to Cart'),
															),
															if (_product!.categories.isNotEmpty) ...[
																const SizedBox(height: 20),
																Wrap(
																	spacing: 10,
																	children: _product!.categories.map((category) {
																		return InkWell(
																			onTap: () => context.push('/shop?category=${category.slug}'),
																			child: Chip(
																				label: Text(category.name),
																				backgroundColor: Colors.grey.shade200,
																			),
																		);
																	}).toList(),
																),
															],
														],
													),
												),
											],
										),
										const SizedBox(height: 60),
										RelatedProducts(productId: _product!.id),
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
