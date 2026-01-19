import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';

class SuccessScreen extends StatelessWidget {
	final String? sessionId;

	const SuccessScreen({super.key, this.sessionId});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				children: [
					const AppHeader(),
					Expanded(
						child: Center(
							child: Container(
								constraints: const BoxConstraints(maxWidth: 600),
								margin: const EdgeInsets.symmetric(horizontal: 15),
								padding: const EdgeInsets.all(40),
								child: Column(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										const Icon(
											Icons.check_circle,
											color: Colors.green,
											size: 80,
										),
										const SizedBox(height: 30),
										const Text(
											'Order Successful!',
											style: TextStyle(
												fontSize: 32,
												fontWeight: FontWeight.bold,
											),
											textAlign: TextAlign.center,
										),
										const SizedBox(height: 20),
										Text(
											'Thank you for your order. Your order has been placed successfully.',
											style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
											textAlign: TextAlign.center,
										),
										if (sessionId != null) ...[
											const SizedBox(height: 20),
											Text(
												'Session ID: $sessionId',
												style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
												textAlign: TextAlign.center,
											),
										],
										const SizedBox(height: 40),
										ElevatedButton(
											onPressed: () => context.go('/shop'),
											style: ElevatedButton.styleFrom(
												backgroundColor: Colors.black,
												foregroundColor: Colors.white,
												padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
												minimumSize: const Size(double.infinity, 50),
											),
											child: const Text('Continue Shopping'),
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
