import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/mock/mock_data.dart';
import 'package:sportheroes_mobile/core/providers/providers.dart';
import 'package:sportheroes_mobile/features/onboarding/widgets/onboarding_page.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  final _pages = MockData.onboardingPages;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(localStorageServiceProvider).setOnboarded(true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _next() {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return OnboardingPage(
                    title: page['title'] as String,
                    subtitle: page['subtitle'] as String,
                    iconName: page['icon'] as String,
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.grey300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(
                    _index == _pages.length - 1 ? 'Get Started' : 'Next',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
