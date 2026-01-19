import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/cart_service.dart';
import '../services/stripe_service.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';

class CheckoutScreen extends StatefulWidget {
	const CheckoutScreen({super.key});

	@override
	State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
	final CartService _cartService = CartService();
	final StripeService _stripeService = StripeService();
	final _formKey = GlobalKey<FormState>();
	bool _processing = false;

	final _firstNameController = TextEditingController();
	final _lastNameController = TextEditingController();
	final _emailController = TextEditingController();
	final _phoneController = TextEditingController();
	final _addressController = TextEditingController();
	final _address2Controller = TextEditingController();
	final _cityController = TextEditingController();
	final _stateController = TextEditingController();
	final _postalCodeController = TextEditingController();
	final _orderNotesController = TextEditingController();

	String _country = 'US';

	final Map<String, bool> _fieldErrors = {};

	@override
	void dispose() {
		_firstNameController.dispose();
		_lastNameController.dispose();
		_emailController.dispose();
		_phoneController.dispose();
		_addressController.dispose();
		_address2Controller.dispose();
		_cityController.dispose();
		_stateController.dispose();
		_postalCodeController.dispose();
		_orderNotesController.dispose();
		super.dispose();
	}

	void _formatPhoneNumber(String value) {
		final digits = value.replaceAll(RegExp(r'\D'), '');
		// Limit to 10 digits
		final limitedDigits = digits.length > 10 ? digits.substring(0, 10) : digits;
		String formatted = '';
		if (limitedDigits.length > 0) {
			if (limitedDigits.length <= 3) {
				formatted = '($limitedDigits';
			} else if (limitedDigits.length <= 6) {
				formatted = '(${limitedDigits.substring(0, 3)}) ${limitedDigits.substring(3)}';
			} else {
				final areaCode = limitedDigits.substring(0, 3);
				final exchange = limitedDigits.substring(3, 6);
				final number = limitedDigits.substring(6);
				formatted = '($areaCode) $exchange-$number';
			}
		}
		_phoneController.value = TextEditingValue(
			text: formatted,
			selection: TextSelection.collapsed(offset: formatted.length),
		);
	}

	bool _validateForm() {
		setState(() {
			_fieldErrors.clear();
		});

		bool isValid = true;

		if (_firstNameController.text.trim().isEmpty) {
			_fieldErrors['firstName'] = true;
			isValid = false;
		}
		if (_lastNameController.text.trim().isEmpty) {
			_fieldErrors['lastName'] = true;
			isValid = false;
		}
		if (_emailController.text.trim().isEmpty) {
			_fieldErrors['email'] = true;
			isValid = false;
		}
		if (_phoneController.text.trim().isEmpty) {
			_fieldErrors['phone'] = true;
			isValid = false;
		}
		if (_addressController.text.trim().isEmpty) {
			_fieldErrors['address'] = true;
			isValid = false;
		}
		if (_cityController.text.trim().isEmpty) {
			_fieldErrors['city'] = true;
			isValid = false;
		}
		if (_stateController.text.trim().isEmpty) {
			_fieldErrors['state'] = true;
			isValid = false;
		}
		if (_postalCodeController.text.trim().isEmpty) {
			_fieldErrors['postalCode'] = true;
			isValid = false;
		}
		if (_country.isEmpty) {
			_fieldErrors['country'] = true;
			isValid = false;
		}

		setState(() {});

		return isValid;
	}

