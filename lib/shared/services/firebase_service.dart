import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Authentication
  User? get currentUser => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // User Profile Management
  Future<void> createUserProfile(UserModel user) async {
    if (currentUser != null) {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .set(user.toJson());
    }
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    await _firestore.collection('users').doc(userId).update(updates);
  }

  // Financial Data Management
  Future<void> addTransaction(String userId, Transaction transaction) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .add(transaction.toJson());
    
    // Update user's financial profile
    await _updateFinancialProfile(userId);
  }

  Future<List<Transaction>> getUserTransactions(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => Transaction.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  Future<void> addGoal(String userId, Goal goal) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .add(goal.toJson());
    
    // Update user's financial profile
    await _updateFinancialProfile(userId);
  }

  Future<List<Goal>> getUserGoals(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .where('status', isEqualTo: 'active')
          .get();

      return querySnapshot.docs
          .map((doc) => Goal.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting goals: $e');
      return [];
    }
  }

  Future<void> updateGoal(String userId, String goalId, Map<String, dynamic> updates) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goalId)
        .update(updates);
    
    // Update user's financial profile
    await _updateFinancialProfile(userId);
  }

  // Journal Management
  Future<void> addJournalEntry(String userId, JournalEntry entry) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('journal')
        .add(entry.toJson());
    
    // Update user's emotional state
    await _updateEmotionalState(userId);
  }

  Future<List<JournalEntry>> getUserJournalEntries(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('journal')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return querySnapshot.docs
          .map((doc) => JournalEntry.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting journal entries: $e');
      return [];
    }
  }

  // Document Management
  Future<String> uploadDocument(String userId, String filePath, String fileName) async {
    try {
      final ref = _storage.ref().child('users/$userId/documents/$fileName');
      final uploadTask = ref.putFile(File(filePath));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Save document metadata to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .add({
        'fileName': fileName,
        'fileUrl': downloadUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
        'status': 'pending_processing',
      });
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading document: $e');
      throw Exception('Failed to upload document');
    }
  }

  Future<List<Map<String, dynamic>>> getUserDocuments(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .orderBy('uploadedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error getting documents: $e');
      return [];
    }
  }

  // AI Insights Storage
  Future<void> saveAIInsight(String userId, String insight, String type) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('insights')
        .add({
      'insight': insight,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Future<List<Map<String, dynamic>>> getUserInsights(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('insights')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error getting insights: $e');
      return [];
    }
  }

  // Helper Methods
  Future<void> _updateFinancialProfile(String userId) async {
    try {
      // Get all transactions and goals
      final transactions = await getUserTransactions(userId);
      final goals = await getUserGoals(userId);
      
      // Calculate financial metrics
      final monthlyIncome = _calculateMonthlyIncome(transactions);
      final monthlyExpenses = _calculateMonthlyExpenses(transactions);
      final totalSavings = _calculateTotalSavings(transactions, goals);
      final totalDebt = _calculateTotalDebt(transactions);
      final categorySpending = _calculateCategorySpending(transactions);
      final financialHealthScore = _calculateFinancialHealthScore(
        monthlyIncome, monthlyExpenses, totalSavings, totalDebt
      );
      
      // Update user profile
      await updateUserProfile(userId, {
        'financialProfile': {
          'monthlyIncome': monthlyIncome,
          'monthlyExpenses': monthlyExpenses,
          'totalSavings': totalSavings,
          'totalDebt': totalDebt,
          'categorySpending': categorySpending,
          'financialHealthScore': financialHealthScore,
        }
      });
    } catch (e) {
      print('Error updating financial profile: $e');
    }
  }

  Future<void> _updateEmotionalState(String userId) async {
    try {
      final journalEntries = await getUserJournalEntries(userId);
      
      if (journalEntries.isNotEmpty) {
        final latestEntry = journalEntries.first;
        final moodTrends = _calculateMoodTrends(journalEntries);
        
        await updateUserProfile(userId, {
          'emotionalState': {
            'currentMood': latestEntry.mood,
            'stressLevel': _estimateStressLevel(latestEntry),
            'motivationLevel': _estimateMotivationLevel(latestEntry),
            'moodTrends': moodTrends,
          }
        });
      }
    } catch (e) {
      print('Error updating emotional state: $e');
    }
  }

  // Financial Calculations
  double _calculateMonthlyIncome(List<Transaction> transactions) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    
    return transactions
        .where((t) => t.type == 'income' && t.date.isAfter(thisMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateMonthlyExpenses(List<Transaction> transactions) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    
    return transactions
        .where((t) => t.type == 'expense' && t.date.isAfter(thisMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateTotalSavings(List<Transaction> transactions, List<Goal> goals) {
    final savingsTransactions = transactions
        .where((t) => t.category == 'savings' || t.category == 'investment')
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final goalSavings = goals.fold(0.0, (sum, g) => sum + g.currentAmount);
    
    return savingsTransactions + goalSavings;
  }

  double _calculateTotalDebt(List<Transaction> transactions) {
    return transactions
        .where((t) => t.category == 'debt' || t.category == 'loan')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> _calculateCategorySpending(List<Transaction> transactions) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    
    final monthlyExpenses = transactions
        .where((t) => t.type == 'expense' && t.date.isAfter(thisMonth));
    
    final categoryMap = <String, double>{};
    
    for (final transaction in monthlyExpenses) {
      categoryMap[transaction.category] = 
          (categoryMap[transaction.category] ?? 0.0) + transaction.amount;
    }
    
    return categoryMap;
  }

  double _calculateFinancialHealthScore(
    double income, double expenses, double savings, double debt
  ) {
    if (income == 0) return 0.0;
    
    final expenseRatio = expenses / income;
    final savingsRatio = savings / income;
    final debtRatio = debt / income;
    
    double score = 100.0;
    
    // Expense ratio penalty (ideal: <70%)
    if (expenseRatio > 0.9) score -= 30;
    else if (expenseRatio > 0.8) score -= 20;
    else if (expenseRatio > 0.7) score -= 10;
    
    // Savings ratio bonus (ideal: >20%)
    if (savingsRatio > 0.3) score += 20;
    else if (savingsRatio > 0.2) score += 15;
    else if (savingsRatio > 0.1) score += 10;
    
    // Debt ratio penalty (ideal: <30%)
    if (debtRatio > 0.5) score -= 25;
    else if (debtRatio > 0.3) score -= 15;
    
    return score.clamp(0.0, 100.0);
  }

  // Emotional State Calculations
  Map<String, int> _calculateMoodTrends(List<JournalEntry> entries) {
    final moodCounts = <String, int>{};
    
    for (final entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }
    
    return moodCounts;
  }

  double _estimateStressLevel(JournalEntry entry) {
    // Simple heuristic based on mood and content
    final stressKeywords = ['stress', 'worried', 'anxious', 'overwhelmed', 'tired'];
    final content = entry.content.toLowerCase();
    
    int stressScore = 0;
    for (final keyword in stressKeywords) {
      if (content.contains(keyword)) stressScore++;
    }
    
    // Base stress level from mood
    double baseStress = 5.0;
    switch (entry.mood) {
      case 'stressed':
        baseStress = 8.0;
        break;
      case 'worried':
        baseStress = 7.0;
        break;
      case 'tired':
        baseStress = 6.0;
        break;
      case 'happy':
        baseStress = 3.0;
        break;
      case 'excited':
        baseStress = 2.0;
        break;
    }
    
    return (baseStress + stressScore).clamp(1.0, 10.0);
  }

  double _estimateMotivationLevel(JournalEntry entry) {
    // Simple heuristic based on mood and content
    final motivationKeywords = ['motivated', 'excited', 'goal', 'plan', 'achieve', 'progress'];
    final content = entry.content.toLowerCase();
    
    int motivationScore = 0;
    for (final keyword in motivationKeywords) {
      if (content.contains(keyword)) motivationScore++;
    }
    
    // Base motivation level from mood
    double baseMotivation = 5.0;
    switch (entry.mood) {
      case 'excited':
        baseMotivation = 9.0;
        break;
      case 'happy':
        baseMotivation = 8.0;
        break;
      case 'motivated':
        baseMotivation = 9.0;
        break;
      case 'tired':
        baseMotivation = 4.0;
        break;
      case 'stressed':
        baseMotivation = 3.0;
        break;
    }
    
    return (baseMotivation + motivationScore).clamp(1.0, 10.0);
  }
}
