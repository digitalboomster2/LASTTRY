import 'dart:convert';

class TempMemoryService {
  static final TempMemoryService _instance = TempMemoryService._internal();
  factory TempMemoryService() => _instance;
  TempMemoryService._internal();

  // User data
  String? _userName;
  String? _selectedCoach;
  
  // Financial data
  Map<String, dynamic> _financialData = {
    'income': 0.0,
    'expenses': 0.0,
    'savings': 0.0,
    'savingsRate': 0.0,
    'categories': {
      'food': 0.0,
      'transport': 0.0,
      'data': 0.0,
      'entertainment': 0.0,
      'utilities': 0.0,
      'other': 0.0,
    },
    'debts': [],
    'monthlyData': {},
    'currentMonth': '',
    'goals': [],
  };

  // Getters
  String? get userName => _userName;
  String? get selectedCoach => _selectedCoach;
  Map<String, dynamic> get financialData => _financialData;

  // Setters
  void setUserName(String name) {
    _userName = name;
  }

  void setSelectedCoach(String coach) {
    _selectedCoach = coach;
  }

  // Financial data methods
  void updateFinancialData(Map<String, dynamic> newData) {
    _financialData.addAll(newData);
  }

  void setCurrentMonth(String month) {
    _financialData['currentMonth'] = month;
  }

  void addTransaction(String category, double amount, bool isIncome) {
    if (isIncome) {
      _financialData['income'] += amount;
    } else {
      _financialData['expenses'] += amount;
      _financialData['categories'][category] = (_financialData['categories'][category] ?? 0.0) + amount;
    }
    
    // Update savings
    _financialData['savings'] = _financialData['income'] - _financialData['expenses'];
    
    // Update savings rate
    if (_financialData['income'] > 0) {
      _financialData['savingsRate'] = (_financialData['savings'] / _financialData['income']) * 100;
    }
  }

  void addDebt(String description, double amount, double interestRate, DateTime dueDate) {
    _financialData['debts'].add({
      'description': description,
      'amount': amount,
      'interestRate': interestRate,
      'dueDate': dueDate.toIso8601String(),
    });
  }

  void addGoal(String description, double targetAmount, DateTime targetDate) {
    _financialData['goals'].add({
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': 0.0,
      'targetDate': targetDate.toIso8601String(),
      'progress': 0.0,
    });
  }

  void updateGoalProgress(String description, double amount) {
    for (var goal in _financialData['goals']) {
      if (goal['description'] == description) {
        goal['currentAmount'] += amount;
        goal['progress'] = (goal['currentAmount'] / goal['targetAmount']) * 100;
        break;
      }
    }
  }

  // Monthly data tracking
  void addMonthlyData(String month, Map<String, dynamic> data) {
    _financialData['monthlyData'][month] = data;
  }

  Map<String, dynamic> getMonthlyData(String month) {
    return _financialData['monthlyData'][month] ?? {};
  }

  // Reset data (for testing)
  void resetData() {
    _financialData = {
      'income': 0.0,
      'expenses': 0.0,
      'savings': 0.0,
      'savingsRate': 0.0,
      'categories': {
        'food': 0.0,
        'transport': 0.0,
        'data': 0.0,
        'entertainment': 0.0,
        'utilities': 0.0,
        'other': 0.0,
      },
      'debts': [],
      'monthlyData': {},
      'currentMonth': '',
      'goals': [],
    };
  }

  // Get summary for dashboard
  Map<String, dynamic> getDashboardSummary() {
    return {
      'totalBalance': _financialData['savings'],
      'income': _financialData['income'],
      'expenses': _financialData['expenses'],
      'savingsRate': _financialData['savingsRate'],
      'topCategory': _getTopSpendingCategory(),
      'monthlyTrend': _getMonthlyTrend(),
    };
  }

  String _getTopSpendingCategory() {
    if (_financialData['categories'].isEmpty) return 'No data';
    
    var entries = _financialData['categories'].entries.toList();
    entries.sort((a, b) {
      final aValue = (a.value as num);
      final bValue = (b.value as num);
      return bValue.compareTo(aValue);
    });
    
    return entries.first.key;
  }

  Map<String, dynamic> _getMonthlyTrend() {
    if (_financialData['monthlyData'].isEmpty) {
      return {'trend': 'stable', 'percentage': 0.0};
    }
    
    // Simple trend calculation
    var months = _financialData['monthlyData'].keys.toList();
    months.sort();
    if (months.length < 2) return {'trend': 'stable', 'percentage': 0.0};
    
    var current = months.last;
    var previous = months[months.length - 2];
    
    var currentIncome = _financialData['monthlyData'][current]['income'] ?? 0.0;
    var previousIncome = _financialData['monthlyData'][previous]['income'] ?? 0.0;
    
    if (previousIncome == 0) return {'trend': 'stable', 'percentage': 0.0};
    
    var percentage = ((currentIncome - previousIncome) / previousIncome) * 100;
    
    if (percentage > 5) return {'trend': 'increasing', 'percentage': percentage};
    if (percentage < -5) return {'trend': 'decreasing', 'percentage': percentage};
    return {'trend': 'stable', 'percentage': percentage};
  }
}
