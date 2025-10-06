
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/services/temp_memory_service.dart';
import '../../../../shared/services/groq_ai_service.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';

class PreChatPage extends ConsumerStatefulWidget {
  const PreChatPage({super.key});

  @override
  ConsumerState<PreChatPage> createState() => _PreChatPageState();
}

// UPDATE the service declaration:
class _PreChatPageState extends ConsumerState<PreChatPage> {
  final Set<String> _selectedFeatures = <String>{};
  int _selectedTabIndex = 0;
  final TempMemoryService _memoryService = TempMemoryService();
  String _selectedTimeRange = '1M';

  @override
  void initState() {
    super.initState();
    // Load selected features from onboarding (for demo purposes)
    _selectedFeatures.addAll([
      'Dark mode',
      'Push notifications',
      'Camera access',
      'File uploads',
      'Analytics insights',
    ]);
  }

  Future<void> _requestPermission(String feature) async {
    switch (feature) {
      case 'Camera access':
        _showPermissionResult('Camera access ready! 📸 (iOS permission will be requested when needed)');
        break;
      case 'Push notifications':
        _showPermissionResult('Notifications ready! 🔔 (iOS permission will be requested when needed)');
        break;
      case 'File uploads':
        _showPermissionResult('File uploads ready! 📁');
        break;
      case 'Analytics insights':
        _showPermissionResult('Analytics enabled! 📊');
        break;
    }
  }

