import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart_item.dart';
import 'cart_service.dart';

class StripeService {
	static final StripeService _instance = StripeService._internal();
	factory StripeService() => _instance;
	StripeService._internal();

	// Default API URL - can be configured via environment or config
	// In production, set this via environment variables or a config file
	String? _apiBaseUrl;
	
	String? get apiBaseUrl => _apiBaseUrl;
	
	void setApiBaseUrl(String? url) {
		_apiBaseUrl = url;
	}

	Future<String> createCheckoutSession({
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

			// Add shipping as a line item if cart is not empty
			if (cartItems.isNotEmpty) {
				final shippingAmount = (CartService.shippingRate * 100).round();
				lineItems.add({
					'price_data': {
						'currency': 'usd',
						'product_data': {
							'name': 'Shipping',
						},
						'unit_amount': shippingAmount,
					},
					'quantity': 1,
				});
			}

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

			// Determine the API URL
			String endpointUrl;
			if (apiUrl != null) {
				endpointUrl = apiUrl;
			} else if (_apiBaseUrl != null && _apiBaseUrl!.isNotEmpty) {
				endpointUrl = '$_apiBaseUrl/api/create-checkout';
			} else {
				// Try to use environment variable or show helpful error
				throw Exception(
					'Stripe API URL not configured. Please set the API base URL using StripeService().setApiBaseUrl("https://your-api.com") '
					'or provide apiUrl parameter. The backend should create a Stripe Checkout session and return the checkout URL.'
				);
			}

			// Make HTTP POST request to backend API
			final uri = Uri.parse(endpointUrl);
			final response = await http.post(
				uri,
				headers: {
					'Content-Type': 'application/json',
				},
				body: json.encode(requestBody),
			).timeout(
				const Duration(seconds: 30),
				onTimeout: () {
					throw Exception('Request timeout. Please check your internet connection and try again.');
				},
			);

			if (response.statusCode == 200 || response.statusCode == 201) {
				final responseData = json.decode(response.body) as Map<String, dynamic>;
				
				// Expecting the response to have a 'url' or 'checkoutUrl' field with the Stripe Checkout URL
				final checkoutUrl = responseData['url'] as String? ?? 
													responseData['checkoutUrl'] as String? ??
													responseData['checkout_url'] as String?;
				
				if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
					return checkoutUrl;
				} else {
					throw Exception('Backend API did not return a checkout URL. Response: ${response.body}');
				}
			} else {
				// Try to parse error message from response
				String errorMessage = 'Failed to create checkout session';
				try {
					final errorData = json.decode(response.body) as Map<String, dynamic>;
					errorMessage = errorData['error'] as String? ?? 
												errorData['message'] as String? ?? 
												errorMessage;
				} catch (_) {
					// If response is not JSON, use the status code
					errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
				}
				throw Exception(errorMessage);
			}
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





