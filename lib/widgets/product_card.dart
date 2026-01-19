import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../utils/image_loader.dart';

class ProductCard extends StatelessWidget {
	final Product product;

	const ProductCard({
		super.key,
		required this.product,
	});

	String _getProductImage() {
		if (product.images.isNotEmpty) {
			return product.images[0];
		}
		return '/assets/images/placeholder.jpg';
	}

	String _formatPrice(double price) {
		return '\$${price.toStringAsFixed(2)}';
	}

	@override
	Widget build(BuildContext context) {
		final cartService = CartService();
		final hasSale = product.salePrice != null;

		return InkWell(
			onTap: () {
				context.push('/product/${product.slug}');
			},
			child: Container(
				decoration: BoxDecoration(
					border: Border.all(color: Colors.grey.shade300),
					borderRadius: BorderRadius.circular(4),
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Stack(
							children: [
								AspectRatio(
									aspectRatio: 1.0,
									child: Container(
										decoration: BoxDecoration(
											border: Border.all(color: Colors.black, width: 1),
										),
										child: ClipRect(
											child: ImageLoader.loadImage(
												_getProductImage(),
												fit: BoxFit.cover,
											),
										),
									),
								),
								if (hasSale)
									Positioned(
										top: 8,
										right: 8,
										child: Container(
											padding: const EdgeInsets.symmetric(
												horizontal: 0,
												vertical: 4,
											),
											decoration: BoxDecoration(
												color: Colors.red,
												borderRadius: BorderRadius.circular(4),
											),
											child: const Text(
												'Sale',
												style: TextStyle(
													color: Colors.white,
													fontSize: 12,
													fontWeight: FontWeight.bold,
												),
											),
										),
									),
							],
						),
						Container(
							margin: const EdgeInsets.only(top: 20),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
								Text(
									product.name,
									style: const TextStyle(
										fontSize: 16,
										fontWeight: FontWeight.w600,
									),
									maxLines: 2,
									overflow: TextOverflow.ellipsis,
								),
								const SizedBox(height: 8),
								Row(
									children: [
										if (hasSale)
											Text(
												_formatPrice(product.salePrice!),
												style: const TextStyle(
													fontSize: 16,
													fontWeight: FontWeight.bold,
													color: Colors.red,
												),
											),
										if (hasSale) const SizedBox(width: 8),
										Text(
											_formatPrice(product.price),
											style: TextStyle(
												fontSize: hasSale ? 14 : 16,
												fontWeight: FontWeight.bold,
												decoration: hasSale ? TextDecoration.lineThrough : null,
												color: hasSale ? Colors.grey : Colors.black,
											),
										),
									],
								),
							],
						),
						),
					],
				),
			),
		);
	}
}





