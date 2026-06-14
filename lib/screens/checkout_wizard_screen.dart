import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../utils/toast_utils.dart';

class CheckoutWizardScreen extends StatefulWidget {
  final double totalAmount;

  const CheckoutWizardScreen({super.key, required this.totalAmount});

  @override
  State<CheckoutWizardScreen> createState() => _CheckoutWizardScreenState();
}

class _CheckoutWizardScreenState extends State<CheckoutWizardScreen> {
  int _currentStep = 0;
  
  // Step 1: Shipping Form
  final _shippingFormKey = GlobalKey<FormState>();
  String _name = '';
  String _address = '';
  String _city = '';
  String _zipCode = '';

  // Step 2: Payment Method
  String _paymentMethod = 'Credit Card';

  void _submitOrder() async {
    try {
      await DatabaseHelper.instance.clearCart();
      if (mounted) {
        ToastUtils.showSuccess(
          context,
          'Order Placed! Total: \$ ${widget.totalAmount.toStringAsFixed(2)}',
        );
        // Pop back to the Shop Screen
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Failed to place order.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0) {
            if (_shippingFormKey.currentState!.validate()) {
              _shippingFormKey.currentState!.save();
              setState(() => _currentStep++);
            }
          } else if (_currentStep == 1) {
            setState(() => _currentStep++);
          } else {
            _submitOrder();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            Navigator.pop(context);
          }
        },
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          final isLastStep = _currentStep == 2;
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(isLastStep ? 'Place Order' : 'Continue'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Shipping Details'),
            content: Form(
              key: _shippingFormKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    onSaved: (value) => _address = value!,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'City'),
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                          onSaved: (value) => _city = value!,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Zip Code'),
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                          onSaved: (value) => _zipCode = value!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Payment Method'),
            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  decoration: const InputDecoration(labelText: 'Select Payment Method'),
                  items: const [
                    DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
                    DropdownMenuItem(value: 'PayPal', child: Text('PayPal')),
                    DropdownMenuItem(value: 'Cash on Delivery', child: Text('Cash on Delivery')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _paymentMethod = value);
                    }
                  },
                ),
              ],
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Review Order'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Shipping Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('$_name\n$_address\n$_city, $_zipCode'),
                const SizedBox(height: 16),
                const Text('Payment Method:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_paymentMethod),
                const SizedBox(height: 16),
                const Divider(),
                Text(
                  'Total: \$ ${widget.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
}
