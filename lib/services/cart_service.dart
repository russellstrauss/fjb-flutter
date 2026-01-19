import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
	static final CartService _instance = CartService._internal();
	factory CartService() => _instance;
	CartService._internal() {
		_loadCart();
	}

	static const String _storageKey = 'fjb_cart';
	static const double shippingRate = 10.0;
	List<CartItem> _cartItems = [];

	Future<void> _loadCart() async {
		try {
			final prefs = await SharedPreferences.getInstance();
			final cartData = prefs.getString(_storageKey);
			if (cartData != null) {
				final List<dynamic> jsonList = json.decode(cartData) as List<dynamic>;
				_cartItems = jsonList
						.map((json) => CartItem.fromJson(json as Map<String, dynamic>))
						.toList();
			}
		} catch (e) {
			print('Error loading cart: $e');
			_cartItems = [];
		}
	}

	Future<void> _saveCart() async {
		try {
			final prefs = await SharedPreferences.getInstance();
			final cartData = json.encode(_cartItems.map((item) => item.toJson()).toList());
			await prefs.setString(_storageKey, cartData);
			_notifyListeners();
		} catch (e) {
			print('Error saving cart: $e');
		}
	}

	void _notifyListeners() {
		// In a full implementation, you might use ChangeNotifier or ValueNotifier
		// For now, widgets will call getItems() when needed
	}

	Future<void> addItem(Product product, {int quantity = 1, Map<String, dynamic>? variation}) async {
		if (product.slug.isEmpty) {
			print('Product missing slug: $product');
			return;
		}

		final item = CartItem(
			id: product.id,
			slug: product.slug,
			sku: product.sku,
			name: product.name,
			price: product.salePrice ?? product.price,
			image: product.images.isNotEmpty ? product.images[0] : null,
			quantity: quantity,
			variation: variation,
		);

		_cartItems.add(item);
		await _saveCart();
	}

	Future<void> removeItem(int index) async {
		if (index >= 0 && index < _cartItems.length) {
			_cartItems.removeAt(index);
			await _saveCart();
		}
	}

	Future<void> updateQuantity(int index, int quantity) async {
		if (index >= 0 && index < _cartItems.length) {
			if (quantity > 0) {
				_cartItems[index].quantity = quantity;
			} else {
				await removeItem(index);
				return;
			}
			await _saveCart();
		}
	}

	Future<void> clearCart() async {
		_cartItems.clear();
		await _saveCart();
	}

	List<CartItem> getItems() {
		return List.unmodifiable(_cartItems);
	}

	bool isEmpty() {
		return _cartItems.isEmpty;
	}

	double getSubtotal() {
		return _cartItems.fold(0.0, (total, item) => total + (item.price * item.quantity));
	}

	double getShipping() {
		return _cartItems.isEmpty ? 0.0 : shippingRate;
	}

	double getTotal() {
		return getSubtotal() + getShipping();
	}

	int getItemCount() {
		return _cartItems.length;
	}

	String formatPrice(double price) {
		return '\$${price.toStringAsFixed(2)}';
	}
}