	Future<void> _handleSubmit() async {
		if (_cartService.isEmpty()) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Your cart is empty')),
			);
			return;
		}

		if (!_validateForm()) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Please fill in all required fields')),
			);
			return;
		}

		setState(() {
			_processing = true;
		});

		try {
			final customerDetails = {
				'name': '${_firstNameController.text} ${_lastNameController.text}',
				'email': _emailController.text,
				'phone': _phoneController.text,
				'shipping': {
					'name': '${_firstNameController.text} ${_lastNameController.text}',
					'address': {
						'line1': _addressController.text,
						'line2': _address2Controller.text.isEmpty ? null : _address2Controller.text,
						'city': _cityController.text,
						'state': _stateController.text,
						'postal_code': _postalCodeController.text,
						'country': _country,
					}
				},
				'notes': _orderNotesController.text.isEmpty ? null : _orderNotesController.text,
			};

			final checkoutUrl = await _stripeService.createCheckoutSession(
				cartItems: _cartService.getItems(),
				customerDetails: customerDetails,
			);

			// Launch the Stripe checkout URL
			if (!mounted) return;
			await _stripeService.launchCheckoutUrl(checkoutUrl);
		} catch (error) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Error: $error')),
			);
		} finally {
			if (mounted) {
				setState(() {
					_processing = false;
				});
			}
		}
	}

	@override
	Widget build(BuildContext context) {
		final items = _cartService.getItems();
		final subtotal = _cartService.getSubtotal();
		final shipping = _cartService.getShipping();
		final total = _cartService.getTotal();
		final isEmpty = _cartService.isEmpty();

		return Scaffold(
			body: Column(
				children: [
					const AppHeader(),
					Expanded(
						child: SingleChildScrollView(
							child: Container(
								constraints: const BoxConstraints(maxWidth: 800),
								margin: const EdgeInsets.symmetric(horizontal: 15),
								padding: const EdgeInsets.symmetric(vertical: 20),
								child: isEmpty
										? Center(
												child: Column(
													mainAxisAlignment: MainAxisAlignment.center,
													children: [
														const Text('Your cart is empty.'),
														const SizedBox(height: 20),
														ElevatedButton(
															onPressed: () => context.push('/shop'),
															child: const Text('Continue Shopping'),
														),
													],
												),
											)
										: Form(
												key: _formKey,
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														const Text(
															'Checkout',
															style: TextStyle(
																fontSize: 32,
																fontWeight: FontWeight.bold,
															),
														),
														const SizedBox(height: 30),
														// Customer Information
														_FormSection(
															title: 'Customer Information',
															children: [
																Row(
																	children: [
																		Expanded(
																			child: _FormField(
																				label: 'First Name *',
																				controller: _firstNameController,
																				hasError: _fieldErrors['firstName'] ?? false,
																			),
																		),
																		const SizedBox(width: 15),
																		Expanded(
																			child: _FormField(
																				label: 'Last Name *',
																				controller: _lastNameController,
																				hasError: _fieldErrors['lastName'] ?? false,
																			),
																		),
																	],
																),
																_FormField(
																	label: 'Email *',
																	controller: _emailController,
																	keyboardType: TextInputType.emailAddress,
																	hasError: _fieldErrors['email'] ?? false,
																),
																_FormField(
																	label: 'Phone *',
																	controller: _phoneController,
																	keyboardType: TextInputType.phone,
																	onChanged: _formatPhoneNumber,
																	hasError: _fieldErrors['phone'] ?? false,
																	inputFormatters: [
																		FilteringTextInputFormatter.digitsOnly,
																	],
																),
															],
														),
														const SizedBox(height: 30),
														// Shipping Address
														_FormSection(
															title: 'Shipping Address',
															children: [
																_FormField(
																	label: 'Street Address *',
																	controller: _addressController,
																	hasError: _fieldErrors['address'] ?? false,
																),
																_FormField(
																	label: 'Apartment, suite, etc. (Optional)',
																	controller: _address2Controller,
																),
																Row(
																	children: [
																		Expanded(
																			child: _FormField(
																				label: 'City *',
																				controller: _cityController,
																				hasError: _fieldErrors['city'] ?? false,
																			),
																		),
																		const SizedBox(width: 15),
																		Expanded(
																			child: _FormField(
																				label: 'State/Province *',
																				controller: _stateController,
																				hasError: _fieldErrors['state'] ?? false,
																			),
																		),
																	],
																),
																Row(
																	children: [
																		Expanded(
																			child: _FormField(
																				label: 'Postal Code *',
																				controller: _postalCodeController,
																				hasError: _fieldErrors['postalCode'] ?? false,
																			),
																		),
																		const SizedBox(width: 15),
																		Expanded(
																			child: Column(
																				crossAxisAlignment: CrossAxisAlignment.start,
																				children: [
																					const Text(
																						'Country *',
																						style: TextStyle(fontWeight: FontWeight.bold),
																					),
																					const SizedBox(height: 5),
																					DropdownButtonFormField<String>(
																						value: _country,
																						decoration: InputDecoration(
																							errorText: _fieldErrors['country'] ?? false ? 'Required' : null,
																							border: const OutlineInputBorder(),
																						),
																						items: const [
																							DropdownMenuItem(value: 'US', child: Text('United States')),
																							DropdownMenuItem(value: 'CA', child: Text('Canada')),
																							DropdownMenuItem(value: 'GB', child: Text('United Kingdom')),
																						],
																						onChanged: (value) {
																							setState(() {
																								_country = value ?? 'US';
																								_fieldErrors.remove('country');
																							});
																						},
																					),
																				],
																			),
																		),
																	],
																),
															],
														),
														const SizedBox(height: 30),
														// Order Notes
														_FormSection(
															title: 'Order Notes',
															children: [
																_FormField(
																	label: 'Order Notes and Customization Requests (Optional)',
																	controller: _orderNotesController,
																	maxLines: 4,
																),
															],
														),
														const SizedBox(height: 30),
														// Order Summary
														_FormSection(
															title: 'Order Summary',
															children: [
																...items.map((item) => Padding(
																			padding: const EdgeInsets.only(bottom: 10),
																			child: Row(
																				mainAxisAlignment: MainAxisAlignment.spaceBetween,
																				children: [
																					Expanded(
																						child: Column(
																							crossAxisAlignment: CrossAxisAlignment.start,
																							children: [
																								Text(item.name),
																								if (item.variation != null && item.variation!['size'] != null)
																									Text(
																										'Size: ${item.variation!['size']}',
																										style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
																									),
																							],
																						),
																					),
																					Text(
																						_cartService.formatPrice(item.price * item.quantity),
																						style: const TextStyle(fontWeight: FontWeight.bold),
																					),
																				],
																			),
																		)),
																const Divider(),
																Row(
																	mainAxisAlignment: MainAxisAlignment.spaceBetween,
																	children: [
																		const Text('Subtotal:', style: TextStyle(fontSize: 16)),
																		Text(_cartService.formatPrice(subtotal), style: const TextStyle(fontSize: 16)),
																	],
																),
																const SizedBox(height: 10),
																Row(
																	mainAxisAlignment: MainAxisAlignment.spaceBetween,
																	children: [
																		const Text('Shipping:', style: TextStyle(fontSize: 16)),
																		Text(_cartService.formatPrice(shipping), style: const TextStyle(fontSize: 16)),
																	],
																),
																const Divider(height: 20),
																Row(
																	mainAxisAlignment: MainAxisAlignment.spaceBetween,
																	children: [
																		const Text(
																			'Total:',
																			style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
																		),
																		Text(
																			_cartService.formatPrice(total),
																			style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
																		),
																	],
																),
															],
														),
														const SizedBox(height: 30),
														// Actions
														Row(
															children: [
																Expanded(
																	child: OutlinedButton(
																		onPressed: _processing ? null : () => context.pop(),
																		child: const Text('Back to Cart'),
																	),
																),
																const SizedBox(width: 15),
																Expanded(
																	child: ElevatedButton(
																		onPressed: _processing ? null : _handleSubmit,
																		style: ElevatedButton.styleFrom(
																			backgroundColor: Colors.black,
																			foregroundColor: Colors.white,
																			padding: const EdgeInsets.symmetric(vertical: 15),
																			minimumSize: const Size(double.infinity, 50),
																		),
																		child: _processing
																				? const SizedBox(
																						height: 20,
																						width: 20,
																						child: CircularProgressIndicator(strokeWidth: 2),
																					)
																				: const Text('Proceed to Payment'),
																	),
																),
															],
														),
													],
												),
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

class _FormSection extends StatelessWidget {
	final String title;
	final List<Widget> children;

	const _FormSection({
		required this.title,
		required this.children,
	});

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(20),
			decoration: BoxDecoration(
				color: Colors.grey.shade50,
				borderRadius: BorderRadius.circular(8),
				border: Border.all(color: Colors.grey.shade300),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						title,
						style: const TextStyle(
							fontSize: 20,
							fontWeight: FontWeight.bold,
						),
					),
					const SizedBox(height: 20),
					...children,
				],
			),
		);
	}
}

class _FormField extends StatelessWidget {
	final String label;
	final TextEditingController controller;
	final TextInputType? keyboardType;
	final int? maxLines;
	final void Function(String)? onChanged;
	final bool hasError;
	final List<TextInputFormatter>? inputFormatters;

	const _FormField({
		required this.label,
		required this.controller,
		this.keyboardType,
		this.maxLines,
		this.onChanged,
		this.hasError = false,
		this.inputFormatters,
	});

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					label,
					style: const TextStyle(fontWeight: FontWeight.bold),
				),
				const SizedBox(height: 5),
				TextFormField(
					controller: controller,
					keyboardType: keyboardType,
					maxLines: maxLines,
					onChanged: onChanged,
					inputFormatters: inputFormatters,
					decoration: InputDecoration(
						errorText: hasError ? 'This field is required' : null,
						border: const OutlineInputBorder(),
					),
				),
			],
		);
	}
}
