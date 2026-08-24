import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/app.dart';
import '../../../app/theme/app_theme.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashBloc>(
      create: (context) => SplashBloc()..add(const StartSplashTimerEvent()),
      child: const _SplashPageContent(),
    );
  }
}

class _SplashPageContent extends StatelessWidget {
  const _SplashPageContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0E1117) : Colors.white;
    final activeColor = AppTheme.getGainColor(context);
    final mutedText = AppTheme.getTextMuted(context);

    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashCompletedState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigationShell()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),

              // Center Logo & Brand Identity
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glowing Icon Container
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: activeColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: activeColor.withValues(alpha: 0.4), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.3),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.trending_up_rounded,
                        size: 54,
                        color: activeColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Brand Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'GROWW',
                        style: TextStyle(
                          color: activeColor,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'TRADING',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'Invest in Stocks • Futures & Options • ETFs',
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Smooth Loading Indicator
                  SizedBox(
                    width: 140,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        backgroundColor: activeColor.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Compliance & Security Badge
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_outlined, color: activeColor, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '100% SECURE & ENCRYPTED',
                          style: TextStyle(
                            color: activeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'NSE • BSE • SEBI REGISTERED BROKER',
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
