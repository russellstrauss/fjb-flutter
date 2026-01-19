import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/product_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/success_screen.dart';
import 'screens/about_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/orders_screen.dart';
import 'services/auth_service.dart';
import 'services/stripe_service.dart';

void main() {
	// Configure Stripe API URL from environment variable or use localhost fallback
	const apiUrl = String.fromEnvironment(
		'STRIPE_API_URL',
		defaultValue: 'http://localhost:3000',
	);
	StripeService().setApiBaseUrl(apiUrl);
	
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	// Create router once as static final to enable hot reload
	static final GoRouter _router = GoRouter(
		initialLocation: '/',
		routes: [
			GoRoute(
				path: '/',
				name: 'home',
				builder: (context, state) => const HomeScreen(),
			),
			GoRoute(
				path: '/shop',
				name: 'shop',
				builder: (context, state) {
					final category = state.uri.queryParameters['category'];
					return ShopScreen(category: category);
				},
			),
			GoRoute(
				path: '/product/:slug',
				name: 'product',
				builder: (context, state) {
					final slug = state.pathParameters['slug']!;
					return ProductScreen(slug: slug);
				},
			),
			GoRoute(
				path: '/cart',
				name: 'cart',
				builder: (context, state) => const CartScreen(),
			),
			GoRoute(
				path: '/checkout',
				name: 'checkout',
				builder: (context, state) => const CheckoutScreen(),
			),
			GoRoute(
				path: '/success',
				name: 'success',
				builder: (context, state) {
					final sessionId = state.uri.queryParameters['session_id'];
					return SuccessScreen(sessionId: sessionId);
				},
			),
			GoRoute(
				path: '/about',
				name: 'about',
				builder: (context, state) => const AboutScreen(),
			),
			GoRoute(
				path: '/login',
				name: 'login',
				builder: (context, state) {
					final redirect = state.uri.queryParameters['redirect'];
					return LoginScreen(redirectPath: redirect);
				},
			),
			GoRoute(
				path: '/admin',
				name: 'admin',
				builder: (context, state) => const AdminScreen(),
			),
			GoRoute(
				path: '/orders',
				name: 'orders',
				builder: (context, state) => const OrdersScreen(),
			),
		],
		errorBuilder: (context, state) => Scaffold(
			body: Center(
				child: Text('Page not found: ${state.uri}'),
			),
		),
	);

	@override
	Widget build(BuildContext context) {
		return MaterialApp.router(
			title: 'Farmer John\'s Botanicals',
			debugShowCheckedModeBanner: false,
			theme: _buildTheme(),
			routerConfig: _router,
		);
	}



	ThemeData _buildTheme() {
		// Use google_fonts package for proper Flutter web font loading
		final textTheme = TextTheme(
			displayLarge: GoogleFonts.montserrat(
				fontSize: 32,
				fontWeight: FontWeight.w600,
			),
			displayMedium: GoogleFonts.montserrat(
				fontSize: 28,
				fontWeight: FontWeight.w600,
			),
			displaySmall: GoogleFonts.montserrat(
				fontSize: 24,
				fontWeight: FontWeight.w600,
			),
			headlineMedium: GoogleFonts.montserrat(
				fontSize: 20,
				fontWeight: FontWeight.w600,
			),
			titleLarge: GoogleFonts.montserrat(
				fontSize: 18,
				fontWeight: FontWeight.w500,
			),
			bodyLarge: GoogleFonts.openSans(
				fontSize: 16,
				fontWeight: FontWeight.w400,
			),
			bodyMedium: GoogleFonts.openSans(
				fontSize: 14,
				fontWeight: FontWeight.w400,
			),
			bodySmall: GoogleFonts.openSans(
				fontSize: 12,
				fontWeight: FontWeight.w400,
			),
		);
		
		final theme = ThemeData(
			useMaterial3: true,
			colorScheme: ColorScheme.fromSeed(
				seedColor: const Color(0xFF0098D6),
				primary: const Color(0xFF0098D6),
				secondary: const Color(0xFF333333),
			),
			textTheme: textTheme,
			scaffoldBackgroundColor: Colors.white,
			appBarTheme: const AppBarTheme(
				backgroundColor: Colors.white,
				foregroundColor: Colors.black,
				elevation: 0,
			),
			buttonTheme: const ButtonThemeData(
				buttonColor: Color(0xFF333333),
				textTheme: ButtonTextTheme.primary,
			),
		);
		
		return theme;
	}
}

