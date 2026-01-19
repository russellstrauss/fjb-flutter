import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../models/order.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';

class OrdersScreen extends StatefulWidget {
	const OrdersScreen({super.key});

	@override
	State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
	final AuthService _authService = AuthService();
	final OrderService _orderService = OrderService();
	List<Order> _orders = [];
	bool _checkingAuth = true;
	bool _isAuthenticated = false;
	bool _loading = true;

	@override
	void initState() {
		super.initState();
		_checkAuth();
	}

	Future<void> _checkAuth() async {
		final isAuthenticated = await _authService.checkAuth();
		setState(() {
			_isAuthenticated = isAuthenticated;
			_checkingAuth = false;
		});

		if (!isAuthenticated) {
			if (mounted) {
				context.go('/login?redirect=/orders');
			}
			return;
		}

		await _loadOrders();
	}

	Future<void> _loadOrders() async {
		setState(() {
			_loading = true;
		});

		try {
			final orders = await _orderService.loadOrders();
			setState(() {
				_orders = orders;
				_loading = false;
			});
		} catch (error) {
			setState(() {
				_loading = false;
			});
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('Error loading orders: $error')),
				);
			}
		}
	}

	@override
	Widget build(BuildContext context) {
		if (_checkingAuth) {
			return const Scaffold(
				body: Center(child: CircularProgressIndicator()),
			);
		}

		if (!_isAuthenticated) {
			return const SizedBox.shrink();
		}

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
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Row(
											mainAxisAlignment: MainAxisAlignment.spaceBetween,
											children: [
												const Text(
													'Orders',
													style: TextStyle(
														fontSize: 32,
														fontWeight: FontWeight.bold,
													),
												),
												IconButton(
													icon: const Icon(Icons.refresh),
													onPressed: _loadOrders,
												),
											],
										),
										const SizedBox(height: 30),
										_loading
												? const Center(child: CircularProgressIndicator())
												: _orders.isEmpty
														? const Center(
																child: Padding(
																	padding: EdgeInsets.all(40),
																	child: Text('No orders found'),
																),
															)
														: ListView.builder(
																shrinkWrap: true,
																physics: const NeverScrollableScrollPhysics(),
																itemCount: _orders.length,
																itemBuilder: (context, index) {
																	return _OrderCard(order: _orders[index]);
																},
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

class _OrderCard extends StatelessWidget {
	final Order order;

	const _OrderCard({required this.order});

	String _formatDate(String dateString) {
		try {
			final date = DateTime.parse(dateString);
			return '${date.month}/${date.day}/${date.year}';
		} catch (e) {
			return dateString;
		}
	}

	String _formatPrice(double price) {
		return '\$${price.toStringAsFixed(2)}';
	}

	Color _getStatusColor(String status) {
		switch (status.toLowerCase()) {
			case 'completed':
				return Colors.green;
			case 'pending':
				return Colors.orange;
			case 'cancelled':
				return Colors.red;
			default:
				return Colors.grey;
		}
	}

	@override
	Widget build(BuildContext context) {
		return Card(
			margin: const EdgeInsets.only(bottom: 15),
			child: ExpansionTile(
				leading: Container(
					padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
					decoration: BoxDecoration(
						color: _getStatusColor(order.status),
						borderRadius: BorderRadius.circular(4),
					),
					child: Text(
						order.status.toUpperCase(),
						style: const TextStyle(
							color: Colors.white,
							fontSize: 12,
							fontWeight: FontWeight.bold,
						),
					),
				),
				title: Text(
					order.orderNumber,
					style: const TextStyle(fontWeight: FontWeight.bold),
				),
				subtitle: Text(
					'${_formatDate(order.createdAt)} • ${_formatPrice(order.totals.total)}',
				),
				children: [
					Padding(
						padding: const EdgeInsets.all(16),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								_OrderDetailRow(label: 'Customer', value: order.customer.name),
								_OrderDetailRow(label: 'Email', value: order.customer.email),
								if (order.customer.phone != null)
									_OrderDetailRow(label: 'Phone', value: order.customer.phone!),
								const Divider(),
								const Text(
									'Items:',
									style: TextStyle(fontWeight: FontWeight.bold),
								),
								const SizedBox(height: 10),
								...order.items.map((item) => Padding(
											padding: const EdgeInsets.only(bottom: 5),
											child: Text('${item.quantity}x ${item.name} - ${_formatPrice(item.total)}'),
										)),
								const Divider(),
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
										Text(
											_formatPrice(order.totals.total),
											style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
										),
									],
								),
							],
						),
					),
				],
			),
		);
	}
}

class _OrderDetailRow extends StatelessWidget {
	final String label;
	final String value;

	const _OrderDetailRow({required this.label, required this.value});

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.only(bottom: 8),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					SizedBox(
						width: 100,
						child: Text(
							'$label:',
							style: const TextStyle(fontWeight: FontWeight.bold),
						),
					),
					Expanded(child: Text(value)),
				],
			),
		);
	}
}
