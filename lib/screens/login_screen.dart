import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';

class LoginScreen extends StatefulWidget {
	final String? redirectPath;

	const LoginScreen({super.key, this.redirectPath});

	@override
	State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
	final AuthService _authService = AuthService();
	final _formKey = GlobalKey<FormState>();
	final _usernameController = TextEditingController();
	final _passwordController = TextEditingController();
	bool _loading = false;
	String? _error;

	@override
	void dispose() {
		_usernameController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	Future<void> _handleLogin() async {
		if (!_formKey.currentState!.validate()) {
			return;
		}

		setState(() {
			_loading = true;
			_error = null;
		});

		try {
			final result = await _authService.login(
				_usernameController.text,
				_passwordController.text,
			);

			if (!mounted) return;

			if (result['success'] == true) {
				if (widget.redirectPath != null) {
					context.go(widget.redirectPath!);
				} else {
					context.go('/admin');
				}
			} else {
				setState(() {
					_error = result['error'] as String? ?? 'Invalid credentials';
					_loading = false;
				});
			}
		} catch (error) {
			if (!mounted) return;
			setState(() {
				_error = 'An error occurred: $error';
				_loading = false;
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				children: [
					const AppHeader(),
					Expanded(
						child: Center(
							child: Container(
								constraints: const BoxConstraints(maxWidth: 400),
								margin: const EdgeInsets.symmetric(horizontal: 15),
								padding: const EdgeInsets.all(40),
								child: Form(
									key: _formKey,
									child: Column(
										mainAxisAlignment: MainAxisAlignment.center,
										children: [
											const Text(
												'Admin Login',
												style: TextStyle(
													fontSize: 32,
													fontWeight: FontWeight.bold,
												),
											),
											const SizedBox(height: 40),
											TextFormField(
												controller: _usernameController,
												decoration: const InputDecoration(
													labelText: 'Username',
													border: OutlineInputBorder(),
												),
												validator: (value) {
													if (value == null || value.isEmpty) {
														return 'Please enter your username';
													}
													return null;
												},
											),
											const SizedBox(height: 20),
											TextFormField(
												controller: _passwordController,
												decoration: const InputDecoration(
													labelText: 'Password',
													border: OutlineInputBorder(),
												),
												obscureText: true,
												validator: (value) {
													if (value == null || value.isEmpty) {
														return 'Please enter your password';
													}
													return null;
												},
											),
											if (_error != null) ...[
												const SizedBox(height: 20),
												Text(
													_error!,
													style: const TextStyle(color: Colors.red),
													textAlign: TextAlign.center,
												),
											],
											const SizedBox(height: 30),
											SizedBox(
												width: double.infinity,
												child: ElevatedButton(
													onPressed: _loading ? null : _handleLogin,
													style: ElevatedButton.styleFrom(
														backgroundColor: Colors.black,
														foregroundColor: Colors.white,
														padding: const EdgeInsets.symmetric(vertical: 15),
														minimumSize: const Size(double.infinity, 50),
													),
													child: _loading
															? const SizedBox(
																	height: 20,
																	width: 20,
																	child: CircularProgressIndicator(strokeWidth: 2),
																)
															: const Text('Login'),
												),
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
