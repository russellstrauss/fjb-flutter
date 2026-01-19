class CartItem {
	final int id;
	final String slug;
	final String sku;
	final String name;
	final double price;
	final String? image;
	int quantity;
	final Map<String, dynamic>? variation;

	CartItem({
		required this.id,
		required this.slug,
		required this.sku,
		required this.name,
		required this.price,
		this.image,
		this.quantity = 1,
		this.variation,
	});

	factory CartItem.fromJson(Map<String, dynamic> json) {
		return CartItem(
			id: json['id'] as int,
			slug: json['slug'] as String,
			sku: json['sku'] as String,
			name: json['name'] as String,
			price: (json['price'] as num).toDouble(),
			image: json['image'] as String?,
			quantity: json['quantity'] as int? ?? 1,
			variation: json['variation'] as Map<String, dynamic>?,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'slug': slug,
			'sku': sku,
			'name': name,
			'price': price,
			if (image != null) 'image': image,
			'quantity': quantity,
			if (variation != null) 'variation': variation,
		};
	}

	CartItem copyWith({
		int? id,
		String? slug,
		String? sku,
		String? name,
		double? price,
		String? image,
		int? quantity,
		Map<String, dynamic>? variation,
	}) {
		return CartItem(
			id: id ?? this.id,
			slug: slug ?? this.slug,
			sku: sku ?? this.sku,
			name: name ?? this.name,
			price: price ?? this.price,
			image: image ?? this.image,
			quantity: quantity ?? this.quantity,
			variation: variation ?? this.variation,
		);
	}
}





