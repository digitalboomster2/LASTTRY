import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/services/groq_ai_service.dart';
import '../../../../shared/services/temp_memory_service.dart';
import '../../../../shared/services/file_upload_service.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAIThinking = false;
  String _aiStatus = '';
  int _aiProgress = 0;
  bool _showDocumentPopup = false;
  bool _showVoicePopup = false;
  bool _isRecording = false;
  
  final GroqAIService _aiService = GroqAIService();
  final TempMemoryService _memoryService = TempMemoryService();
  final FileUploadService _fileUploadService = FileUploadService();
  
  List<Map<String, dynamic>> _chatMessages = [];
  
  // Chat mode state management
  String _currentMode = 'default'; // 'default', 'heal', 'analyse'
  
  // Smart feature array that adapts to conversation and mode
  List<Map<String, dynamic>> get _contextualSuggestions {
    final baseSuggestions = [
      {
        'title': 'Heal Me',
        'icon': Icons.healing,
        'color': const Color(0xFFFF8A65),
        'category': 'Support',
        'description': 'Get gentle financial guidance',
        'mode': 'heal',
      },
      {
        'title': 'Analyse Me',
        'icon': Icons.analytics,
        'color': const Color(0xFF4FC3F7),
        'category': 'Insights',
        'description': 'Review your financial progress',
        'mode': 'analyse',
      },
    ];
    
    // Add mode-specific suggestions
    if (_currentMode == 'heal') {
      baseSuggestions.addAll([
        {
          'title': 'Spending Patterns',
          'icon': Icons.trending_down,
          'color': const Color(0xFFE91E63),
          'category': 'Analysis',
          'description': 'Understand your habits',
        },
        {
          'title': 'Stress Management',
          'icon': Icons.psychology,
          'color': const Color(0xFF9C27B0),
          'category': 'Wellness',
          'description': 'Find healthy alternatives',
        },
      ]);
    } else if (_currentMode == 'analyse') {
      baseSuggestions.addAll([
        {
          'title': 'Goal Progress',
          'icon': Icons.flag,
          'color': const Color(0xFF2196F3),
          'category': 'Achievement',
          'description': 'Track your milestones',
        },
        {
          'title': 'Next Steps',
          'icon': Icons.arrow_forward,
          'color': const Color(0xFFFF9800),
          'category': 'Planning',
          'description': 'Plan your next move',
        },
      ]);
    } else {
      // Default mode suggestions
      baseSuggestions.addAll([
        {
          'title': 'Budget Planning',
          'icon': Icons.account_balance_wallet,
          'color': const Color(0xFF2196F3),
          'category': 'Planning',
          'description': 'Create a personalized budget plan',
        },
        {
          'title': 'Goal Tracking',
          'icon': Icons.flag,
          'color': const Color(0xFFFF9800),
          'category': 'Goals',
          'description': 'Monitor your financial goals',
        },
      ]);
    }
    
    return baseSuggestions;
  }

  // Theme-aware color getters
  Color get _accentColor {
    switch (_currentMode) {
      case 'heal':
        return const Color(0xFFFF8A65); // Warm coral
      case 'analyse':
        return const Color(0xFF4FC3F7); // Cool blue
      default:
        return const Color(0xFFFFD700); // Default golden
    }
  }

  Color get _modeBackgroundTint {
    switch (_currentMode) {
      case 'heal':
        return Colors.orange.withOpacity( 0.03); // Very subtle warm tint
      case 'analyse':
        return Colors.blue.withOpacity( 0.03); // Very subtle cool tint
      default:
        return Colors.transparent;
      }
    }

  @override
  void initState() {
    super.initState();
    _simulateAIThinking();
    // Ask financial questions for new users
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _askFinancialQuestions();
      _injectDailyTip();
    });
  }

  void _simulateAIThinking() {
    setState(() {
      _isAIThinking = true;
      _aiStatus = 'Analyzing your financial profile...';
      _aiProgress = 0;
    });

    // Simulate AI thinking process
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _aiStatus = 'Generating personalized insights...';
          _aiProgress = 30;
        });
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _aiStatus = 'Finalizing recommendations...';
          _aiProgress = 70;
        });
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isAIThinking = false;
          _aiStatus = '';
          _aiProgress = 0;
        });
      }
    });
  }

  Future<void> _injectDailyTip() async {
    try {
      final data = _memoryService.financialData;
      final tip = await _aiService.getDailyCoaching('concise, practical', data);
      if (!mounted) return;
      setState(() {
        _chatMessages.add({
          'text': '💡 Daily Tip: ' + tip,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
      });
    } catch (_) {}
  }

  void _showSettingsMenu() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 50,
        100,
        20,
        0,
      ),
      items: [
        PopupMenuItem(
          value: 'dark_mode',
          child: Row(
            children: [
              Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                Theme.of(context).brightness == Brightness.dark
                    ? 'Light Mode'
                    : 'Dark Mode',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'permissions',
          child: Row(
            children: [
              Icon(
                Icons.security,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Permissions',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'new_topic',
          child: Row(
            children: [
              Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'New Topic',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'chat_history',
          child: Row(
            children: [
              Icon(
                Icons.history,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Chat History',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (_currentMode != 'default') PopupMenuItem(
          value: 'reset_mode',
          child: Row(
            children: [
              Icon(
                Icons.refresh,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Reset to Default Mode',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'dark_mode') {
        // Toggle dark mode - this would typically be handled by your theme provider
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dark mode toggle would be implemented here'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else if (value == 'permissions') {
        // Show permissions dialog
        _showPermissionsDialog();
      } else if (value == 'new_topic') {
        // Start new topic
        _messageController.clear();
        setState(() {
          _isAIThinking = false;
          _aiStatus = '';
          _aiProgress = 0;
        });
      } else if (value == 'chat_history') {
        // Show chat history
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat history would be shown here'),
            duration: Duration(seconds: 1),
          ),
        );
      } else if (value == 'reset_mode') {
        // Reset to default mode
        setState(() {
          _currentMode = 'default';
          _isAIThinking = true;
          _aiStatus = 'Switching to Default Mode...';
          _aiProgress = 0;
        });

        // Simulate mode switch
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _aiStatus = 'Ready to provide gentle financial guidance';
              _aiProgress = 100;
            });
          }
          
          // Clear status after showing mode confirmation
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _isAIThinking = false;
                _aiStatus = '';
                _aiProgress = 0;
              });
            }
          });
        });
      }
    });
  }

  void _showPermissionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Permissions',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPermissionItem(
              'Camera',
              'Access camera for document scanning',
              Icons.camera_alt,
            ),
            _buildPermissionItem(
              'Microphone',
              'Access microphone for voice input',
              Icons.mic,
            ),
            _buildPermissionItem(
              'Storage',
              'Access files for document upload',
              Icons.folder,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity( 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: true, // This would be connected to actual permission state
            onChanged: (value) {
              // Handle permission toggle
            },
          ),
        ],
      ),
    );
  }

  void _showDocumentAttachmentPopup() {
    setState(() {
      _showDocumentPopup = true;
    });
  }

  void _hideDocumentAttachmentPopup() {
    setState(() {
      _showDocumentPopup = false;
    });
  }

  void _showVoiceRecordingPopup() {
    setState(() {
      _showVoicePopup = true;
    });
  }

  void _hideVoiceRecordingPopup() {
    setState(() {
      _showVoicePopup = false;
      _isRecording = false;
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    
    if (_isRecording) {
      // Start recording logic would go here
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isRecording) {
          setState(() {
            _isRecording = false;
          });
          _hideVoiceRecordingPopup();
          // Add recorded message to chat
          _messageController.text = "Voice message recorded";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return ResponsiveScaffold(
        backgroundColor: const Color(0xFFFAFAFA), // Light grey background like iOS simulator
      body: Stack(
        children: [
          // Mode-based background tint overlay
          Positioned.fill(
            child: Container(
              color: _modeBackgroundTint,
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Premium Header
                _buildPremiumHeader(isDarkMode),
                
                // AI Thinking State
                if (_isAIThinking) _buildAIThinkingState(isDarkMode),
                
                // Chat Messages Area
                Expanded(
                  child: _buildChatMessages(isDarkMode),
                ),
                
                // Smart Feature Array
                _buildSmartFeatureArray(isDarkMode),
                
                // Enhanced Chatbox
                _buildEnhancedChatbox(isDarkMode),
              ],
            ),
          ),
          
          // Document Attachment Popup
          if (_showDocumentPopup)
            _buildDocumentAttachmentPopup(isDarkMode),
          
          // Voice Recording Popup
          if (_showVoicePopup)
            _buildVoiceRecordingPopup(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(bool isDarkMode) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity( 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.go('/chat'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.arrow_back,
                color: isDarkMode ? Colors.white : Colors.black87,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // AI Coach Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withOpacity( 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _currentMode == 'heal' ? Icons.healing : 
              _currentMode == 'analyse' ? Icons.analytics : 
              Icons.psychology,
              color: Colors.black87,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Title and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Savvy Bee',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Your AI Financial Coach',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    if (_currentMode != 'default') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _accentColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _currentMode == 'heal' ? 'Heal Mode' : 'Analyse Mode',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Settings Button (3 dots)
          GestureDetector(
            onTap: _showSettingsMenu,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.more_vert,
                color: isDarkMode ? Colors.white : Colors.black87,
                size: 20,
              ),
            ),
          ),
          

        ],
      ),
    );
  }

  Widget _buildAIThinkingState(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.white.withOpacity( 0.05) : Colors.black.withOpacity( 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // AI Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _currentMode == 'heal' ? Icons.healing : 
              _currentMode == 'analyse' ? Icons.analytics : 
              Icons.psychology,
              color: Colors.black87,
              size: 16,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Status and Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _aiStatus,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress Bar
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withOpacity( 0.1) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _aiProgress / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Estimated Time
          Text(
            '${(3 - (_aiProgress / 33.33).floor()).toString().padLeft(2, '0')}:${((100 - _aiProgress) / 1.67).floor().toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }

  Widget _buildChatMessages(bool isDarkMode) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Welcome Message (only show if no chat history)
        if (_chatMessages.isEmpty) _buildWelcomeMessage(isDarkMode),
        
        // Chat Messages
        ..._chatMessages.map((message) => _buildChatMessage(message, isDarkMode)),
        
        // AI Thinking State (if active)
        if (_isAIThinking) _buildAIThinkingMessage(isDarkMode),
      ],
    );
  }

  Widget _buildWelcomeMessage(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.black87,
              size: 16,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Message Bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.white.withOpacity( 0.05) : Colors.black.withOpacity( 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi! I\'m your AI financial coach powered by Groq. I\'m here to help you make smarter money decisions.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'To get started, try uploading your financial statement using the 📎 button. I\'ll analyze it with real AI and provide personalized insights!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }

  Widget _buildChatMessage(Map<String, dynamic> message, bool isDarkMode) {
    final isUser = message['isUser'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF4FC3F7) : const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isUser ? Icons.person : Icons.psychology,
              color: Colors.black87,
              size: 16,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Message Bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser 
                    ? (isDarkMode ? const Color(0xFF4FC3F7) : const Color(0xFF4FC3F7))
                    : (isDarkMode ? const Color(0xFF2A2A2A) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.white.withOpacity( 0.05) : Colors.black.withOpacity( 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message['text'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isUser ? Colors.white : (isDarkMode ? Colors.white : Colors.black87),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }

  Widget _buildAIThinkingMessage(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.black87,
              size: 16,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Thinking Bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.white.withOpacity( 0.05) : Colors.black.withOpacity( 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Animated dots
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).animate(delay: const Duration(milliseconds: 0))
                        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0))
                        .then()
                        .scale(begin: const Offset(1.0, 1.0), end: const Offset(0.5, 0.5)),
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).animate(delay: const Duration(milliseconds: 200))
                        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0))
                        .then()
                        .scale(begin: const Offset(1.0, 1.0), end: const Offset(0.5, 0.5)),
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).animate(delay: const Duration(milliseconds: 400))
                        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0))
                        .then()
                        .scale(begin: const Offset(1.0, 1.0), end: const Offset(0.5, 0.5)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _aiStatus,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }

  Widget _buildSmartFeatureArray(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Text(
                'Suggested',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'AI Powered',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Core Suggestions Grid
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _contextualSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _contextualSuggestions[index];
                return Container(
                  width: 140,
                  margin: EdgeInsets.only(right: index < _contextualSuggestions.length - 1 ? 12 : 0),
                  child: GestureDetector(
                    onTap: () => _handleSuggestionTap(suggestion),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: suggestion['color'] as Color,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode ? Colors.white.withOpacity( 0.05) : Colors.black.withOpacity( 0.05),
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
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: suggestion['color'] as Color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  suggestion['icon'] as IconData,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                suggestion['category'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: suggestion['color'] as Color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            suggestion['title'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate(delay: Duration(milliseconds: index * 100))
                  .fadeIn()
                  .slideX(begin: 0.3);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedChatbox(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.white.withOpacity( 0.05) : Colors.black.withOpacity( 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Input Field Row
          Row(
            children: [
              
              // Text Input Field with inline buttons
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      // Text Field
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Ask me anything about your finances...',
                            hintStyle: TextStyle(
                              color: isDarkMode ? Colors.white60 : Colors.black54,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      
                      // Inline Attachment Button
                      GestureDetector(
                        onTap: _showDocumentAttachmentPopup,
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.attach_file,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            size: 16,
                          ),
                        ),
                      ),
                      
                      // Inline Camera Button
                      GestureDetector(
                        onTap: () {
                          // Handle camera action
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Camera access would be implemented here'),
                              backgroundColor: const Color(0xFFFFD700),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Send Button
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _accentColor.withOpacity( 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.send,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Voice Recording Button
              GestureDetector(
                onTap: _showVoiceRecordingPopup,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.mic,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          

        ],
      ),
    );
  }

  void _handleSuggestionTap(Map<String, dynamic> suggestion) {
    // Handle mode switching for Heal Me and Analyse Me
    if (suggestion['mode'] == 'heal' || suggestion['mode'] == 'analyse') {
      setState(() {
        _currentMode = suggestion['mode'] as String;
        _isAIThinking = true;
        _aiStatus = _currentMode == 'heal' 
            ? 'Switching to Heal Mode...' 
            : 'Switching to Analyse Mode...';
        _aiProgress = 0;
      });
      
      // Simulate mode switch
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _aiStatus = _currentMode == 'heal' 
                ? 'Ready to provide gentle financial guidance' 
                : 'Ready to analyze your financial progress';
            _aiProgress = 100;
          });
        }
        
        // Clear status after showing mode confirmation
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isAIThinking = false;
              _aiStatus = '';
              _aiProgress = 0;
            });
          }
        });
      });
      return;
    }
    
    // Handle other suggestions
    setState(() {
      _isAIThinking = true;
      _aiStatus = 'Processing ${suggestion['title']}...';
      _aiProgress = 0;
    });
    
    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAIThinking = false;
          _aiStatus = '';
          _aiProgress = 0;
        });
      }
    });
  }

  Widget _buildDocumentAttachmentPopup(bool isDarkMode) {
    return Stack(
      children: [
        // Blurred background overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity( 0.3),
            ),
          ),
        ),
        
        // Popup content
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity( 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white30 : Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    'Attach Document',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                
                // Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildAttachmentOption(
                        'Camera',
                        'Scan document with camera',
                        Icons.camera_alt,
                        isDarkMode,
                        () {
                          _hideDocumentAttachmentPopup();
                          // Handle camera action
                        },
                      ),
                      _buildAttachmentOption(
                        'Gallery',
                        'Choose from photo library',
                        Icons.photo_library,
                        isDarkMode,
                        () {
                          _hideDocumentAttachmentPopup();
                          // Handle gallery action
                        },
                      ),
                      _buildAttachmentOption(
                        'Files',
                        'Browse device files',
                        Icons.folder_open,
                        isDarkMode,
                        () async {
                          _hideDocumentAttachmentPopup();
                          // Upload financial statement and post chat update on success
                          final String? insights = await _fileUploadService.uploadFinancialStatement(context);
                          if (insights != null && mounted) {
                            await _postAnalysisChatUpdate(insights: insights);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentOption(
    String title,
    String subtitle,
    IconData icon,
    bool isDarkMode,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDarkMode ? Colors.white : Colors.black87,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDarkMode ? Colors.white30 : Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceRecordingPopup(bool isDarkMode) {
    return Stack(
      children: [
        // Blurred background overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity( 0.3),
            ),
          ),
        ),
        
        // Popup content
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity( 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white30 : Colors.grey[400],
                  ),
                ),
                
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    'Voice Recording',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                
                // Recording visualization
                Container(
                  height: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Waveform visualization
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return Container(
                              width: 4,
                              height: _isRecording ? 20 + (index * 8) : 8,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: _isRecording 
                                    ? const Color(0xFFFFD700)
                                    : (isDarkMode ? Colors.white30 : Colors.grey[400]),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ).animate(delay: Duration(milliseconds: index * 100))
                              .scaleY(begin: 0.5, end: 1.0)
                              .then()
                              .scaleY(begin: 1.0, end: 0.5);
                          }),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          _isRecording ? 'Recording...' : 'Tap to start recording',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: GestureDetector(
                          onTap: _hideVoiceRecordingPopup,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Record button
                      Expanded(
                        child: GestureDetector(
                          onTap: _toggleRecording,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: _isRecording 
                                  ? Colors.red 
                                  : const Color(0xFFFFD700),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                color: _isRecording ? Colors.white : Colors.black87,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add user message to chat
    setState(() {
      _chatMessages.add({
        'text': message,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _messageController.clear();
    });

    // Show AI thinking state
    setState(() {
      _isAIThinking = true;
      _aiStatus = 'Analyzing your message...';
      _aiProgress = 0;
    });

    try {
      // Get financial data context
      final financialData = _memoryService.financialData;
      final context = financialData.isNotEmpty 
          ? 'User has financial data: ${financialData.toString()}'
          : 'User has no financial data uploaded yet';

      // Get AI response
      final aiResponse = await _aiService.chatWithAI(message, context);

      // Update progress
      setState(() {
        _aiProgress = 100;
      });

      // Add AI response to chat
      setState(() {
        _chatMessages.add({
          'text': aiResponse,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isAIThinking = false;
        _aiStatus = '';
        _aiProgress = 0;
      });

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

    } catch (e) {
      setState(() {
        _chatMessages.add({
          'text': 'I\'m having trouble connecting to my AI brain right now. Let me try to help you with what I know about your finances, or you can try rephrasing your question.',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isAIThinking = false;
        _aiStatus = '';
        _aiProgress = 0;
      });
    }
  }

  void _askFinancialQuestions() async {
    if (_chatMessages.isEmpty) {
      try {
        // Get AI-powered financial questions based on user's financial data
        final hasFinancialData = _memoryService.financialData['income'] > 0;
        
        if (hasFinancialData) {
          // If user has uploaded statements, ask AI-generated contextual questions
          final context = '''
Income: ₦${_memoryService.financialData['income']}
Expenses: ₦${_memoryService.financialData['expenses']}
Savings: ₦${_memoryService.financialData['savings']}
Categories: ${_memoryService.financialData['categories']}
''';
          
          final aiQuestions = await _aiService.getFinancialQuestions();
          if (aiQuestions.isNotEmpty) {
            _addAIQuestion(aiQuestions);
          }
        } else {
          // If no financial data, ask general onboarding questions
          _addAIQuestion('Hi! I\'m here to help with your finances. To get started, could you tell me your estimated monthly income?');
          _addAIQuestion('What are your main financial goals? (e.g., save for emergency fund, pay off debt, invest)');
          _addAIQuestion('What\'s your biggest financial challenge right now?');
        }
      } catch (e) {
        print('Error getting AI questions: $e');
        // Fallback to basic questions
        _addAIQuestion('Hi! I\'m here to help with your finances. To get started, could you tell me your estimated monthly income?');
      }
    }
  }

  void _addAIQuestion(String question) {
    setState(() {
      _chatMessages.add({
        'text': question,
        'isUser': false,
        'timestamp': DateTime.now(),
        'isQuestion': true,
      });
    });
  }

  Future<void> _postAnalysisChatUpdate({String? insights}) async {
    // Compose a concise ChatGPT‑style brief
    final data = _memoryService.financialData;
    final income = (data['income'] as num? ?? 0).toDouble();
    final expenses = (data['expenses'] as num? ?? 0).toDouble();
    final savings = (data['savings'] as num? ?? 0).toDouble();

    // Try to pull opening/closing from current month snapshot
    String openingStr = '';
    String closingStr = '';
    final currentMonth = data['currentMonth'] as String?;
    final monthly = data['monthlyData'] as Map<String, dynamic>?;
    if (currentMonth != null && monthly != null) {
      final monthMap = monthly[currentMonth] as Map<String, dynamic>?;
      if (monthMap != null) {
        final open = (monthMap['openingBalance'] as num?)?.toDouble();
        final close = (monthMap['closingBalance'] as num?)?.toDouble();
        if (open != null) openingStr = 'Opening Balance: ₦${_formatNumber(open)}\n';
        if (close != null) closingStr = 'Closing Balance: ₦${_formatNumber(close)}\n';
      }
    }

    final header = '📋 Account Statement Brief';
    final overview = 'Income: ₦${_formatNumber(income)}  •  Expenses: ₦${_formatNumber(expenses)}  •  Savings: ₦${_formatNumber(savings)}';
    final body = [
      if (openingStr.isNotEmpty) openingStr.trim(),
      if (closingStr.isNotEmpty) closingStr.trim(),
      if (insights != null && insights.isNotEmpty) insights.trim(),
    ].where((s) => s.isNotEmpty).join('\n');

    final text = [header, overview, if (body.isNotEmpty) '', body].join('\n');

    if (!mounted) return;
    setState(() {
      _chatMessages.add({
        'text': text,
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    });
  }

  String _formatNumber(num value) {
    final n = value.toDouble().abs();
    if (n >= 1000000) return (value / 1000000).toStringAsFixed(1) + 'M';
    if (n >= 1000) return (value / 1000).toStringAsFixed(0) + 'K';
    return value.toStringAsFixed(0);
  }



  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}