import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  LOGIN PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthLoading) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isLoading = false);
    }
    if (state is AuthAuthenticated) {
      HapticFeedback.lightImpact();
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (state is AuthError) {
      _showError(state.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: TrazaColors.danger,
              size: 16,
            ),
            const SizedBox(width: TrazaSpacing.sm),
            Expanded(
              child: Text(
                message,
                // bodyMedium = textSecondary por defecto, forzamos primary
                style: TrazaTextStyles.bodyMedium.copyWith(
                  color: TrazaColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: TrazaColors.bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: TrazaRadius.card,
          side: const BorderSide(color: TrazaColors.border, width: 0.5),
        ),
        margin: const EdgeInsets.all(TrazaSpacing.lg),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    context.read<AuthBloc>().add(
          LoginEvent(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleState,
      child: Scaffold(
        backgroundColor: TrazaColors.bg,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: TrazaSpacing.xxl,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 52),

                      // ── Header ──────────────────────────────────────
                      const _TrazaAuthHeader(
                        icon: Icons.location_on_rounded,
                        title: 'Bienvenido',
                        subtitle:
                            'Ingresa a tu cuenta para ver\nlas zonas de riesgo en Chía.',
                      ),

                      const SizedBox(height: TrazaSpacing.xxxl + TrazaSpacing.sm),

                      // ── Email ────────────────────────────────────────
                      _TrazaField(
                        controller: _emailController,
                        label: 'Correo electrónico',
                        hint: 'tu@correo.com',
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingresa tu correo';
                          if (!v.contains('@')) return 'Correo inválido';
                          return null;
                        },
                      ),

                      const SizedBox(height: TrazaSpacing.md),

                      // ── Contraseña ───────────────────────────────────
                      _TrazaField(
                        controller: _passwordController,
                        label: 'Contraseña',
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: TrazaColors.textSecondary,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),

                      const SizedBox(height: TrazaSpacing.xxl + TrazaSpacing.sm),

                      // ── Botón principal ──────────────────────────────
                      _TrazaPrimaryButton(
                        label: 'Ingresar',
                        isLoading: _isLoading,
                        onTap: _submit,
                      ),

                      const SizedBox(height: TrazaSpacing.xl),

                      // ── Divisor ──────────────────────────────────────
                      const _TrazaDivider(label: 'o'),

                      const SizedBox(height: TrazaSpacing.xl),

                      // ── Ir a registro ────────────────────────────────
                      _TrazaSecondaryButton(
                        label: 'Crear cuenta',
                        onTap: () => Navigator.of(context).pushNamed('/register'),
                      ),

                      const SizedBox(height: TrazaSpacing.xxxl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  REGISTER PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String _selectedRole = 'ciudadano';

  static const List<_RoleOption> _roles = [
    _RoleOption(
      value: 'ciudadano',
      label: 'Ciudadano',
      icon: Icons.person_outline_rounded,
    ),
    _RoleOption(
      value: 'autoridad',
      label: 'Autoridad',
      icon: Icons.shield_outlined,
    ),
  ];

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthLoading) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isLoading = false);
    }
    if (state is AuthAuthenticated) {
      HapticFeedback.lightImpact();
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (state is AuthError) {
      _showError(state.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: TrazaColors.danger,
              size: 16,
            ),
            const SizedBox(width: TrazaSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: TrazaTextStyles.bodyMedium.copyWith(
                  color: TrazaColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: TrazaColors.bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: TrazaRadius.card,
          side: const BorderSide(color: TrazaColors.border, width: 0.5),
        ),
        margin: const EdgeInsets.all(TrazaSpacing.lg),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    context.read<AuthBloc>().add(
          RegisterEvent(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _selectedRole,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleState,
      child: Scaffold(
        backgroundColor: TrazaColors.bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              margin: const EdgeInsets.all(TrazaSpacing.sm),
              decoration: BoxDecoration(
                color: TrazaColors.bgCard,
                borderRadius: BorderRadius.circular(TrazaRadius.sm),
                border: Border.all(color: TrazaColors.border, width: 0.5),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: TrazaColors.textSecondary,
                size: 15,
              ),
            ),
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: TrazaSpacing.xxl,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: TrazaSpacing.sm),

                    // ── Header ──────────────────────────────────────
                    const _TrazaAuthHeader(
                      icon: Icons.person_add_alt_1_rounded,
                      title: 'Crear cuenta',
                      subtitle:
                          'Únete a la comunidad Traza y\nayuda a mapear Chía.',
                    ),

                    const SizedBox(height: TrazaSpacing.xxxl),

                    // ── Selector de rol ──────────────────────────────
                    Text(
                      'Tipo de cuenta',
                      // labelSmall default color = textTertiary, ok para label
                      style: TrazaTextStyles.labelMedium,
                    ),
                    const SizedBox(height: TrazaSpacing.sm),
                    _RoleSelector(
                      roles: _roles,
                      selected: _selectedRole,
                      onChanged: (v) => setState(() => _selectedRole = v),
                    ),

                    const SizedBox(height: TrazaSpacing.xl),

                    // ── Email ────────────────────────────────────────
                    _TrazaField(
                      controller: _emailController,
                      label: 'Correo electrónico',
                      hint: 'tu@correo.com',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa tu correo';
                        if (!v.contains('@')) return 'Correo inválido';
                        return null;
                      },
                    ),

                    const SizedBox(height: TrazaSpacing.md),

                    // ── Contraseña ───────────────────────────────────
                    _TrazaField(
                      controller: _passwordController,
                      label: 'Contraseña',
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: TrazaColors.textSecondary,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                        if (v.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),

                    const SizedBox(height: TrazaSpacing.md),

                    // ── Confirmar contraseña ─────────────────────────
                    _TrazaField(
                      controller: _confirmController,
                      label: 'Confirmar contraseña',
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                        child: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: TrazaColors.textSecondary,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                        if (v != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: TrazaSpacing.xxl + TrazaSpacing.sm),

                    // ── Botón principal ──────────────────────────────
                    _TrazaPrimaryButton(
                      label: 'Crear cuenta',
                      isLoading: _isLoading,
                      onTap: _submit,
                    ),

                    const SizedBox(height: TrazaSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  WIDGETS INTERNOS — locales a las páginas de auth
// ═══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────
//  Header
// ─────────────────────────────────────────────

class _TrazaAuthHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrazaAuthHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: TrazaColors.brandSub,
            borderRadius: BorderRadius.circular(TrazaRadius.lg),
            border: Border.all(
              color: TrazaColors.brand.withOpacity(0.35),
              width: 1,
            ),
          ),
          child: Icon(icon, color: TrazaColors.brand, size: 24),
        ),

        const SizedBox(height: TrazaSpacing.lg + TrazaSpacing.xs),

        // headlineLarge = 24px / w700 / textPrimary ✓
        Text(title, style: TrazaTextStyles.headlineLarge),

        const SizedBox(height: TrazaSpacing.xs + 2),

        // bodyMedium = 13px / textSecondary — ideal para subtítulo
        Text(
          subtitle,
          style: TrazaTextStyles.bodyMedium.copyWith(height: 1.6),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Campo de texto
//  Hereda fill/border del inputDecorationTheme
//  pero los sobreescribe con los tokens exactos.
// ─────────────────────────────────────────────

class _TrazaField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const _TrazaField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // labelMedium = 12px / w500 / textSecondary ✓
        Text(label, style: TrazaTextStyles.labelMedium),
        const SizedBox(height: TrazaSpacing.xs + 2),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          // bodyLarge para texto ingresado: 15px / w400 / textPrimary ✓
          style: TrazaTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            // bodyMedium default es textSecondary, perfecto para hint
            hintStyle: TrazaTextStyles.bodyMedium,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TrazaSpacing.md + 2,
              ),
              child: Icon(icon, size: 17, color: TrazaColors.textSecondary),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: TrazaSpacing.md),
                    child: suffixIcon,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 44),
            // Sobreescribimos fillColor para usar bgCard (más elevado que bgSurface)
            filled: true,
            fillColor: TrazaColors.bgCard,
            contentPadding: TrazaSpacing.inputPadding,
            // Borders: alineados con inputDecorationTheme pero con bgCard
            border: OutlineInputBorder(
              borderRadius: TrazaRadius.input,
              borderSide: const BorderSide(color: TrazaColors.border, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: TrazaRadius.input,
              borderSide: const BorderSide(color: TrazaColors.border, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: TrazaRadius.input,
              borderSide: const BorderSide(
                color: TrazaColors.borderFocus,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: TrazaRadius.input,
              borderSide: const BorderSide(color: TrazaColors.danger, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: TrazaRadius.input,
              borderSide: const BorderSide(color: TrazaColors.danger, width: 1),
            ),
            // labelSmall = 10px / w500 / textTertiary — compacto para error
            errorStyle: TrazaTextStyles.labelSmall.copyWith(
              color: TrazaColors.dangerText,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Botón primario
// ─────────────────────────────────────────────

class _TrazaPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _TrazaPrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: isLoading
              ? TrazaColors.brand.withOpacity(0.6)
              : TrazaColors.brand,
          borderRadius: TrazaRadius.button,
          boxShadow: isLoading ? [] : TrazaShadows.brand,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  label,
                  // labelLarge = 14px / w600 / textPrimary — sobreescribimos color
                  style: TrazaTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Botón secundario
// ─────────────────────────────────────────────

class _TrazaSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TrazaSecondaryButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: TrazaColors.bgCard,
          borderRadius: TrazaRadius.button,
          border: Border.all(color: TrazaColors.border, width: 0.5),
        ),
        child: Center(
          child: Text(
            label,
            // labelLarge = 14px / w600 — color por defecto textPrimary ✓
            style: TrazaTextStyles.labelLarge,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Divisor con label
// ─────────────────────────────────────────────

class _TrazaDivider extends StatelessWidget {
  final String label;
  const _TrazaDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: TrazaColors.border, thickness: 0.5),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TrazaSpacing.md),
          child: Text(label, style: TrazaTextStyles.labelMedium),
        ),
        const Expanded(
          child: Divider(color: TrazaColors.border, thickness: 0.5),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Selector de rol
// ─────────────────────────────────────────────

class _RoleOption {
  final String value;
  final String label;
  final IconData icon;

  const _RoleOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class _RoleSelector extends StatelessWidget {
  final List<_RoleOption> roles;
  final String selected;
  final void Function(String) onChanged;

  const _RoleSelector({
    required this.roles,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: roles.map((role) {
        final isSelected = role.value == selected;
        final isLast = role == roles.last;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(role.value);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: isLast ? 0 : TrazaSpacing.sm),
              padding: const EdgeInsets.symmetric(vertical: TrazaSpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? TrazaColors.brandSub : TrazaColors.bgCard,
                borderRadius: TrazaRadius.card,
                border: Border.all(
                  color: isSelected
                      ? TrazaColors.brand.withOpacity(0.5)
                      : TrazaColors.border,
                  width: isSelected ? 1.0 : 0.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    role.icon,
                    size: 20,
                    color: isSelected
                        ? TrazaColors.brand
                        : TrazaColors.textSecondary,
                  ),
                  const SizedBox(height: TrazaSpacing.xs + 2),
                  Text(
                    role.label,
                    // titleSmall = 13px / w600 / textPrimary
                    style: TrazaTextStyles.titleSmall.copyWith(
                      color: isSelected
                          ? TrazaColors.brand
                          : TrazaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}