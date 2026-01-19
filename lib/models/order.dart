import 'shipping_address.dart';
import 'cart_item.dart';

class OrderItem {
	final String name;
	final String sku;
	final int quantity;
	final double price;
	final double total;

	OrderItem({
		required this.name,
		required this.sku,
		required this.quantity,
		required this.price,
		required this.total,
	});

	factory OrderItem.fromJson(Map<String, dynamic> json) {
		return OrderItem(
			name: json['name'] as String,
			sku: json['sku'] as String,
			quantity: json['quantity'] as int,
			price: (json['price'] as num).toDouble(),
			total: (json['total'] as num).toDouble(),
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'name': name,
			'sku': sku,
			'quantity': quantity,
			'price': price,
			'total': total,
		};
	}
}

class OrderTotals {
	final double subtotal;
	final double shipping;
	final double tax;
	final double total;

	OrderTotals({
		required this.subtotal,
		required this.shipping,
		required this.tax,
		required this.total,
	});

	factory OrderTotals.fromJson(Map<String, dynamic> json) {
		return OrderTotals(
			subtotal: (json['subtotal'] as num).toDouble(),
			shipping: (json['shipping'] as num).toDouble(),
			tax: (json['tax'] as num).toDouble(),
			total: (json['total'] as num).toDouble(),
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'subtotal': subtotal,
			'shipping': shipping,
			'tax': tax,
			'total': total,
		};
	}
}

class OrderCustomer {
	final String name;
	final String email;
	final String? phone;

	OrderCustomer({
		required this.name,
		required this.email,
		this.phone,
	});

	factory OrderCustomer.fromJson(Map<String, dynamic> json) {
		return OrderCustomer(
			name: json['name'] as String,
			email: json['email'] as String,
			phone: json['phone'] as String?,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'name': name,
			'email': email,
			if (phone != null) 'phone': phone,
		};
	}
}

class Order {
	final String id;
	final String? stripeSessionId;
	final String? stripePaymentIntentId;
	final String orderNumber;
	final String status;
	final String createdAt;
	final String updatedAt;
	final OrderCustomer customer;
	final Map<String, dynamic> shipping;
	final List<OrderItem> items;
	final OrderTotals totals;
	final String currency;
	final String? notes;

	Order({
		required this.id,
		this.stripeSessionId,
		this.stripePaymentIntentId,
		required this.orderNumber,
		required this.status,
		required this.createdAt,
		required this.updatedAt,
		required this.customer,
		required this.shipping,
		required this.items,
		required this.totals,
		required this.currency,
		this.notes,
	});

	factory Order.fromJson(Map<String, dynamic> json) {
		return Order(
			id: json['id'] as String,
			stripeSessionId: json['stripeSessionId'] as String?,
			stripePaymentIntentId: json['stripePaymentIntentId'] as String?,
			orderNumber: json['orderNumber'] as String,
			status: json['status'] as String,
			createdAt: json['createdAt'] as String,
			updatedAt: json['updatedAt'] as String,
			customer: OrderCustomer.fromJson(json['customer'] as Map<String, dynamic>),
			shipping: json['shipping'] as Map<String, dynamic>,
			items: (json['items'] as List<dynamic>)
					.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
					.toList(),
			totals: OrderTotals.fromJson(json['totals'] as Map<String, dynamic>),
			currency: json['currency'] as String? ?? 'usd',
			notes: json['notes'] as String?,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			if (stripeSessionId != null) 'stripeSessionId': stripeSessionId,
			if (stripePaymentIntentId != null) 'stripePaymentIntentId': stripePaymentIntentId,
			'orderNumber': orderNumber,
			'status': status,
			'createdAt': createdAt,
			'updatedAt': updatedAt,
			'customer': customer.toJson(),
			'shipping': shipping,
			'items': items.map((e) => e.toJson()).toList(),
			'totals': totals.toJson(),
			'currency': currency,
			if (notes != null) 'notes': notes,
		};
	}
}





