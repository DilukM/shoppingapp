import '../models/shopping_item.dart';

final List<ShoppingItem> initialProducts = [
  ShoppingItem(
    name: 'Wireless Headphones',
    price: 99.99,
    description: 'Noise-cancelling over-ear headphones with 20 hours of battery life.',
    // Tiny base64 encoded transparent/grey pixel just to show functionality
    imageBase64: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
  ),
  ShoppingItem(
    name: 'Smart Watch',
    price: 199.50,
    description: 'Fitness tracker and smartwatch with heart rate monitoring.',
  ),
  ShoppingItem(
    name: 'Bluetooth Speaker',
    price: 45.00,
    description: 'Portable waterproof speaker with deep bass.',
  ),
  ShoppingItem(
    name: 'Mechanical Keyboard',
    price: 120.00,
    description: 'RGB mechanical keyboard with tactile switches.',
  ),
  ShoppingItem(
    name: 'Gaming Mouse',
    price: 59.99,
    description: 'Ergonomic gaming mouse with customizable buttons.',
  ),
  ShoppingItem(
    name: 'USB-C Hub',
    price: 35.50,
    description: '7-in-1 USB-C hub with HDMI, USB 3.0, and SD card reader.',
  ),
];
