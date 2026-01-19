class Category {
	final String name;
	final String slug;
	final String? description;

	Category({
		required this.name,
		required this.slug,
		this.description,
	});

	factory Category.fromJson(Map<String, dynamic> json) {
		return Category(
			name: json['name'] as String,
			slug: json['slug'] as String,
			description: json['description'] as String?,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'name': name,
			'slug': slug,
			if (description != null) 'description': description,
		};
	}

	@override
	bool operator ==(Object other) =>
			identical(this, other) ||
			other is Category && runtimeType == other.runtimeType && slug == other.slug;

	@override
	int get hashCode => slug.hashCode;
}





