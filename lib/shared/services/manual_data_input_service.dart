import 'package:flutter/material.dart';
import 'temp_memory_service.dart';
import 'groq_ai_service.dart';

class ManualDataInputService {
  static final ManualDataInputService _instance = ManualDataInputService._internal();
  factory ManualDataInputService() => _instance;
  ManualDataInputService._internal();

  final TempMemoryService _memoryService = TempMemoryService();
  final GroqAIService _aiService = GroqAIService();

  Future<bool> showManualDataInput(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const ManualDataInputDialog();
      },
    ) ?? false;
  }

  Future<void> processManualData(Map<String, dynamic> data) async {
    // Set current month
    _memoryService.setCurrentMonth(data['month'] ?? 'August');
    
    // Add income
    if (data['income'] != null && data['income'] > 0) {
      _memoryService.addTransaction('salary', data['income'], true);
    }
    
    // Add expenses by category
    final categories = data['categories'] ?? {};
    for (var entry in categories.entries) {
      if (entry.value > 0) {
        _memoryService.addTransaction(entry.key, entry.value, false);
      }
    }
    
    // Add monthly data
    _memoryService.addMonthlyData(data['month'] ?? 'August', {
      'income': data['income'] ?? 0.0,
      'expenses': data['totalExpenses'] ?? 0.0,
      'savings': (data['income'] ?? 0.0) - (data['totalExpenses'] ?? 0.0),
      'categories': categories,
    });
  }
}

class ManualDataInputDialog extends StatefulWidget {
  const ManualDataInputDialog({super.key});

  @override
  State<ManualDataInputDialog> createState() => _ManualDataInputDialogState();
}

class _ManualDataInputDialogState extends State<ManualDataInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _monthController = TextEditingController(text: 'August');
  final _incomeController = TextEditingController();
  final _foodController = TextEditingController();
  final _transportController = TextEditingController();
  final _dataController = TextEditingController();
  final _entertainmentController = TextEditingController();
  final _utilitiesController = TextEditingController();
  final _otherController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('📊 Enter Your Financial Data'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _monthController,
                decoration: const InputDecoration(
                  labelText: 'Month',
                  hintText: 'e.g., August',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a month';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _incomeController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Income (₦)',
                  hintText: 'e.g., 450000',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your income';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Monthly Expenses by Category:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _foodController,
                decoration: const InputDecoration(
                  labelText: 'Food & Dining (₦)',
                  hintText: 'e.g., 87500',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _transportController,
                decoration: const InputDecoration(
                  labelText: 'Transport (₦)',
                  hintText: 'e.g., 45000',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _dataController,
                decoration: const InputDecoration(
                  labelText: 'Data & Internet (₦)',
                  hintText: 'e.g., 15000',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _entertainmentController,
                decoration: const InputDecoration(
                  labelText: 'Entertainment (₦)',
                  hintText: 'e.g., 25000',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _utilitiesController,
                decoration: const InputDecoration(
                  labelText: 'Utilities (₦)',
                  hintText: 'e.g., 30000',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _otherController,
                decoration: const InputDecoration(
                  labelText: 'Other Expenses (₦)',
                  hintText: 'e.g., 0',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitData,
          child: const Text('Submit & Analyze'),
        ),
      ],
    );
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'month': _monthController.text,
        'income': double.tryParse(_incomeController.text) ?? 0.0,
        'categories': {
          'food': double.tryParse(_foodController.text) ?? 0.0,
          'transport': double.tryParse(_transportController.text) ?? 0.0,
          'data': double.tryParse(_dataController.text) ?? 0.0,
          'entertainment': double.tryParse(_entertainmentController.text) ?? 0.0,
          'utilities': double.tryParse(_utilitiesController.text) ?? 0.0,
          'other': double.tryParse(_otherController.text) ?? 0.0,
        },
      };
      
      double totalExpenses = 0.0;
      for (var value in (data['categories'] as Map<String, dynamic>).values) {
        totalExpenses += (value as double);
      }
      data['totalExpenses'] = totalExpenses;
      
      Navigator.of(context).pop(true);
      
      // Process the data
      final service = ManualDataInputService();
      service.processManualData(data).then((_) {
        // Show success dialog with AI insights
        _showSuccessDialog(context, data);
      });
    }
  }

  void _showSuccessDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Financial data for ${data['month']} has been analyzed and your dashboard has been updated.'),
              const SizedBox(height: 16),
              Text('Income: ₦${(data['income'] / 1000).toStringAsFixed(0)}K'),
              Text('Expenses: ₦${(data['totalExpenses'] / 1000).toStringAsFixed(0)}K'),
              Text('Savings: ₦${((data['income'] - data['totalExpenses']) / 1000).toStringAsFixed(0)}K'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _monthController.dispose();
    _incomeController.dispose();
    _foodController.dispose();
    _transportController.dispose();
    _dataController.dispose();
    _entertainmentController.dispose();
    _utilitiesController.dispose();
    _otherController.dispose();
    super.dispose();
  }
}