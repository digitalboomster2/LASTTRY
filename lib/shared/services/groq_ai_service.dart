import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqAIService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  static final GroqAIService _instance = GroqAIService._internal();
  factory GroqAIService() => _instance;
  GroqAIService._internal();



  Future<String> getFinancialInsights(Map<String, dynamic> financialData) async {
    try {
      final prompt = _buildFinancialAnalysisPrompt(financialData);
      final response = await _makeGroqRequest(prompt);
      return response;
    } catch (e) {
      return 'I encountered an error analyzing your financial data. Please try again.';
    }
  }

  Future<String> getHealMeResponse(String userMessage) async {
    try {
      final prompt = 'You are a compassionate financial wellness coach. The user says: "$userMessage". Provide empathetic, supportive financial advice and encouragement.';
      final response = await _makeGroqRequest(prompt);
      return response;
    } catch (e) {
      return 'I\'m here to help with your financial wellness. How can I support you today?';
    }
  }

  Future<String> analyzeTransactions(List<Map<String, dynamic>> transactions) async {
    try {
      final prompt = _buildTransactionAnalysisPrompt(transactions);
      final response = await _makeGroqRequest(prompt);
      return response;
    } catch (e) {
      return 'I couldn\'t analyze your transactions at the moment. Please try again.';
    }
  }

  Future<String> generateGoalRecommendations(Map<String, dynamic> financialData) async {
    try {
      final prompt = _buildGoalRecommendationPrompt(financialData);
      final response = await _makeGroqRequest(prompt);
      return response;
    } catch (e) {
      return 'I\'m having trouble generating goal recommendations right now.';
    }
  }

  Future<String> getDailyCoaching(String coachPersona, Map<String, dynamic> userData) async {
    try {
      final prompt = _buildDailyCoachingPrompt(coachPersona, userData);
      final response = await _makeGroqRequest(prompt);
      return response;
    } catch (e) {
      return 'Here\'s your daily financial tip: Small, consistent actions lead to big financial changes over time.';
    }
  }

  Future<String> chatWithAI(String userMessage, String context) async {
    try {
      final prompt = _buildChatPrompt(userMessage, context);
      final response = await _makeGroqRequest(prompt);
      return response;
    } catch (e) {
      return 'I\'m having trouble responding right now. Please try again.';
    }
  }

  Future<String> _makeGroqRequest(String prompt) async {
    try {
      const String apiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
      if (apiKey.isEmpty) {
        throw Exception('Missing GROQ_API_KEY. Provide via --dart-define=GROQ_API_KEY=YOUR_KEY');
      }
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama3-8b-8192',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful AI assistant specializing in financial coaching and analysis. Provide clear, actionable advice based on the user\'s financial data and questions.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'No response generated';
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  String _buildFinancialAnalysisPrompt(Map<String, dynamic> financialData) {
    final income = financialData['income'] ?? 0;
    final expenses = financialData['expenses'] ?? 0;
    final savings = financialData['savings'] ?? 0;
    final categories = financialData['categories'] ?? {};
    final debts = financialData['debts'] ?? [];
    
    return '''
Analyze this financial data and provide actionable insights:

Income: ₦${income}K
Expenses: ₦${expenses}K
Savings: ₦${savings}K
Spending Categories: ${categories.toString()}
Debts: ${debts.toString()}

Provide:
1. Key insights about spending patterns
2. Specific recommendations for improvement
3. Savings opportunities
4. Debt management advice
5. Upcoming financial considerations
''';
  }

  String _buildTransactionAnalysisPrompt(List<Map<String, dynamic>> transactions) {
    return '''
Analyze these transactions and provide insights:

${transactions.map((t) => '${t['date']}: ${t['amount']} - ${t['category']}').join('\n')}

Identify:
1. Spending patterns
2. Unusual transactions
3. Budget optimization opportunities
4. Potential savings
''';
  }

  String _buildGoalRecommendationPrompt(Map<String, dynamic> financialData) {
    return '''
Based on this financial profile, recommend SMART financial goals:

Income: ₦${financialData['income'] ?? 0}K
Current Savings: ₦${financialData['savings'] ?? 0}K
Expenses: ₦${financialData['expenses'] ?? 0}K

Provide 3-5 specific, achievable financial goals with timelines and action steps.
''';
  }

  String _buildDailyCoachingPrompt(String coachPersona, Map<String, dynamic> userData) {
    return '''
You are a ${coachPersona} financial coach. Provide today's personalized financial coaching tip based on:

User Data: ${userData.toString()}

Give one actionable tip that fits their current financial situation.
''';
  }

  String _buildChatPrompt(String userMessage, String context) {
    return '''
Context: $context

User Message: $userMessage

Respond naturally as a helpful AI assistant. If this is about finances, provide helpful advice. If it's about anything else, be conversational and helpful.
''';
  }

  Future<String> getSmartSpendingInsights(Map<String, dynamic> financialData) async {
    try {
      final prompt = '''
Analyze this financial data and provide specific, actionable insights:

Income: ₦${financialData['income'] ?? 0}K
Expenses: ₦${financialData['expenses'] ?? 0}K
Savings: ₦${financialData['savings'] ?? 0}K
Categories: ${financialData['categories'] ?? {}}

Provide:
1. Specific spending insights (e.g., "You spent ₦${(financialData['categories']?['food'] ?? 0) / 1000}K on food this month")
2. Budget tweak suggestions
3. Savings opportunities
4. Recurring charge warnings
5. Future month predictions
6. Actionable next steps

Make it conversational and specific to their data. Use the exact amounts from their categories.
''';

      final response = await _makeGroqRequest(prompt);
      return response;
    } catch (e) {
      return 'I\'m having trouble analyzing your spending patterns right now.';
    }
  }

  Future<String> getFinancialQuestions() async {
    try {
      final prompt = '''
You are a helpful financial coach. Ask the user 3-4 key financial questions to understand their situation better:

1. Ask about their estimated monthly income
2. Ask about their main financial goals
3. Ask about their biggest financial challenge
4. Ask about their current savings habits

Make it conversational and encouraging. Don't overwhelm them - just a few friendly questions to get started.
''';

      final response = await _makeGroqRequest(prompt);
      return response;
    } catch (e) {
      return 'Hi! I\'m here to help with your finances. To get started, could you tell me your estimated monthly income? What are your main financial goals?';
    }
  }

  Future<String> analyzeReceipt(Map<String, dynamic> receiptData) async {
    try {
      final prompt = '''
You are an AI financial analyst. Analyze this receipt data and extract financial information:

Receipt Data: ${receiptData.toString()}

Please provide a structured analysis including:
1. Total amount
2. Category classification
3. Date of transaction
4. Merchant/store name
5. Key insights about the spending

Format your response clearly so it can be parsed by the app.
''';

      final response = await _makeGroqRequest(prompt);
      return response;
    } catch (e) {
      return 'Unable to analyze receipt at this time.';
    }
  }
}