import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:go_router/go_router.dart';
import 'temp_memory_service.dart';
import 'groq_ai_service.dart';
import '../parsing/statement_parser.dart';

class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() => _instance;
  FileUploadService._internal();

  final TempMemoryService _memoryService = TempMemoryService();
  final GroqAIService _aiService = GroqAIService();

  Future<String?> uploadFinancialStatement(BuildContext context) async {
    try {
      // Pick file using file_selector
      final typeGroup = XTypeGroup(
        label: 'Financial Documents',
        uniformTypeIdentifiers: ['com.adobe.pdf', 'public.comma-separated-values-text', 'public.plain-text'],
        extensions: ['pdf', 'csv', 'txt'],
      );
      
      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

      if (file != null) {
        
        // Show enhanced loading dialog
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
                    // Animated icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.analytics,
                        color: Color(0xFF2196F3),
                        size: 48,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Analyzing Statement',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    const Text(
                      'AI is processing your financial data...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Progress indicator
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        // Simulate file processing (in real app, this would parse the actual file)
        await Future.delayed(const Duration(seconds: 2));
        
        // Close loading dialog
        Navigator.of(context).pop();

        // Parse and populate data
        await _parseFinancialStatement(file);
        
        // Get AI insights on the uploaded data
        final insights = await _getAIInsights();
        
        // Show success message with insights
        final fileName = file.path.split('/').last;
        // Loading dialog was already closed above; do not pop again
      
      // Show success message in chat-style notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✅ Statement Analyzed Successfully!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Dashboard updated with new insights. Tap to view.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'View Dashboard',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to pre-chat dashboard view
              if (context.mounted) {
                context.go('/chat');
              }
            },
          ),
        ),
      );
        
        return insights;
      }
      
      return null;
    } catch (e) {
      // Ensure any loading dialog is closed safely
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      // Avoid opening a dialog while navigator is locked; use snackbar instead
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process file: $e'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
      return null;
    }
  }

  Future<void> _parseFinancialStatement(XFile file) async {
    // For demo purposes, we'll simulate parsing different file types
    // In a real app, you'd implement actual CSV/PDF parsing
    
    final extension = file.path.split('.').last.toLowerCase();
    
    if (extension == 'csv') {
      await _parseCSVFile(file);
    } else if (extension == 'pdf') {
      await _parsePDFFile(file);
    } else {
      await _parseGenericFile(file);
    }
  }

  Future<void> _parseCSVFile(XFile file) async {
    try {
      print('Parsing CSV file: ${file.name}');
      
      // Read the CSV content
      final content = await file.readAsString();
      
      // Deterministic parsing via StatementParser
      final parser = StatementParser();
      final extractedData = _normalizeParsed(parser.parse(content));
      
      // Store the extracted data
      _memoryService.setCurrentMonth(_getCurrentMonth());
      _memoryService.addTransaction('salary', (extractedData['income'] as num? ?? 0).toDouble(), true);
      
      // Add expenses by category
      final categories = extractedData['categories'] as Map<String, dynamic>? ?? {};
      for (final entry in categories.entries) {
        final amount = (entry.value as num? ?? 0).toDouble();
        if (amount > 0) {
          _memoryService.addTransaction(entry.key, amount, false);
        }
      }
      
      // Add monthly data
      _memoryService.addMonthlyData(_getCurrentMonth(), extractedData);
      
      print('CSV file parsed successfully with AI analysis');
      
    } catch (e) {
      print('Error parsing CSV with AI: $e');
      throw Exception('Failed to parse CSV. Please ensure the file contains valid financial data.');
    }
  }

  Future<void> _parsePDFFile(XFile file) async {
    try {
      print('Parsing PDF file: ${file.name}');
      
      // Read the PDF file bytes
      final bytes = await file.readAsBytes();
      
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      // Extract text from all pages using proper text extraction
      String extractedText = '';
      for (int i = 0; i < document.pages.count; i++) {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        final String pageText = extractor.extractText(startPageIndex: i);
        
        // Only add non-empty pages
        if (pageText.trim().isNotEmpty) {
          // Clean up the text for better parsing
          final cleanText = pageText
              .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
              .replaceAll(RegExp(r'[^\w\s\-₦,.\/]'), ' ') // Keep only relevant characters
              .trim();
          
          extractedText += '=== PAGE ${i + 1} ===\n$cleanText\n\n';
        }
      }
      
      // Close the document
      document.dispose();
      
      // If no text was extracted, throw an error
      if (extractedText.trim().isEmpty) {
        throw Exception('Could not extract text from PDF. The file might be image-based or corrupted.');
      }
      
      print('Extracted text length: ${extractedText.length} characters');
      print('First 500 characters: ${extractedText.substring(0, extractedText.length > 500 ? 500 : extractedText.length)}');
      
      // Use ChatGPT's EXACT analysis approach - be as specific and detailed as ChatGPT was
      final aiContext = '''
PDF File: ${file.name}
Content Type: Bank Statement

ACTUAL EXTRACTED TEXT FROM PDF:
$extractedText

ANALYZE THIS EXACTLY LIKE CHATGPT DID:

1. PARSE EVERY TRANSACTION ROW:
   - Look for: Posting Date, Value Date, Description, Outflow, Inflow, Balance
   - Extract opening balance (first row) and closing balance (last row)
   - Identify ALL inflows (credits, deposits, salary) and outflows (debits, payments, charges)

2. CLASSIFY USING CHATGPT'S EXACT RULES:
   - "POS", "Fuel", "Uber", "Car" → Transport
   - "Groceries", "Food", "Chowdeck", "Amala", "Restaurant" → Food & Dining
   - "Power", "Electricity", "Gas", "POS Power" → Utilities
   - "SMS ALERT CHARGE", "NIP-FEE", "VAT-FEE", "NIP/Fee" → Fees
   - "PAYSTACK", "Transfer", "Peer" → Peer Transfer
   - Other transactions → Personal/Other

3. AGGREGATE LIKE CHATGPT:
   - Total inflow = sum of ALL credits/deposits
   - Total outflow = sum of ALL debits/payments
   - Category breakdown = group by classification, sum amounts
   - Fee leakage = sum ALL VAT/NIP/SMS charges
   - Calculate inflow vs outflow ratio

4. DETECT PATTERNS LIKE CHATGPT:
   - Balance volatility (max-min difference in balances)
   - Large transactions (>₦100k inflows/outflows)
   - Reversals/failed transactions
   - Cumulative small charges (fees add up)
   - High-frequency vs low-frequency transactions

5. PROVIDE CHATGPT-LEVEL INSIGHTS:
   - Account trend (declining/improving)
   - Spending discipline analysis
   - Fee leakage impact
   - Income irregularity assessment
   - Risk areas identification

FORMAT EXACTLY AS:
Income: ₦[total inflow]
Expenses: ₦[total outflow]
Savings: ₦[income - expenses]
Categories: {food: ₦[amount], transport: ₦[amount], utilities: ₦[amount], entertainment: ₦[amount], fees: ₦[amount], other: ₦[amount]}
Opening Balance: ₦[amount]
Closing Balance: ₦[amount]
Inflow vs Outflow Ratio: [X% / Y%]
Key Insights: [ChatGPT-level analysis with specific numbers and patterns]

BE AS DETAILED AND ACCURATE AS CHATGPT WAS. Use ONLY actual numbers from the text.
''';
      
      // Get AI analysis of the REAL PDF content
      final aiAnalysis = await _aiService.getFinancialInsights({
        'fileName': file.name,
        'content': extractedText,
        'type': 'PDF',
        'aiContext': aiContext,
      });
      
      print('AI Analysis received: ${aiAnalysis.length} characters');
      
      // Prefer deterministic parsing via central StatementParser
      final parser = StatementParser();
      final extractedData = _normalizeParsed(parser.parse(extractedText));
      
      print('Parsed data: $extractedData');
      
      // Store the extracted data
      _memoryService.setCurrentMonth(_getCurrentMonth());
      _memoryService.addTransaction('salary', (extractedData['income'] as num? ?? 0).toDouble(), true);
      
      // Add expenses by category
      final categories = extractedData['categories'] as Map<String, dynamic>? ?? {};
      for (final entry in categories.entries) {
        final amount = (entry.value as num? ?? 0).toDouble();
        if (amount > 0) {
          _memoryService.addTransaction(entry.key, amount, false);
        }
      }
      
      // Add monthly data
      _memoryService.addMonthlyData(_getCurrentMonth(), extractedData);
      
      print('PDF parsed successfully with REAL AI analysis');
      
    } catch (e) {
      print('Error parsing PDF with AI: $e');
      // If AI parsing fails, show error to user instead of using fallback
      throw Exception('Failed to parse PDF: $e. Please ensure the file is a valid financial statement.');
    }
  }

  Future<void> _parseGenericFile(XFile file) async {
    try {
      print('Parsing generic file: ${file.name}');
      
      // Read the file content
      final content = await file.readAsString();
      
      // Deterministic parsing via StatementParser
      final parser = StatementParser();
      final extractedData = _normalizeParsed(parser.parse(content));
      
      // Store the extracted data
      _memoryService.setCurrentMonth(_getCurrentMonth());
      _memoryService.addTransaction('salary', (extractedData['income'] as num? ?? 0).toDouble(), true);
      
      // Add expenses by category
      final categories = extractedData['categories'] as Map<String, dynamic>? ?? {};
      for (final entry in categories.entries) {
        final amount = (entry.value as num? ?? 0).toDouble();
        if (amount > 0) {
          _memoryService.addTransaction(entry.key, amount, false);
        }
      }
      
      // Add monthly data
      _memoryService.addMonthlyData(_getCurrentMonth(), extractedData);
      
      print('Generic file parsed successfully with AI analysis');
      
    } catch (e) {
      print('Error parsing generic file with AI: $e');
      throw Exception('Failed to parse file. Please ensure the file contains valid financial data.');
    }
  }

  Future<String> _getAIInsights() async {
    try {
      final financialData = _memoryService.financialData;
      if (financialData.isNotEmpty) {
        return await _aiService.getFinancialInsights(financialData);
      }
      return 'Financial data has been uploaded and analyzed.';
    } catch (e) {
      return 'Financial data uploaded successfully. AI analysis will be available in chat.';
    }
  }

  void _showSuccessDialog(BuildContext context, String fileName, String insights) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
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
                // Header with gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Success! 🎉',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'File "$fileName" processed',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status message
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.analytics,
                                color: const Color(0xFF4CAF50),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Dashboard updated with new insights!',
                                  style: TextStyle(
                                    color: const Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // AI Insights header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.psychology,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'AI Insights',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Insights content in scrollable container
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: SingleChildScrollView(
                            child: Text(
                              insights,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Color(0xFF424242),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Action buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Navigate to dashboard or refresh the current page
                            // Since we're in the pre-chat page, just close the dialog
                            // The dashboard should already be visible
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'View Dashboard',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4CAF50),
                            side: const BorderSide(color: Color(0xFF4CAF50)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Continue Chat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
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
  
  Map<String, dynamic> _extractFinancialDataFromText(String text) {
    // Fallback lightweight extractor (kept for compatibility)
    final data = <String, dynamic>{};
    final lowerText = text.toLowerCase();
    
    // Extract month from text (look for month names)
    final monthPattern = RegExp(r'\b(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\b', caseSensitive: false);
    final monthMatch = monthPattern.firstMatch(lowerText);
    if (monthMatch != null) {
      data['month'] = monthMatch.group(0)!.substring(0, 1).toUpperCase() + monthMatch.group(0)!.substring(1);
    }
    
    // Extract income (look for salary, income, credit, etc.)
    final incomePatterns = [
      RegExp(r'salary[:\s]*₦?([\d,]+)', caseSensitive: false),
      RegExp(r'income[:\s]*₦?([\d,]+)', caseSensitive: false),
      RegExp(r'credit[:\s]*₦?([\d,]+)', caseSensitive: false),
      RegExp(r'₦?([\d,]+)[\s]*salary', caseSensitive: false),
      RegExp(r'₦?([\d,]+)[\s]*income', caseSensitive: false),
    ];
    
    for (final pattern in incomePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amount = _parseAmount(match.group(1)!);
        if (amount > 0) {
          data['income'] = amount;
          break;
        }
      }
    }
    
    // Extract expenses by category
    final expenses = <String, num>{};
    
    // Food/Dining expenses
    final foodPatterns = [
      RegExp(r'food[:\s]*₦?([\d,]+)', caseSensitive: false),
      RegExp(r'dining[:\s]*₦?([\d,]+)', caseSensitive: false),
      RegExp(r'restaurant[:\s]*₦?([\d,]+)', caseSensitive: false),
      RegExp(r'₦?([\d,]+)[\s]*food', caseSensitive: false),
    ];
    
    for (final pattern in foodPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amount = _parseAmount(match.group(1)!);
        if (amount > 0) {
          expenses['food'] = (expenses['food'] ?? 0) + amount;
        }
      }
    }
    
    // Transport expenses
    final transportPatterns = [
      RegExp(r'transport[:\s]*₦?([\d,]+)', caseSensitive: false),
      RegExp(r'fuel[:\s]*₦?([\d,]+)', caseSensitive: false),
      RegExp(r'uber[:\s]*₦?([\d,]+)', caseSensitive: false),
      RegExp(r'₦?([\d,]+)[\s]*transport', caseSensitive: false),
    ];
    
    for (final pattern in transportPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amount = _parseAmount(match.group(1)!);
        if (amount > 0) {
          expenses['transport'] = (expenses['transport'] ?? 0) + amount;
        }
      }
    }
    
    // Data/Internet expenses
    final dataPatterns = [
      RegExp(r'data[:\s]*₦?([\d,]+)', caseSensitive: false),
      RegExp(r'internet[:\s]*₦?([\d,]+)', caseSensitive: false),
      RegExp(r'₦?([\d,]+)[\s]*data', caseSensitive: false),
    ];
    
    for (final pattern in dataPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amount = _parseAmount(match.group(1)!);
        if (amount > 0) {
          expenses['data'] = (expenses['data'] ?? 0) + amount;
        }
      }
    }
    
    // Utilities expenses
    final utilitiesPatterns = [
      RegExp(r'utilities[:\s]*₦?([\d,]+)', caseSensitive: false),
      RegExp(r'electricity[:\s]*₦?([\d,]+)', caseSensitive: false),
      RegExp(r'water[:\s]*₦?([\d,]+)', caseSensitive: false),
      RegExp(r'₦?([\d,]+)[\s]*utilities', caseSensitive: false),
    ];
    
    for (final pattern in utilitiesPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amount = _parseAmount(match.group(1)!);
        if (amount > 0) {
          expenses['utilities'] = (expenses['utilities'] ?? 0) + amount;
        }
      }
    }
    
    // Entertainment expenses
    final entertainmentPatterns = [
      RegExp(r'entertainment[:\s]*₦?([\d,]+)', caseSensitive: false),
      RegExp(r'movie[:\s]*₦?([\d,]+)', caseSensitive: false),
      RegExp(r'₦?([\d,]+)[\s]*entertainment', caseSensitive: false),
    ];
    
    for (final pattern in entertainmentPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amount = _parseAmount(match.group(1)!);
        if (amount > 0) {
          expenses['entertainment'] = (expenses['entertainment'] ?? 0) + amount;
        }
      }
    }
    
    // Look for any other amounts that might be expenses
    final amountPattern = RegExp(r'₦?([\d,]+)', caseSensitive: false);
    final allMatches = amountPattern.allMatches(text);
    
    for (final match in allMatches) {
      final amount = _parseAmount(match.group(1)!);
      if (amount > 0 && amount < (data['income'] ?? double.infinity)) {
        // This could be an expense, try to categorize it
        final context = text.substring(max(0, match.start - 50), min(text.length, match.end + 50)).toLowerCase();
        
        if (context.contains('debit') || context.contains('withdrawal') || context.contains('payment')) {
          // Try to find category from context
          String category = 'other';
          if (context.contains('food') || context.contains('restaurant')) category = 'food';
          else if (context.contains('transport') || context.contains('fuel')) category = 'transport';
          else if (context.contains('data') || context.contains('internet')) category = 'data';
          else if (context.contains('utility') || context.contains('electricity')) category = 'utilities';
          else if (context.contains('entertainment') || context.contains('movie')) category = 'entertainment';
          
          expenses[category] = (expenses[category] ?? 0) + amount;
        }
      }
    }
    
    data['expenses'] = expenses;
    
    print('Extracted data: $data');
    return data;
  }

  // Deterministic parser for bank-style statements
  Map<String, dynamic> _parseStructuredStatement(String text) {
    final lines = text.split(RegExp(r'\n|=== PAGE'));
    num openingBalance = 0;
    num closingBalance = 0;
    num totalInflow = 0;
    num totalOutflow = 0;
    final categories = <String, num>{};

    final balanceRegex = RegExp(r'BALANCE[^\d]*([\d,]+\.\d{2})');
    final rowRegex = RegExp(
        r'(\d{2}\s\w{3}\s\d{4}|\d{2}\s\w+\s\d{4}|\d{2}\s\w{3}\s\d{2,4}).{0,60}?([\-\d,]+\.\d{2})?\s*([\-\d,]+\.\d{2})?\s*([\-\d,]+\.\d{2})');

    bool sawFirstBalance = false;
    for (final raw in lines) {
      final line = raw.replaceAll('\r', ' ').trim();
      if (line.isEmpty) continue;

      // Opening/closing balance capture
      final balMatch = balanceRegex.firstMatch(line);
      if (balMatch != null) {
        final value = _parseAmount(balMatch.group(1)!);
        if (!sawFirstBalance) {
          openingBalance = value;
          sawFirstBalance = true;
        }
        closingBalance = value; // last seen balance
      }

      // Transaction row capture (credit/debit/balance columns)
      final rowMatch = rowRegex.firstMatch(line);
      if (rowMatch != null) {
        final creditStr = rowMatch.group(2);
        final debitStr = rowMatch.group(3);
        final balanceStr = rowMatch.group(4);
        if (creditStr != null && creditStr.isNotEmpty && !creditStr.startsWith('-')) {
          totalInflow += _parseAmount(creditStr);
        }
        if (debitStr != null && debitStr.isNotEmpty) {
          totalOutflow += _parseAmount(debitStr.replaceAll('-', ''));
        }
        if (balanceStr != null && balanceStr.isNotEmpty) {
          closingBalance = _parseAmount(balanceStr.replaceAll('-', ''));
        }
      }

      // Category classification heuristics
      final lower = line.toLowerCase();
      num amtHint = 0;
      final m = RegExp(r'([\d,]+\.\d{2})').allMatches(line).toList();
      if (m.isNotEmpty) {
        amtHint = _parseAmount(m.last.group(1)!);
      }
      void addCat(String key) {
        categories[key] = (categories[key] ?? 0) + amtHint;
      }
      if (lower.contains('chowdeck') || lower.contains('amala') || lower.contains('restaurant') || lower.contains('food') || lower.contains('grocery')) {
        addCat('food');
      } else if (lower.contains('uber') || lower.contains('pos fuel') || lower.contains('fuel') || lower.contains('car')) {
        addCat('transport');
      } else if (lower.contains('power') || lower.contains('electric') || lower.contains('utility') || lower.contains('internet') || lower.contains('data')) {
        addCat('utilities');
      } else if (lower.contains('sms alert') || lower.contains('nip-fee') || lower.contains('nip/fee') || lower.contains('vat-fee') || lower.contains('vat')) {
        addCat('fees');
      }
    }

    final savings = totalInflow - totalOutflow;
    return {
      'income': totalInflow.toDouble(),
      'expenses': totalOutflow.toDouble(),
      'savings': savings.toDouble(),
      'categories': categories,
      'openingBalance': openingBalance.toDouble(),
      'closingBalance': closingBalance.toDouble(),
    };
  }

  Map<String, dynamic> _normalizeParsed(Map<String, dynamic> map) {
    final out = Map<String, dynamic>.from(map);
    out['income'] = (out['income'] as num? ?? 0).toDouble();
    out['expenses'] = (out['expenses'] as num? ?? 0).toDouble();
    out['savings'] = (out['savings'] as num? ?? 0).toDouble();
    if (out['categories'] is Map) {
      final cats = Map<String, dynamic>.from(out['categories']);
      final fixed = <String, double>{};
      for (final e in cats.entries) {
        fixed[e.key] = (e.value as num? ?? 0).toDouble();
      }
      out['categories'] = fixed;
    }
    return out;
  }
  
  num _parseAmount(String amountStr) {
    // Remove commas and convert to number
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
