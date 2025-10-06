  Widget _buildCoachSelectionStep() {
    final coaches = <Map<String, dynamic>>[
      {
        'name': 'Nurturing Guide',
        'description': 'Caring and Patient, like a supportive mentor/counsellor',
        'icon': Icons.psychology,
        'color': const Color(0xFF4CAF50),
        'gradient': [const Color(0xFF81C784), const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
      },
      {
        'name': 'Analytical Partner',
        'description': 'Data Driven insights with clear reasoning',
        'icon': Icons.analytics,
        'color': const Color(0xFF2196F3),
        'gradient': [const Color(0xFF64B5F6), const Color(0xFF2196F3), const Color(0xFF1976D2)],
      },
      {
        'name': 'Motivational Coach',
        'description': 'Energetic and Inspiring',
        'icon': Icons.emoji_events,
        'color': const Color(0xFFFF9800),
        'gradient': [const Color(0xFFBA68C8), const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
      },
      {
        'name': 'Practical Advisor',
        'description': 'Direct and actionable, cuts through complexity',
        'icon': Icons.lightbulb,
        'color': const Color(0xFF9C27B0),
        'gradient': [const Color(0xFFBA68C8), const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // Main title
          Text(
            "Choose your AI coach",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn().slideY(begin: 0.3),
          
          const SizedBox(height: 12),
          
          // Subtitle
          Text(
            "Your coach will adapt their style to match your financial goals.",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
          
          const SizedBox(height: 40),
          
          // Coach selection area
          Expanded(
            child: PageView.builder(
              onPageChanged: (index) {
                setState(() {
                  _selectedCoach = coaches[index]['name']!;
                });
              },
              itemCount: coaches.length,
              itemBuilder: (context, index) {
                final coach = coaches[index];
                final isSelected = _selectedCoach == coach['name'];
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Large circular graphic
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: coach['gradient'] as List<Color>,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (coach['color'] as Color).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        coach['icon'] as IconData,
                        size: 80,
                        color: Colors.white,
                      ),
                    ).animate().scale(begin: const Offset(0.8, 0.8)).then().animate().shimmer(duration: 2000.ms),
                    
                    const SizedBox(height: 24),
                    
                    // Coach name
                    Text(
                      coach['name']!,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                    
                    const SizedBox(height: 8),
                    
                    // Coach description
                    Text(
                      coach['description']!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        letterSpacing: 0.1,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                    
                    const SizedBox(height: 32),
                    
                    // Pagination dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(coaches.length, (dotIndex) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == dotIndex 
                              ? (coach['color'] as Color)
                              : Colors.grey[300],
                          ),
                        );
                      }),
                    ).animate().fadeIn(delay: 500.ms),
                  ],
                );
              },
            ),
          ),
          
          // Continue button
          _buildContinueButton(),
        ],
      ),
    );
  }
