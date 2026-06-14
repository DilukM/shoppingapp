import 'dart:convert';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/shopping_item.dart';
import '../utils/toast_utils.dart';
import 'cart_screen.dart';
import 'manage_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
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
      setState(() {
        _products = products;
      });
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

  Future<void> _addToCart(ShoppingItem product) async {
    try {
      await DatabaseHelper.instance.addToCart(product);
      if (mounted) {
        ToastUtils.showSuccess(context, '${product.name} added to cart!');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Failed to add to cart.');
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
        title: const Text('Shopping App'),
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
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('No products available.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: product.imageBase64 != null
                                ? Image.memory(
                                    base64Decode(product.imageBase64!),
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                  ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.description,
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '\$ ${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      PopupMenuButton<String>(
                                        padding: EdgeInsets.zero,
                                        onSelected: (value) async {
                                          if (value == 'edit') {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ManageProductScreen(item: product)),
                                            );
                                            if (result == true) _loadProducts();
                                          } else if (value == 'delete') {
                                            _deleteProduct(product);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Text('Edit'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                        icon: const Icon(Icons.more_vert, size: 20),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => _addToCart(product),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          minimumSize: const Size(0, 32),
                                        ),
                                        child: const Text('Add'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
