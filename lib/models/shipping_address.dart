class ShippingAddress {
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  ShippingAddress({
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      line1: json['line1'] as String,
      line2: json['line2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String,
      country: json['country'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line1': line1,
      if (line2 != null) 'line2': line2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
    };
  }

  String get fullAddress {
    final parts = [line1];
    if (line2 != null && line2!.isNotEmpty) {
      parts.add(line2!);
    }
    parts.add('$city, $state $postalCode');
    parts.add(country);
    return parts.join(', ');
  }
}





