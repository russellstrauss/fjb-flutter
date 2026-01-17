import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';
import '../utils/image_loader.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  @override
  Widget build(BuildContext context) {
    final items = _cartService.getItems();
    final total = _cartService.getTotal();
    final isEmpty = _cartService.isEmpty();

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
                child: isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Your cart is empty.',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => context.push('/shop'),
                              child: const Text('Continue Shopping'),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Shopping Cart',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Cart items
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return _CartItemCard(
                                item: items[index],
                                index: index,
                                onUpdate: () => setState(() {}),
                              );
                            },
                          ),
                          const SizedBox(height: 30),
                          // Total
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _cartService.formatPrice(total),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Checkout button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context.push('/checkout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text('Proceed to Checkout'),
                            ),
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

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final int index;
  final VoidCallback onUpdate;

  const _CartItemCard({
    required this.item,
    required this.index,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            // Image
            if (item.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: ImageLoader.loadImage(item.image!, fit: BoxFit.cover),
                ),
              ),
            if (item.image != null) const SizedBox(width: 15),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.variation != null && item.variation!['size'] != null)
                    Text(
                      'Size: ${item.variation!['size']}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    cartService.formatPrice(item.price * item.quantity),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Quantity controls
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () async {
                    final newQuantity = item.quantity - 1;
                    if (newQuantity > 0) {
                      await cartService.updateQuantity(index, newQuantity);
                    } else {
                      await cartService.removeItem(index);
                    }
                    onUpdate();
                  },
                ),
                Text(
                  item.quantity.toString(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    await cartService.updateQuantity(index, item.quantity + 1);
                    onUpdate();
                  },
                ),
              ],
            ),
            // Remove button
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () async {
                await cartService.removeItem(index);
                onUpdate();
              },
            ),
          ],
        ),
      ),
    );
  }
}
