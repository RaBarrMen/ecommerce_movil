import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../widgets/onboarding_page_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      title: AppStrings.onboarding1Title,
      subtitle: AppStrings.onboarding1Subtitle,
      color: Color(0xFFEEEDFE),
      icon: Icons.shopping_bag_outlined,
    ),
    _OnboardingData(
      title: AppStrings.onboarding2Title,
      subtitle: AppStrings.onboarding2Subtitle,
      color: Color(0xFFFFEEF2),
      icon: Icons.lock_outline,
    ),
    _OnboardingData(
      title: AppStrings.onboarding3Title,
      subtitle: AppStrings.onboarding3Subtitle,
      color: Color(0xFFE8FFF4),
      icon: Icons.local_shipping_outlined,
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  Future<void> _finish() async {
    await context.read<AuthProvider>().completeOnboarding();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text(AppStrings.skip),
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => OnboardingPageWidget(
                  title: _pages[i].title,
                  subtitle: _pages[i].subtitle,
                  backgroundColor: _pages[i].color,
                  icon: _pages[i].icon,
                ),
              ),
            ),
            // Indicator + button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.primaryLight,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLastPage
                          ? _finish
                          : () => _controller.nextPage(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                              ),
                      child: Text(
                        _isLastPage
                            ? AppStrings.getStarted
                            : AppStrings.next,
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
  }
}

class _OnboardingData {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}