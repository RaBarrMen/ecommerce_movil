import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/widgets/loading_widget.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.status == AuthStatus.loading) {
              return const LoadingWidget(message: 'Iniciando sesión...');
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Logo / icon
                  FadeInDown(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        size: 56,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      AppStrings.appName,
                      style: theme.textTheme.displayLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      AppStrings.signInSubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Error
                  if (auth.status == AuthStatus.error && auth.errorMessage != null)
                    FadeIn(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.errorMessage!,
                                style: const TextStyle(
                                    color: AppColors.error, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Google button
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: GoogleSignInButton(
                      onPressed: () async {
                        await auth.signInWithGoogle();
                        if (auth.isAuthenticated && context.mounted) {
                          context.go(AppRoutes.home);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}