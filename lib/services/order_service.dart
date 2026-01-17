import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order.dart';
import '../services/auth_service.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal() {
    _loadOrders();
  }

  static const String _storageKey = 'orders';
  List<Order> _orders = [];

  Future<void> _loadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersData = prefs.getString(_storageKey);
      if (ordersData != null) {
        final List<dynamic> jsonList = json.decode(ordersData) as List<dynamic>;
        _orders = jsonList
            .map((json) => Order.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error loading orders: $e');
      _orders = [];
    }
  }

  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersData = json.encode(_orders.map((order) => order.toJson()).toList());
      await prefs.setString(_storageKey, ordersData);
    } catch (e) {
      print('Error saving orders: $e');
    }
  }

  Future<List<Order>> loadOrders() async {
    await _loadOrders();
    return List.unmodifiable(_orders);
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Order> createOrder({
    required String stripeSessionId,
    required String orderNumber,
    required Map<String, dynamic> customer,
    required Map<String, dynamic> shipping,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> totals,
    String? notes,
  }) async {
    final now = DateTime.now().toIso8601String();
    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';

    final order = Order(
      id: orderId,
      stripeSessionId: stripeSessionId,
      orderNumber: orderNumber,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
      customer: OrderCustomer.fromJson(customer),
      shipping: shipping,
      items: items.map((item) => OrderItem.fromJson(item)).toList(),
      totals: OrderTotals.fromJson(totals),
      currency: 'usd',
      notes: notes,
    );

    _orders.add(order);
    await _saveOrders();
    return order;
  }

  Future<Order> updateOrderStatus(String id, String status) async {
    final order = getOrderById(id);
    if (order == null) {
      throw Exception('Order not found');
    }

    final updatedOrders = _orders.map((o) {
      if (o.id == id) {
        return Order(
          id: o.id,
          stripeSessionId: o.stripeSessionId,
          stripePaymentIntentId: o.stripePaymentIntentId,
          orderNumber: o.orderNumber,
          status: status,
          createdAt: o.createdAt,
          updatedAt: DateTime.now().toIso8601String(),
          customer: o.customer,
          shipping: o.shipping,
          items: o.items,
          totals: o.totals,
          currency: o.currency,
          notes: o.notes,
        );
      }
      return o;
    }).toList();

    _orders = updatedOrders;
    await _saveOrders();
    
    final updatedOrder = getOrderById(id);
    if (updatedOrder == null) {
      throw Exception('Order not found after update');
    }
    return updatedOrder;
  }

  Future<void> deleteOrder(String id) async {
    final order = getOrderById(id);
    if (order == null) {
      throw Exception('Order not found');
    }

    _orders.removeWhere((o) => o.id == id);
    await _saveOrders();
  }

  String generateOrderNumber() {
    final year = DateTime.now().year;
    final yearOrders = _orders.where((o) {
      final orderYear = DateTime.parse(o.createdAt).year;
      return orderYear == year;
    }).length;
    final nextNum = (yearOrders + 1).toString().padLeft(3, '0');
    return 'ORD-$year-$nextNum';
  }

  List<Order> get allOrders => List.unmodifiable(_orders);
}





