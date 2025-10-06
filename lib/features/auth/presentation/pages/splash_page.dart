import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _buttonController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Light grey background like iOS simulator
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Top right close button (for demo purposes)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.black54,
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
              
              const Spacer(),
              
              // Main content
              Column(
                children: [
                  // Logo and Title
                  _buildLogoAndTitle(),
                  
                  const SizedBox(height: 40),
                  
                  // Taglines
                  _buildTaglines(),
                  
                  const SizedBox(height: 60),
                  
                  // Call to Action Button
                  _buildCallToActionButton(),
                  
                  const SizedBox(height: 24),
                  
                  // How it works link
                  _buildHowItWorksLink(),
                ],
              ),
              
              const Spacer(),
              
              // Bottom bar
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Column(
      children: [
        // Bee logo icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700), // Golden yellow
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.emoji_nature,
            size: 40,
            color: Colors.white,
          ),
        ).animate(controller: _logoController).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
        ).then().animate().shimmer(duration: 2000.ms),
        
        const SizedBox(height: 24),
        
        // Main title
        Text(
          'meet savvy bee.',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ).animate(controller: _textController).fadeIn().slideY(begin: 0.3),
        
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          'your financial',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            letterSpacing: -0.2,
          ),
        ).animate(controller: _textController).fadeIn(delay: 200.ms).slideY(begin: 0.3),
        
        Text(
          'wellness companion',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            letterSpacing: -0.2,
          ),
        ).animate(controller: _textController).fadeIn(delay: 400.ms).slideY(begin: 0.3),
      ],
    );
  }

  Widget _buildTaglines() {
    return Column(
      children: [
        Text(
          'Let your finances bloom',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black45,
            letterSpacing: 0.2,
          ),
        ).animate(controller: _textController).fadeIn(delay: 600.ms),
        
        const SizedBox(height: 8),
        
        Text(
          'AI-powered insights for mindful money management',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black38,
            letterSpacing: 0.1,
          ),
          textAlign: TextAlign.center,
        ).animate(controller: _textController).fadeIn(delay: 800.ms),
      ],
    );
  }

  Widget _buildCallToActionButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => context.go('/onboarding'),
          child: const Center(
            child: Text(
              'Get Started',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    ).animate(controller: _buttonController).fadeIn().slideY(begin: 0.3);
  }

  Widget _buildHowItWorksLink() {
    return TextButton(
      onPressed: () {
        // TODO: Show how it works
      },
      child: Text(
        'How it works',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
      ),
    ).animate(controller: _buttonController).fadeIn(delay: 200.ms);
  }

  Widget _buildBottomBar() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            // Attribution
            const Text(
              'curated by Savvy',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3);
  }
}
