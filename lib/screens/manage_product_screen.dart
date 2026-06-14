import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
import '../models/shopping_item.dart';
import '../utils/toast_utils.dart';

class ManageProductScreen extends StatefulWidget {
  final ShoppingItem? item;

  const ManageProductScreen({super.key, this.item});

  @override
  State<ManageProductScreen> createState() => _ManageProductScreenState();
}

class _ManageProductScreenState extends State<ManageProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  String? _imageBase64;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _priceController = TextEditingController(
      text: widget.item != null ? widget.item!.price.toString() : '',
    );
    _descController = TextEditingController(text: widget.item?.description ?? '');
    _imageBase64 = widget.item?.imageBase64;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Failed to pick image: $e');
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageBase64 = null;
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final description = _descController.text.trim();

    final product = ShoppingItem(
      id: widget.item?.id,
      name: name,
      price: price,
      description: description,
      imageBase64: _imageBase64,
    );

    try {
      if (widget.item == null) {
        await DatabaseHelper.instance.insertProduct(product);
        if (mounted) ToastUtils.showSuccess(context, 'Product added successfully.');
      } else {
        await DatabaseHelper.instance.updateProduct(product);
        if (mounted) ToastUtils.showSuccess(context, 'Product updated successfully.');
      }
      if (mounted) Navigator.pop(context, true); // Return true to signal refresh
    } catch (e) {
      if (mounted) ToastUtils.showError(context, 'Failed to save product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: _imageBase64 != null && _imageBase64!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                base64Decode(_imageBase64!.replaceAll(RegExp(r'\s+'), '')),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              ),
                            )
                          : const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Row(
                        children: [
                          if (_imageBase64 != null)
                            CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 18,
                              child: IconButton(
                                icon: const Icon(Icons.delete, size: 18, color: Colors.white),
                                onPressed: _removeImage,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                              onPressed: _pickImage,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Price is required';
                  if (double.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditing ? 'Update Product' : 'Add Product',
                    style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
