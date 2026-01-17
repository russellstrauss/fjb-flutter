import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_card.dart';

class RelatedProducts extends StatelessWidget {
  final int productId;
  final int limit;

  const RelatedProducts({
    super.key,
    required this.productId,
    this.limit = 4,
  });

  @override
  Widget build(BuildContext context) {
    final productService = ProductService();
    final relatedProducts = productService.getRelatedProducts(productId, limit: limit);

    if (relatedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Related Products',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 340,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: relatedProducts.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 250,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ProductCard(product: relatedProducts[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}





