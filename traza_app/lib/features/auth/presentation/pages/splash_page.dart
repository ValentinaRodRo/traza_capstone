import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _scaleAnim = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) context.read<AuthBloc>().add(CheckAuthEvent());
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (state is AuthUnauthenticated) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt         = Theme.of(context);
    final brandColor = TrazaThemeTokens.brand(context);
    final brandSub   = TrazaThemeTokens.brandSub(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: _handleState,
      child: Scaffold(
        // ✅ scaffoldBackgroundColor del tema
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: brandSub,
                      borderRadius: BorderRadius.circular(TrazaRadius.xl),
                      border: Border.all(
                        color: brandColor.withOpacity(0.35),
                        width: 1,
                      ),
                      boxShadow: TrazaShadows.brand,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Image.asset(
                        'assets/icons/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: TrazaSpacing.xl),

                  // ✅ textTheme adaptativo
                  Text(
                    'Traza',
                    style: tt.textTheme.headlineLarge?.copyWith(
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: TrazaSpacing.xs),

                  Text(
                    'Chía, Cundinamarca',
                    style: tt.textTheme.labelSmall,
                  ),

                  const SizedBox(height: TrazaSpacing.xxxl + TrazaSpacing.lg),

                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        brandColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}