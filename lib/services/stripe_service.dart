import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../models/cart_item.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  Future<void> createCheckoutSession({
    required List<CartItem> cartItems,
    Map<String, dynamic>? customerDetails,
    String? apiUrl,
  }) async {
    if (cartItems.isEmpty) {
      throw Exception('Cart is empty');
    }

    try {
      final lineItems = cartItems.map((item) {
        String? imageUrl;
        if (item.image != null) {
          if (item.image!.startsWith('http')) {
            imageUrl = item.image;
          } else {
            // For local images, you might need to convert to full URL
            // For now, we'll use the relative path
            imageUrl = item.image;
          }
        }

        return {
          'price_data': {
            'currency': 'usd',
            'product_data': {
              'name': item.name,
              if (imageUrl != null) 'images': [imageUrl],
            },
            'unit_amount': (item.price * 100).round(),
          },
          'quantity': item.quantity,
        };
      }).toList();

      // Prepare request body
      final metadata = <String, dynamic>{
        'cart_items': json.encode(cartItems.map((item) => {
          'sku': item.sku,
          'name': item.name,
          'quantity': item.quantity,
        }).toList()),
      };

      final requestBody = <String, dynamic>{
        'line_items': lineItems,
        'success_url': '/success?session_id={CHECKOUT_SESSION_ID}',
        'cancel_url': '/checkout',
        'metadata': metadata,
      };

      // Add customer details if provided
      if (customerDetails != null) {
        requestBody['customer_email'] = customerDetails['email'];
        requestBody['customer_name'] = customerDetails['name'];
        if (customerDetails['shipping'] != null) {
          requestBody['shipping_address'] = customerDetails['shipping']['address'];
          requestBody['shipping_name'] = customerDetails['shipping']['name'];
        }
        
        metadata['customer_name'] = customerDetails['name'];
        metadata['customer_email'] = customerDetails['email'];
        if (customerDetails['phone'] != null) {
          metadata['customer_phone'] = customerDetails['phone'];
        }
        if (customerDetails['notes'] != null) {
          metadata['order_notes'] = customerDetails['notes'];
        }
        if (customerDetails['shipping'] != null) {
          final address = customerDetails['shipping']['address'] as Map<String, dynamic>;
          metadata['shipping_address'] = json.encode({
            'line1': address['line1'],
            'line2': address['line2'],
            'city': address['city'],
            'state': address['state'],
            'postal_code': address['postal_code'],
            'country': address['country'],
          });
        }
      }

      // For demo purposes, if there's no backend API, we'll simulate
      // In production, you'd call the actual API endpoint
      final url = apiUrl ?? '/api/create-checkout';
      
      // If we're in a web environment, we can make the actual API call
      // For mobile, we might need to handle this differently
      // For now, we'll throw an error suggesting to implement the backend
      
      // Note: In a real implementation, you'd use http package to make the POST request
      // and then use url_launcher to open the returned checkout URL
      throw Exception('Stripe checkout requires backend API. Please implement the API endpoint or use Stripe SDK for mobile.');
    } catch (error) {
      print('Error creating checkout session: $error');
      rethrow;
    }
  }

  Future<void> launchCheckoutUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch checkout URL: $url');
    }
  }
}





