import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late PageController _pageController;
  
  // User preferences
  String _userName = '';
  String _selectedCoach = '';
  final Set<String> _selectedFeatures = <String>{};
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAFAFA), // Light grey background like iOS simulator
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar
            _buildTopBar(),
            
            // Progress indicator
            _buildProgressIndicator(),
            
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildWelcomeStep(),
                  _buildCoachSelectionStep(),
                  _buildFeaturesStep(),
                  _buildFinalStep(),
                ],
              ),
            ),
            
            // Bottom navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          if (_currentStep > 0)
            GestureDetector(
              onTap: _previousStep,
                              child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isDarkMode ? const Color(0xFF4A4A4A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                    color: _isDarkMode ? Colors.white : Colors.black54,
                  ),
                ),
            ).animate().fadeIn().slideX(begin: -0.3)
          else
            const SizedBox(width: 40),
          

          
                      // Skip button
            TextButton(
              onPressed: () => context.go('/chat'),
                          child: Text(
              'Skip',
              style: TextStyle(
                color: _isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            ).animate().fadeIn().slideX(begin: 0.3),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: index <= _currentStep 
                  ? const Color(0xFFFFD700)
                  : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          
          // Main question
          Text(
            "What's your name?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _isDarkMode ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn().slideY(begin: 0.3),
          
          const SizedBox(height: 12),
          
          // Subtitle
          Text(
            "We'll personalize your experience based on your preferences.",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: _isDarkMode ? Colors.white70 : Colors.black54,
              letterSpacing: 0.1,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
          
          const SizedBox(height: 40),
          
          // Name input field
          Container(
            decoration: BoxDecoration(
              color: _isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _isDarkMode 
                      ? Colors.white.withOpacity(0.05) 
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) => setState(() => _userName = value),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
          
          const Spacer(),
          
          // Continue button
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildCoachSelectionStep() {
    final coaches = <Map<String, dynamic>>[
      {
        'name': 'Nurturing Guide',
        'description': 'Caring and Patient, like a supportive mentor/counsellor',
        'icon': Icons.psychology,
        'color': const Color(0xFF4CAF50),
      },
      {
        'name': 'Analytical Partner',
        'description': 'Data Driven insights with clear reasoning',
        'icon': Icons.analytics,
        'color': const Color(0xFF2196F3),
      },
      {
        'name': 'Motivational Coach',
        'description': 'Energetic and Inspiring',
        'icon': Icons.emoji_events,
        'color': const Color(0xFFFF9800),
      },
      {
        'name': 'Practical Advisor',
        'description': 'Direct and actionable, cuts through complexity',
        'icon': Icons.lightbulb,
        'color': const Color(0xFF9C27B0),
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          
          // Main question
          Text(
            "Choose your AI coach",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _isDarkMode ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn().slideY(begin: 0.3),
          
          const SizedBox(height: 12),
          
          // Subtitle
          Text(
            "Your coach will adapt their style to match your financial goals.",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: _isDarkMode ? Colors.white70 : Colors.black54,
              letterSpacing: 0.1,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
          
          const SizedBox(height: 40),
          
          // Coach options
          Expanded(
            child: ListView.builder(
              itemCount: coaches.length,
              itemBuilder: (context, index) {
                final coach = coaches[index];
                final isSelected = _selectedCoach == coach['name'];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _selectedCoach = coach['name']!),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFD700) : (_isDarkMode ? const Color(0xFF2A2A2A) : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black87 : coach['color'] as Color,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Icon(
                                coach['icon'] as IconData,
                                color: isSelected ? Colors.white : Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    coach['name']!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.black87 : (_isDarkMode ? Colors.white : Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    coach['description']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isSelected ? Colors.black87 : (_isDarkMode ? Colors.white70 : Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Always reserve space for the checkmark to prevent layout shifts
                            Container(
                              width: 24,
                              height: 24,
                              child: isSelected ? Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.black87,
                                ),
                              ) : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate(delay: Duration(milliseconds: 200 * index)).fadeIn().slideY(begin: 0.3);
              },
            ),
          ),
          
          // Continue button
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildFeaturesStep() {
    final features = [
      'Dark mode',
      'Push notifications',
      'Camera access',
      'File uploads',
      'Analytics insights',
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          
          // Main question
          Text(
            "Customize your experience",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _isDarkMode ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn().slideY(begin: 0.3),
          
          const SizedBox(height: 12),
          
          // Subtitle
          Text(
            "Select the features you'd like to enable. You can change these later.",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: _isDarkMode ? Colors.white70 : Colors.black54,
              letterSpacing: 0.1,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
          
          const SizedBox(height: 40),
          
          // Select/Deselect all buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFeatures.clear();
                      _selectedFeatures.addAll(features);
                      _isDarkMode = true; // Dark mode will be enabled
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.2),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      'Select All',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFeatures.clear();
                      _isDarkMode = false; // Dark mode will be disabled
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      'Deselect All',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
          
          const SizedBox(height: 24),
          
          // Feature toggles
          Expanded(
            child: ListView.builder(
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                final isSelected = _selectedFeatures.contains(feature);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedFeatures.remove(feature);
                          } else {
                            _selectedFeatures.add(feature);
                          }
                          
                          // Update dark mode state
                          if (feature == 'Dark mode') {
                            _isDarkMode = _selectedFeatures.contains('Dark mode');
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              feature,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            Container(
                              width: 50,
                              height: 30,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFFD700) : Colors.grey[300],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: AnimatedAlign(
                                alignment: isSelected ? Alignment.centerRight : Alignment.centerLeft,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  margin: EdgeInsets.only(
                                    left: isSelected ? 0 : 2,
                                    right: isSelected ? 2 : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate(delay: Duration(milliseconds: 200 * index)).fadeIn().slideY(begin: 0.3);
              },
            ),
          ),
          
          // Continue button
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildFinalStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          
          // Success icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              size: 50,
              color: Colors.white,
            ),
          ).animate().scale(begin: const Offset(0.8, 0.8)).then().animate().shimmer(duration: 2000.ms),
          
          const SizedBox(height: 40),
          
          // Welcome message
          Text(
            "Welcome to Savvy Bee!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _isDarkMode ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn().slideY(begin: 0.3),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            "Your personalized financial wellness journey begins now. Let's make your money work for you!",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: _isDarkMode ? Colors.white70 : Colors.black54,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
          
          const Spacer(),
          
          // Get started button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => context.go('/chat'),
                child: const Center(
                  child: Text(
                    "Let's Get Started",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    final canContinue = _currentStep == 0 ? _userName.isNotEmpty :
                        _currentStep == 1 ? _selectedCoach.isNotEmpty :
                        true;
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: canContinue ? const Color(0xFFFFD700) : Colors.grey[300],
        borderRadius: BorderRadius.circular(28),
        boxShadow: canContinue ? [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: canContinue ? _nextStep : null,
          child: Center(
            child: Text(
              _currentStep == 3 ? "Get Started" : "Continue",
              style: TextStyle(
                color: canContinue ? Colors.black87 : Colors.grey[500],
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3);
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App branding
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Text(
                    'S',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'savvy bee.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          // Step indicator
          Text(
            '${_currentStep + 1} of 4',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
