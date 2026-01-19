import 'category.dart';

class Product {
	final int id;
	final String name;
	final String slug;
	final String sku;
	final double price;
	final double regularPrice;
	final double? salePrice;
	final String? shortDescription;
	final List<String> images;
	final int? stockQuantity;
	final String stockStatus;
	final bool inStock;
	final bool manageStock;
	final List<Category> categories;
	final List<Map<String, dynamic>> tags;
	final List<String>? sizes;
	final String currency;
	final String type;
	final bool featured;
	final List<String>? colors;

	Product({
		required this.id,
		required this.name,
		required this.slug,
		required this.sku,
		required this.price,
		required this.regularPrice,
		this.salePrice,
		this.shortDescription,
		required this.images,
		this.stockQuantity,
		required this.stockStatus,
		required this.inStock,
		required this.manageStock,
		required this.categories,
		required this.tags,
		this.sizes,
		required this.currency,
		required this.type,
		required this.featured,
		this.colors,
	});

	factory Product.fromJson(Map<String, dynamic> json) {
		return Product(
			id: json['id'] as int,
			name: json['name'] as String,
			slug: json['slug'] as String,
			sku: json['sku'] as String,
			price: (json['price'] as num).toDouble(),
			regularPrice: (json['regular_price'] as num).toDouble(),
			salePrice: json['sale_price'] != null ? (json['sale_price'] as num).toDouble() : null,
			shortDescription: json['short_description'] as String?,
			images: (json['images'] as List<dynamic>?)
							?.map((e) {
								if (e is String) {
									return e.trim();
								} else if (e is Map<String, dynamic> && e.containsKey('src')) {
									return (e['src'] as String).trim();
								} else {
									return e.toString().trim();
								}
							})
							.where((img) => img.isNotEmpty)
							.toList() ??
					[],
			stockQuantity: json['stock_quantity'] as int?,
			stockStatus: json['stock_status'] as String? ?? 'instock',
			inStock: json['in_stock'] as bool? ?? true,
			manageStock: json['manage_stock'] as bool? ?? true,
			categories: (json['categories'] as List<dynamic>?)
							?.map((e) => Category.fromJson(e as Map<String, dynamic>))
							.toList() ??
					[],
			tags: (json['tags'] as List<dynamic>?)
							?.map((e) => e as Map<String, dynamic>)
							.toList() ??
					[],
			sizes: json['sizes'] != null
					? (json['sizes'] as List<dynamic>).map((e) => e.toString()).toList()
					: null,
			currency: json['currency'] as String? ?? 'USD',
			type: json['type'] as String? ?? 'simple',
			featured: json['featured'] as bool? ?? false,
			colors: json['colors'] != null
					? (json['colors'] as List<dynamic>).map((e) => e.toString()).toList()
					: null,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'name': name,
			'slug': slug,
			'sku': sku,
			'price': price,
			'regular_price': regularPrice,
			if (salePrice != null) 'sale_price': salePrice,
			if (shortDescription != null) 'short_description': shortDescription,
			'images': images,
			if (stockQuantity != null) 'stock_quantity': stockQuantity,
			'stock_status': stockStatus,
			'in_stock': inStock,
			'manage_stock': manageStock,
			'categories': categories.map((e) => e.toJson()).toList(),
			'tags': tags,
			if (sizes != null) 'sizes': sizes,
			'currency': currency,
			'type': type,
			'featured': featured,
			if (colors != null) 'colors': colors,
		};
	}
}





