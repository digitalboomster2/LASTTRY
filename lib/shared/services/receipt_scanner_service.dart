import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'groq_ai_service.dart';
import 'temp_memory_service.dart';

class ReceiptScannerService {
  static final ReceiptScannerService _instance = ReceiptScannerService._internal();
  factory ReceiptScannerService() => _instance;
  ReceiptScannerService._internal();

  final GroqAIService _aiService = GroqAIService();
  final TempMemoryService _memoryService = TempMemoryService();
  final ImagePicker _picker = ImagePicker();

  Future<Map<String, dynamic>> scanReceipt(BuildContext context) async {
    try {
      // Pick image from camera or gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image == null) {
        throw Exception('No image selected');
      }

      // Show processing dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFFFFD700),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Analyzing Receipt',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AI is extracting financial data...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Convert image to base64 for AI analysis
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Use AI to analyze the receipt image
      final aiContext = '''
Receipt Image Analysis:
Image: $base64Image

Please analyze this receipt image and extract:
1. Total amount
2. Date of transaction
3. Merchant/store name
4. Category (food, transport, utilities, entertainment, etc.)
5. Individual items and their prices
6. Payment method
7. Any discounts or taxes

Provide the data in a structured format that can be parsed.
''';

      // Get AI analysis of the receipt
      final aiAnalysis = await _aiService.analyzeReceipt({
        'image': base64Image,
        'fileName': image.name,
        'aiContext': aiContext,
      });

      // Parse the AI response
      final extractedData = _parseReceiptData(aiAnalysis);
      
      // Store the receipt data
      _memoryService.addTransaction(
        extractedData['category'] ?? 'other',
        extractedData['amount'] ?? 0,
        false,
      );

      // Update monthly data
      final currentMonth = _getCurrentMonth();
      final monthlyData = _memoryService.getMonthlyData(currentMonth);
      final categories = Map<String, dynamic>.from(monthlyData['categories'] ?? {});
      
      final category = extractedData['category'] ?? 'other';
      categories[category] = (categories[category] ?? 0) + (extractedData['amount'] ?? 0);
      
      _memoryService.addMonthlyData(currentMonth, {
        ...monthlyData,
        'expenses': (monthlyData['expenses'] ?? 0) + (extractedData['amount'] ?? 0),
        'categories': categories,
      });

      // Close the dialog
      Navigator.of(context).pop();

      return extractedData;

    } catch (e) {
      // Close the dialog if it's open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      throw Exception('Failed to scan receipt: $e');
    }
  }

  Map<String, dynamic> _parseReceiptData(String aiResponse) {
    // Parse AI response to extract structured data
    final data = <String, dynamic>{};
    
    // Extract amount
    final amountMatch = RegExp(r'amount[:\s]*₦?([\d,]+)', caseSensitive: false).firstMatch(aiResponse);
    if (amountMatch != null) {
      data['amount'] = _parseAmount(amountMatch.group(1)!);
    }
    
    // Extract category
    final categoryMatch = RegExp(r'category[:\s]*([a-zA-Z\s]+)', caseSensitive: false).firstMatch(aiResponse);
    if (categoryMatch != null) {
      data['category'] = categoryMatch.group(1)!.trim().toLowerCase();
    }
    
    // Extract date
    final dateMatch = RegExp(r'date[:\s]*([\d\/\-]+)', caseSensitive: false).firstMatch(aiResponse);
    if (dateMatch != null) {
      data['date'] = dateMatch.group(1)!.trim();
    }
    
    // Extract merchant
    final merchantMatch = RegExp(r'merchant[:\s]*([a-zA-Z\s]+)', caseSensitive: false).firstMatch(aiResponse);
    if (merchantMatch != null) {
      data['merchant'] = merchantMatch.group(1)!.trim();
    }
    
    return data;
  }

  num _parseAmount(String amountStr) {
    final cleanStr = amountStr.replaceAll(',', '');
    try {
      return double.parse(cleanStr);
    } catch (e) {
      return 0;
    }
  }

  String _getCurrentMonth() {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[DateTime.now().month - 1];
  }
}
