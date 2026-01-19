import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';

class AboutScreen extends StatelessWidget {
	const AboutScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				children: [
					const AppHeader(),
					Expanded(
						child: SingleChildScrollView(
							child: Container(
								constraints: const BoxConstraints(maxWidth: 800),
								margin: const EdgeInsets.symmetric(horizontal: 15),
								padding: const EdgeInsets.symmetric(vertical: 40),
								child: const Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											'About Farmer John\'s Botanicals',
											style: TextStyle(
												fontSize: 32,
												fontWeight: FontWeight.bold,
											),
										),
										SizedBox(height: 30),
										Text(
											'Farmer John\'s Botanicals makes the world a more colorful place by specializing in natural fiber fashion lines and textiles.',
											style: TextStyle(fontSize: 16),
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