  void _showPermissionResult(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFFD700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ResponsiveScaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Light grey background like iOS simulator
      body: SafeArea(
        child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            _buildHeader(),
              
              // Navigation Tabs
              _buildNavigationTabs(),
              
              // Dashboard Content based on selected tab
              _selectedTabIndex == 0 ? _buildOverviewTab() : _buildQuickActionsTab(),
              
              // Chat History Section
              _buildChatHistorySection(),
            
                      // Main CTA Button
          _buildMainCTA(),
          
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    // Force exact same styling as iOS simulator
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Bee Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_nature,
              size: 24,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SavvyBee',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.black, // Force exact black like iOS simulator
                letterSpacing: -0.5,
              ),
                ),
                Text(
                  'Your AI Financial Coach',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600], // Force exact grey like iOS simulator
                  ),
                ),
              ],
            ),
          ),
          

          
          // const SizedBox(width: 12),
          
          // Profile Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.person,
                size: 24,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTabs() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
      child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
        child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
                  color: _selectedTabIndex == 0 ? colorScheme.surfaceVariant : Colors.white,
                  borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                      color: colorScheme.onSurface.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
              ),
            ],
          ),
                child: Center(
                child: Text(
                    'Overview',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black, // Force exact black like iOS simulator
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
                child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1 ? colorScheme.surfaceVariant : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.onSurface.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black, // Force exact black like iOS simulator
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final hasData = _memoryService.financialData['income'] > 0;
    // Always render the dashboard. If there's no data, show a subtle prompt and keep values at 0.
    Widget? emptyPrompt;
    if (!hasData) {
      emptyPrompt = Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
            children: [
            const Icon(Icons.upload_file, color: Color(0xFFFFD700)),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
                'Upload a statement from the chat to populate your dashboard.',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (emptyPrompt != null) emptyPrompt,
          Text(
            'Financial Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
              color: Colors.black, // Force exact black like iOS simulator
                    letterSpacing: -0.3,
                  ),
                ),
          const SizedBox(height: 20),
          
          // Summary Cards Row
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Monthly Income',
                  '₦${_formatNumber(_memoryService.financialData['income'])}',
                  Icons.trending_up,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Expenses',
                  '₦${_formatNumber(_memoryService.financialData['expenses'])}',
                  Icons.trending_down,
                  const Color(0xFFE91E63),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Savings Card
          _buildSummaryCard(
            'Monthly Savings',
            '₦${_formatNumber(_memoryService.financialData['savings'])}',
            Icons.savings,
            const Color(0xFFFF9800),
            fullWidth: true,
          ),
          
          const SizedBox(height: 12),
          _buildMoMDeltaRow(),

          const SizedBox(height: 20),
          
          // Spending Breakdown
          _buildSpendingBreakdownCard(colorScheme),
          
          const SizedBox(height: 20),
          
          // AI-Powered Smart Insights (Cleo-style)
          _buildAISmartInsightsCard(colorScheme),
          
          const SizedBox(height: 20),
          
          // Smart Recommendations (Cleo-style)
          _buildSmartRecommendationsCard(colorScheme),
          
          const SizedBox(height: 20),
          
          // Financial Health Dashboard
          _buildFinancialHealthDashboard(colorScheme),
          
          const SizedBox(height: 20),

          // Goals mini-card
          _buildGoalsCard(colorScheme),

          const SizedBox(height: 20),

          // Next Best Action banner
          _buildNextBestActionCard(colorScheme),

          const SizedBox(height: 20),
          
          // Available to Spend Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Available to spend',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Deposit',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                ),
              ),
            ],
          ),
        ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  hasData ? '₦${(_memoryService.financialData['savings'] / 1000).toStringAsFixed(0)}K' : '₦0K',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Progress Bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: hasData
                    ? FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _memoryService.financialData['income'] > 0 
                          ? (_memoryService.financialData['expenses'] / _memoryService.financialData['income']).clamp(0.0, 1.0)
                          : 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF44336),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasData 
                    ? '₦${(_memoryService.financialData['expenses'] / 1000).toStringAsFixed(0)}K of ₦${(_memoryService.financialData['income'] / 1000).toStringAsFixed(0)}K spent'
                    : 'Upload statement for AI analysis',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          
          const SizedBox(height: 20),
          
          // Expense by Card
          Container(
            width: double.infinity,
      padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
        children: [
          Text(
                      'Expense by',
            style: TextStyle(
                        fontSize: 16,
              fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Monthly',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: colorScheme.onSurface,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Viewing last 7 months chart',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  hasData ? '₦${(_memoryService.financialData['expenses'] / 1000).toStringAsFixed(0)}K' : '₦0K',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),
                // Time Range Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeRangeButton('1D', _selectedTimeRange == '1D'),
                    _buildTimeRangeButton('1W', _selectedTimeRange == '1W'),
                    _buildTimeRangeButton('1M', _selectedTimeRange == '1M'),
                    _buildTimeRangeButton('3M', _selectedTimeRange == '3M'),
                    _buildTimeRangeButton('1Y', _selectedTimeRange == '1Y'),
                    _buildTimeRangeButton('ALL', _selectedTimeRange == 'ALL'),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          
          const SizedBox(height: 20),
          
          // Spending Breakdown Card
  
        ],
      ),
    );
  }

  Widget _buildQuickActionsTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final quickActions = [
      {
        'title': 'Ask about Budgeting',
        'icon': Icons.account_balance_wallet,
        'color': const Color(0xFF4CAF50),
        'feature': 'Analytics insights',
      },
      {
        'title': 'Get Financial Advice',
        'icon': Icons.trending_up,
        'color': const Color(0xFF2196F3),
        'feature': 'Analytics insights',
      },
      {
        'title': 'Track Your Goals',
        'icon': Icons.flag,
        'color': const Color(0xFFFF9800),
        'feature': 'Analytics insights',
      },
      {
        'title': 'Investment Tips',
        'icon': Icons.show_chart,
        'color': const Color(0xFF9C27B0),
        'feature': 'Analytics insights',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: quickActions.length,
            itemBuilder: (context, index) {
              final action = quickActions[index];
              return GestureDetector(
                  onTap: () {
                    _requestPermission(action['feature'] as String);
                    context.go('/chat/main');
                  },
                  child: Container(
                  padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                        color: colorScheme.onSurface.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                        width: 40,
                        height: 40,
                          decoration: BoxDecoration(
                            color: action['color'] as Color,
                          borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            action['icon'] as IconData,
                          size: 20,
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(height: 16),
                        Text(
                          action['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
              ).animate(delay: Duration(milliseconds: 200 + (index * 100))).fadeIn().scale(begin: const Offset(0.8, 0.8));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatHistorySection() {
    final colorScheme = Theme.of(context).colorScheme;
    final hasData = _memoryService.financialData['income'] > 0;
    
    if (!hasData) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Chats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black, // Force exact black like iOS simulator
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ready to chat with AI! 🤖',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload a financial statement to get personalized AI insights and start your financial coaching journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    // For now, show a single chat since we're in development
    // In production, this would come from actual chat history
    final recentChats = hasData ? [
      {
        'title': 'Financial Analysis Chat',
        'lastMessage': 'Your statement has been analyzed! Ask me anything about your finances.',
        'time': 'Just now',
        'unread': true,
      },
    ] : [];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              'Recent Chats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black, // Force exact black like iOS simulator
                letterSpacing: -0.3,
              ),
            ),
          const SizedBox(height: 16),
          ...recentChats.map((chat) => _buildChatHistoryItem(chat)),
        ],
      ),
    );
  }

  Widget _buildChatHistoryItem(Map<String, dynamic> chat) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 24,
              color: const Color(0xFFFFD700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        chat['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (chat['unread'] as bool)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  chat['lastMessage'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  chat['time'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.2);
  }

  Widget _buildChartPoint(String label, double height, Color color) {
    return Column(
      children: [
        Container(
          width: 4,
          height: 40 * height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRangeButton(String label, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeRange = label;
        });
        // Here you would filter data based on time range
        // For now, we'll just update the UI
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : colorScheme.surfaceVariant,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }


  
  String _formatNumber(num value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFFFF9800);
      case 'transport':
        return const Color(0xFF2196F3);
      case 'data':
        return const Color(0xFF9C27B0);
      case 'entertainment':
        return const Color(0xFFE91E63);
      case 'utilities':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF607D8B);
    }
  }
  
  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return 'Food & Dining';
      case 'transport':
        return 'Transportation';
      case 'data':
        return 'Data & Internet';
      case 'entertainment':
        return 'Entertainment';
      case 'utilities':
        return 'Utilities';
      default:
        return category;
    }
  }
  
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpendingBreakdownCard(ColorScheme colorScheme) {
    final categories = _memoryService.financialData['categories'] as Map<String, dynamic>? ?? {};
    if (categories.isEmpty) return const SizedBox.shrink();
    
    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: const Color(0xFFFFD700),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Spending Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sortedCategories.take(5).map((entry) => _buildCategoryRow(
            entry.key,
            entry.value as num,
            _memoryService.financialData['expenses'] as num,
          )),
        ],
      ),
    );
  }
  
  Widget _buildCategoryRow(String category, num amount, num totalExpenses) {
    final percentage = (amount / totalExpenses * 100);
    final color = _getCategoryColor(category);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getCategoryDisplayName(category),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '₦${_formatNumber(amount)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFinancialHealthCard(ColorScheme colorScheme) {
    final income = _memoryService.financialData['income'] as num;
    final expenses = _memoryService.financialData['expenses'] as num;
    final savings = _memoryService.financialData['savings'] as num;
    
    final savingsRate = income > 0 ? (savings / income * 100) : 0;
    final expenseRatio = income > 0 ? (expenses / income * 100) : 0;
    
    String healthStatus;
    Color healthColor;
    IconData healthIcon;
    
    if (savingsRate >= 20) {
      healthStatus = 'Excellent';
      healthColor = const Color(0xFF4CAF50);
      healthIcon = Icons.health_and_safety;
    } else if (savingsRate >= 10) {
      healthStatus = 'Good';
      healthColor = const Color(0xFFFF9800);
      healthIcon = Icons.check_circle;
    } else {
      healthStatus = 'Needs Attention';
      healthColor = const Color(0xFFE91E63);
      healthIcon = Icons.warning;
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                healthIcon,
                color: healthColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Financial Health Score',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      healthStatus,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: healthColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Savings Rate: ${savingsRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${expenseRatio.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Expense Ratio',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // NEW: AI-Powered Smart Insights Card (Cleo-style)
  Widget _buildAISmartInsightsCard(ColorScheme colorScheme) {
    return FutureBuilder<String>(
      future: _getAISmartInsights(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity( 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: const Color(0xFF2196F3),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI Smart Insights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final insights = snapshot.data!;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity( 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: const Color(0xFF2196F3),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI Smart Insights',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                insights,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF424242),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // NEW: Get AI-powered smart insights using Groq API
  Future<String> _getAISmartInsights() async {
    try {
      final groqService = GroqAIService();
      final income = _memoryService.financialData['income'] as num;
      final expenses = _memoryService.financialData['expenses'] as num;
      final savings = _memoryService.financialData['savings'] as num;
      final categories = _memoryService.financialData['categories'] as Map<String, dynamic>? ?? {};
      
      if (income == 0) return 'Upload a statement to get AI insights!';
      
      // Create context for AI analysis
      final context = {
        'income': income,
        'expenses': expenses,
        'savings': savings,
        'categories': categories,
        'summary': '''
Income: ₦${_formatNumber(income)}
Expenses: ₦${_formatNumber(expenses)}
Savings: ₦${_formatNumber(savings)}
Spending Categories: ${categories.entries.map((e) => '${e.key}: ₦${_formatNumber(e.value)}').join(', ')}
'''
      };

      // Get AI insights
      final insights = await groqService.getSmartSpendingInsights(context);
      return insights;
    } catch (e) {
      print('Error getting AI insights: $e');
      return 'AI insights temporarily unavailable';
    }
  }

  // NEW: Smart Recommendations Card (Cleo-style actionable tips)
  Widget _buildSmartRecommendationsCard(ColorScheme colorScheme) {
    return FutureBuilder<List<String>>(
      future: _getSmartRecommendations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity( 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: const Color(0xFFFFD700),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Smart Recommendations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final recommendations = snapshot.data!;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity( 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: const Color(0xFFFFD700),
                    size: 24,
                    ),
                  const SizedBox(width: 12),
                  Text(
                    'Smart Recommendations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD700),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rec,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Color(0xFF424242),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  // NEW: Get AI-powered smart recommendations using Groq API
  Future<List<String>> _getSmartRecommendations() async {
    try {
      final groqService = GroqAIService();
      final income = _memoryService.financialData['income'] as num;
      final expenses = _memoryService.financialData['expenses'] as num;
      final savings = _memoryService.financialData['savings'] as num;
      final categories = _memoryService.financialData['categories'] as Map<String, dynamic>? ?? {};
      
      if (income == 0) return [];
      
      // Create context for AI analysis
      final context = {
        'income': income,
        'expenses': expenses,
        'savings': savings,
        'categories': categories,
        'summary': '''
Income: ₦${_formatNumber(income)}
Expenses: ₦${_formatNumber(expenses)}
Savings: ₦${_formatNumber(savings)}
Spending Categories: ${categories.entries.map((e) => '${e.key}: ₦${_formatNumber(e.value)}').join(', ')}
'''
      };

      // Get AI recommendations
      final response = await groqService.getFinancialInsights(context);
      
      // Parse the response into actionable recommendations
      final recommendations = <String>[];
      
      // Extract actionable tips from AI response
      if (response.contains('takeout') || response.contains('food') || response.contains('restaurant')) {
        recommendations.add('Consider reducing takeout expenses by ₦5,000 this month');
      }
      if (response.contains('savings') && savings < income * 0.2) {
        recommendations.add('Try moving ₦${(_memoryService.financialData['income'] * 0.1 / 1000).toStringAsFixed(0)}K to savings today');
      }
      if (response.contains('subscription') || response.contains('recurring')) {
        recommendations.add('Review recurring charges and cancel unused subscriptions');
      }
      if (expenses > income * 0.8) {
        recommendations.add('Your expenses are high - consider a budget review this week');
      }
      
      // Add AI-generated recommendation if available
      if (recommendations.isEmpty && response.isNotEmpty) {
        recommendations.add(response.split('.')[0] + '.');
      }
      
      return recommendations;
    } catch (e) {
      print('Error getting smart recommendations: $e');
      return [];
    }
  }

  Widget _buildFinancialHealthDashboard(ColorScheme colorScheme) {
    final income = _memoryService.financialData['income'] as num? ?? 0;
    final expenses = _memoryService.financialData['expenses'] as num? ?? 0;
    final savings = _memoryService.financialData['savings'] as num? ?? 0;
    final categories = _memoryService.financialData['categories'] as Map<String, dynamic>? ?? {};
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: const Color(0xFFFFD700),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Financial Health Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Key Metrics Row
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Income',
                  '₦${_formatNumber(income)}',
                  Icons.trending_up,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Expenses',
                  '₦${_formatNumber(expenses)}',
                  Icons.trending_down,
                  const Color(0xFFE91E63),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Savings & Balance
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Savings',
                  '₦${_formatNumber(savings)}',
                  Icons.savings,
                  const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Balance',
                  '₦${_formatNumber(income - expenses)}',
                  Icons.account_balance_wallet,
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Category Breakdown
          if (categories.isNotEmpty) ...[
            Text(
              'Spending Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...categories.entries.take(5).map((entry) => _buildCategoryRow(
              entry.key,
              entry.value as num,
              expenses,
            )),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.upload_file,
                    size: 32,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload a statement to see your spending breakdown',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoMDeltaRow() {
    final summary = _memoryService.getDashboardSummary();
    final trend = summary['monthlyTrend'] as Map<String, dynamic>;
    final pct = (trend['percentage'] as num?)?.toDouble() ?? 0.0;
    final isUp = pct >= 0;
    final arrow = isUp ? Icons.arrow_upward : Icons.arrow_downward;
    final color = isUp ? const Color(0xFF4CAF50) : const Color(0xFFE91E63);
    return Row(
      children: [
        Icon(arrow, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          '${pct.toStringAsFixed(1)}% vs last month',
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildGoalsCard(ColorScheme colorScheme) {
    final goals = (_memoryService.financialData['goals'] as List?) ?? [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity( 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: Color(0xFF2196F3), size: 24),
              const SizedBox(width: 12),
              Text('Goals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _memoryService.addGoal('Save ₦100,000', 100000, DateTime.now().add(const Duration(days: 90)));
                  setState(() {});
                },
                child: const Text('Add'),
              )
            ],
          ),
          const SizedBox(height: 12),
          if (goals.isEmpty)
            Text('No goals yet. Add one to start tracking progress.', style: TextStyle(color: colorScheme.onSurfaceVariant))
          else
            ...goals.take(3).map((g) {
              final desc = g['description'] as String? ?? '';
              final target = (g['targetAmount'] as num?)?.toDouble() ?? 0;
              final current = (g['currentAmount'] as num?)?.toDouble() ?? 0;
              final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(desc, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD700)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('₦${_formatNumber(current)} / ₦${_formatNumber(target)}', style: const TextStyle(fontSize: 12, color: Color(0xFF666666)))
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildNextBestActionCard(ColorScheme colorScheme) {
    return FutureBuilder<String>(
      future: GroqAIService().getSmartSpendingInsights(_memoryService.financialData),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final text = snapshot.data!.split('\n').first;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF7FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2196F3).withOpacity( 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.bolt, color: Color(0xFF2196F3)),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Next best action: ' + text, style: TextStyle(color: colorScheme.onSurface, fontSize: 14)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainCTA() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          context.go('/chat/main');
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 24,
                color: Colors.black87,
              ),
              const SizedBox(width: 12),
              Text(
                'Start New Chat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
    );
  }
}
