import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';

class AdminScreen extends StatefulWidget {
	const AdminScreen({super.key});

	@override
	State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
	final AuthService _authService = AuthService();
	bool _isAuthenticated = false;
	bool _checkingAuth = true;

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
				context.go('/login?redirect=/admin');
			}
		}
	}

	Future<void> _handleLogout() async {
		await _authService.logout();
		if (mounted) {
			context.go('/');
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
								padding: const EdgeInsets.symmetric(vertical: 40),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Row(
											mainAxisAlignment: MainAxisAlignment.spaceBetween,
											children: [
												const Text(
													'Admin Dashboard',
													style: TextStyle(
														fontSize: 32,
														fontWeight: FontWeight.bold,
													),
												),
												ElevatedButton(
													onPressed: _handleLogout,
													style: ElevatedButton.styleFrom(
														backgroundColor: Colors.red,
														foregroundColor: Colors.white,
													),
													child: const Text('Logout'),
												),
											],
										),
										const SizedBox(height: 40),
										GridView.count(
											shrinkWrap: true,
											physics: const NeverScrollableScrollPhysics(),
											crossAxisCount: MediaQuery.of(context).size.width > 720 ? 2 : 1,
											crossAxisSpacing: 20,
											mainAxisSpacing: 20,
											childAspectRatio: 2.5,
											children: [
												_AdminCard(
													title: 'Orders',
													description: 'View and manage orders',
													icon: Icons.receipt_long,
													onTap: () => context.push('/orders'),
												),
											],
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

class _AdminCard extends StatelessWidget {
	final String title;
	final String description;
	final IconData icon;
	final VoidCallback onTap;

	const _AdminCard({
		required this.title,
		required this.description,
		required this.icon,
		required this.onTap,
	});

	@override
	Widget build(BuildContext context) {
		return Card(
			child: InkWell(
				onTap: onTap,
				child: Padding(
					padding: const EdgeInsets.all(20),
					child: Row(
						children: [
							Icon(icon, size: 48, color: Colors.black),
							const SizedBox(width: 20),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Text(
											title,
											style: const TextStyle(
												fontSize: 20,
												fontWeight: FontWeight.bold,
											),
										),
										const SizedBox(height: 5),
										Text(
											description,
											style: TextStyle(color: Colors.grey.shade600),
										),
									],
								),
							),
							const Icon(Icons.chevron_right),
						],
					),
				),
			),
		);
	}
}
