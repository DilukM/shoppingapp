import 'dart:convert';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/shopping_item.dart';
import '../utils/toast_utils.dart';
import 'checkout_wizard_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await DatabaseHelper.instance.getCartItems();
      setState(() {
        _cartItems = items;
      });
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Failed to load cart: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double get _totalAmount {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  Future<void> _updateQuantity(CartItem item, int delta) async {
    final newQuantity = item.quantity + delta;
    try {
      await DatabaseHelper.instance.updateCartItemQuantity(item.id!, newQuantity);
      _loadCart(); // Reload the cart to reflect changes
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Failed to update quantity.');
      }
    }
  }

  Future<void> _removeItem(CartItem item) async {
    try {
      await DatabaseHelper.instance.removeFromCart(item.id!);
      if (mounted) {
        ToastUtils.showInfo(context, '${item.name} removed from cart.');
      }
      _loadCart();
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Failed to remove item.');
      }
    }
  }

  Future<void> _checkout() async {
    if (_cartItems.isEmpty) {
      ToastUtils.showError(context, 'Cart is empty. Add items to checkout.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutWizardScreen(totalAmount: _totalAmount),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _cartItems.isEmpty
                      ? const Center(child: Text('Your cart is empty.'))
                      : ListView.builder(
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: ListTile(
                                leading: item.imageBase64 != null && item.imageBase64!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          base64Decode(item.imageBase64!.replaceAll(RegExp(r'\s+'), '')),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                            Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
                                        ),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.image, color: Colors.grey),
                                      ),
                                title: Text(item.name),
                                subtitle: Text(
                                  '\$ ${item.price.toStringAsFixed(2)} x ${item.quantity}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () => _updateQuantity(item, -1),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () => _updateQuantity(item, 1),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeItem(item),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(77), // 0.3 opacity
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: \$ ${_totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _checkout,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Checkout',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
