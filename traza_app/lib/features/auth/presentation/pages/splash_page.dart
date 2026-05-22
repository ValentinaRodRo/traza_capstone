import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  SPLASH PAGE
//  Verifica sesión local y redirige a /home o /login según el estado.
// ═══════════════════════════════════════════════════════════════════════════════

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
      if (mounted) {
        context.read<AuthBloc>().add(CheckAuthEvent());
      }
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
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleState,
      child: Scaffold(
        backgroundColor: TrazaColors.bg,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo ────────────────────────────────────────────
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: TrazaColors.brandSub,
                      borderRadius: BorderRadius.circular(TrazaRadius.xl),
                      border: Border.all(
                        color: TrazaColors.brand.withOpacity(0.35),
                        width: 1,
                      ),
                      boxShadow: TrazaShadows.brand,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: TrazaColors.brand,
                      size: 34,
                    ),
                  ),

                  const SizedBox(height: TrazaSpacing.xl),

                  // ── Nombre ──────────────────────────────────────────
                  Text(
                    'Traza',
                    style: TrazaTextStyles.headlineLarge.copyWith(
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: TrazaSpacing.xs),

                  Text(
                    'Chía, Cundinamarca',
                    style: TrazaTextStyles.labelSmall,
                  ),

                  const SizedBox(height: TrazaSpacing.xxxl + TrazaSpacing.lg),

                  // ── Loader ──────────────────────────────────────────
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        TrazaColors.brand.withOpacity(0.7),
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