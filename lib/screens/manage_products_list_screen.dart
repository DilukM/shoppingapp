import 'dart:convert';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/shopping_item.dart';
import '../utils/toast_utils.dart';
import 'manage_product_screen.dart';

class ManageProductsListScreen extends StatefulWidget {
  const ManageProductsListScreen({super.key});

  @override
  State<ManageProductsListScreen> createState() => _ManageProductsListScreenState();
}

class _ManageProductsListScreenState extends State<ManageProductsListScreen> {
  List<ShoppingItem> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await DatabaseHelper.instance.getProducts();
      if (mounted) {
        setState(() {
          _products = products;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Failed to load products: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProduct(ShoppingItem product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseHelper.instance.deleteProduct(product.id!);
        if (mounted) ToastUtils.showInfo(context, 'Product deleted.');
        _loadProducts();
      } catch (e) {
        if (mounted) ToastUtils.showError(context, 'Failed to delete: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Product',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageProductScreen()),
              );
              if (result == true) _loadProducts();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('No products available.'))
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ListTile(
                        leading: product.imageBase64 != null && product.imageBase64!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  base64Decode(product.imageBase64!.replaceAll(RegExp(r'\s+'), '')),
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
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${product.description}\n\$ ${product.price.toStringAsFixed(2)}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Edit',
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ManageProductScreen(item: product)),
                                );
                                if (result == true) _loadProducts();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () => _deleteProduct(product),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
