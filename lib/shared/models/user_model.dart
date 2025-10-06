class UserModel {
  final String id;
  final String name;
  final String username;
  final String aiCoach;
  final Map<String, dynamic> preferences;
  final FinancialProfile financialProfile;
  final EmotionalState emotionalState;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.aiCoach,
    required this.preferences,
    required this.financialProfile,
    required this.emotionalState,
    required this.createdAt,
    required this.lastActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      aiCoach: json['aiCoach'],
      preferences: json['preferences'] ?? {},
      financialProfile: FinancialProfile.fromJson(json['financialProfile'] ?? {}),
      emotionalState: EmotionalState.fromJson(json['emotionalState'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      lastActive: DateTime.parse(json['lastActive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'aiCoach': aiCoach,
      'preferences': preferences,
      'financialProfile': financialProfile.toJson(),
      'emotionalState': emotionalState.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? aiCoach,
    Map<String, dynamic>? preferences,
    FinancialProfile? financialProfile,
    EmotionalState? emotionalState,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      aiCoach: aiCoach ?? this.aiCoach,
      preferences: preferences ?? this.preferences,
      financialProfile: financialProfile ?? this.financialProfile,
      emotionalState: emotionalState ?? this.emotionalState,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}

class FinancialProfile {
  final double monthlyIncome;
  final double monthlyExpenses;
  final double totalSavings;
  final double totalDebt;
  final List<Goal> goals;
  final List<Transaction> recentTransactions;
  final Map<String, double> categorySpending;
  final double financialHealthScore;

  FinancialProfile({
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.totalSavings,
    required this.totalDebt,
    required this.goals,
    required this.recentTransactions,
    required this.categorySpending,
    required this.financialHealthScore,
  });

  factory FinancialProfile.fromJson(Map<String, dynamic> json) {
    return FinancialProfile(
      monthlyIncome: (json['monthlyIncome'] ?? 0.0).toDouble(),
      monthlyExpenses: (json['monthlyExpenses'] ?? 0.0).toDouble(),
      totalSavings: (json['totalSavings'] ?? 0.0).toDouble(),
      totalDebt: (json['totalDebt'] ?? 0.0).toDouble(),
      goals: (json['goals'] as List<dynamic>?)
              ?.map((g) => Goal.fromJson(g))
              .toList() ??
          [],
      recentTransactions: (json['recentTransactions'] as List<dynamic>?)
              ?.map((t) => Transaction.fromJson(t))
              .toList() ??
          [],
      categorySpending: Map<String, double>.from(json['categorySpending'] ?? {}),
      financialHealthScore: (json['financialHealthScore'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthlyIncome': monthlyIncome,
      'monthlyExpenses': monthlyExpenses,
      'totalSavings': totalSavings,
      'totalDebt': totalDebt,
      'goals': goals.map((g) => g.toJson()).toList(),
      'recentTransactions': recentTransactions.map((t) => t.toJson()).toList(),
      'categorySpending': categorySpending,
      'financialHealthScore': financialHealthScore,
    };
  }
}

class EmotionalState {
  final String currentMood;
  final double stressLevel; // 0-10
  final double motivationLevel; // 0-10
  final List<JournalEntry> recentEntries;
  final Map<String, int> moodTrends;

  EmotionalState({
    required this.currentMood,
    required this.stressLevel,
    required this.motivationLevel,
    required this.recentEntries,
    required this.moodTrends,
  });

  factory EmotionalState.fromJson(Map<String, dynamic> json) {
    return EmotionalState(
      currentMood: json['currentMood'] ?? 'neutral',
      stressLevel: (json['stressLevel'] ?? 5.0).toDouble(),
      motivationLevel: (json['motivationLevel'] ?? 5.0).toDouble(),
      recentEntries: (json['recentEntries'] as List<dynamic>?)
              ?.map((e) => JournalEntry.fromJson(e))
              .toList() ??
          [],
      moodTrends: Map<String, int>.from(json['moodTrends'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentMood': currentMood,
      'stressLevel': stressLevel,
      'motivationLevel': motivationLevel,
      'recentEntries': recentEntries.map((e) => e.toJson()).toList(),
      'moodTrends': moodTrends,
    };
  }
}

class Goal {
  final String id;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final String category;
  final DateTime targetDate;
  final String status; // 'active', 'completed', 'paused'
  final List<Milestone> milestones;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.category,
    required this.targetDate,
    required this.status,
    required this.milestones,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetAmount: (json['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0.0).toDouble(),
      category: json['category'],
      targetDate: DateTime.parse(json['targetDate']),
      status: json['status'],
      milestones: (json['milestones'] as List<dynamic>?)
              ?.map((m) => Milestone.fromJson(m))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'category': category,
      'targetDate': targetDate.toIso8601String(),
      'status': status,
      'milestones': milestones.map((m) => m.toJson()).toList(),
    };
  }

  double get progressPercentage => (currentAmount / targetAmount) * 100;
}

class Milestone {
  final String id;
  final String title;
  final double targetAmount;
  final bool isCompleted;

  Milestone({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.isCompleted,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'],
      title: json['title'],
      targetAmount: (json['targetAmount'] ?? 0.0).toDouble(),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'isCompleted': isCompleted,
    };
  }
}

class Transaction {
  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final String type; // 'income', 'expense'
  final String? receiptUrl;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.receiptUrl,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      description: json['description'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      category: json['category'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      receiptUrl: json['receiptUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'type': type,
      'receiptUrl': receiptUrl,
    };
  }
}

class JournalEntry {
  final String id;
  final String content;
  final String mood;
  final List<String> tags;
  final DateTime createdAt;
  final Map<String, dynamic>? financialContext;

  JournalEntry({
    required this.id,
    required this.content,
    required this.mood,
    required this.tags,
    required this.createdAt,
    this.financialContext,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      content: json['content'],
      mood: json['mood'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      financialContext: json['financialContext'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'mood': mood,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'financialContext': financialContext,
    };
  }
}
