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
    final tt = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: tt.colorScheme.error,
              size: 16,
            ),
            const SizedBox(width: TrazaSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: tt.textTheme.bodyMedium?.copyWith(
                  color: tt.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: tt.cardTheme.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: TrazaRadius.card,
          side: BorderSide(
            color: tt.dividerTheme.color ?? TrazaColors.border,
            width: 0.5,
          ),
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
        // ✅ Hereda scaffoldBackgroundColor del tema
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

                      const _TrazaAuthHeader(
                        icon: Icons.location_on_rounded,
                        useLogo: true,              // ← añade esto
                        title: 'Bienvenido',
                        subtitle: 'Ingresa a tu cuenta para ver\nlas zonas de riesgo en Chía.',
                      ),

                      const SizedBox(height: TrazaSpacing.xxxl + TrazaSpacing.sm),

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
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),

                      const SizedBox(height: TrazaSpacing.xxl + TrazaSpacing.sm),

                      _TrazaPrimaryButton(
                        label: 'Ingresar',
                        isLoading: _isLoading,
                        onTap: _submit,
                      ),

                      const SizedBox(height: TrazaSpacing.xl),

                      const _TrazaDivider(label: 'o'),

                      const SizedBox(height: TrazaSpacing.xl),

                      _TrazaSecondaryButton(
                        label: 'Crear cuenta',
                        onTap: () =>
                            Navigator.of(context).pushNamed('/register'),
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
    final tt = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: tt.colorScheme.error,
              size: 16,
            ),
            const SizedBox(width: TrazaSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: tt.textTheme.bodyMedium?.copyWith(
                  color: tt.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: tt.cardTheme.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: TrazaRadius.card,
          side: BorderSide(
            color: tt.dividerTheme.color ?? TrazaColors.border,
            width: 0.5,
          ),
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
    final tt = Theme.of(context);
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleState,
      child: Scaffold(
        // ✅ Hereda scaffoldBackgroundColor del tema
        appBar: AppBar(
          // ✅ backgroundColor/elevation heredados de appBarTheme
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              margin: const EdgeInsets.all(TrazaSpacing.sm),
              decoration: BoxDecoration(
                color: tt.cardTheme.color,
                borderRadius: BorderRadius.circular(TrazaRadius.sm),
                border: Border.all(
                  color: tt.dividerTheme.color ?? TrazaColors.border,
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: tt.colorScheme.onSurface.withOpacity(0.6),
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

                    const _TrazaAuthHeader(
                      icon: Icons.person_add_alt_1_rounded,
                      title: 'Crear cuenta',
                      subtitle:
                          'Únete a la comunidad Traza y\nayuda a mapear Chía.',
                    ),

                    const SizedBox(height: TrazaSpacing.xxxl),

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
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                        if (v.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),

                    const SizedBox(height: TrazaSpacing.md),

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
//  WIDGETS INTERNOS
// ═══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────
//  Header
// ─────────────────────────────────────────────

class _TrazaAuthHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool useLogo;

  const _TrazaAuthHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.useLogo = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt         = Theme.of(context);
    final brandColor = TrazaThemeTokens.brand(context);
    final brandSub   = TrazaThemeTokens.brandSub(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: useLogo
                ? LinearGradient(
                    colors: [brandColor, TrazaColors.brandDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: useLogo ? null : brandSub,
            borderRadius: BorderRadius.circular(TrazaRadius.lg),
            border: Border.all(
              color: brandColor.withOpacity(0.35),
              width: 1,
            ),
            boxShadow: useLogo ? TrazaShadows.brand : null,
          ),
          child: useLogo
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/icons/logo.png',
                    fit: BoxFit.contain,
                  ),
                )
              : Icon(icon, color: brandColor, size: 24),
        ),

        const SizedBox(height: TrazaSpacing.lg + TrazaSpacing.xs),

        Text(title, style: tt.textTheme.headlineLarge),

        const SizedBox(height: TrazaSpacing.xs + 2),

        Text(
          subtitle,
          style: tt.textTheme.bodyMedium?.copyWith(height: 1.6),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Campo de texto
//  ✅ Hereda fill/border del inputDecorationTheme;
//     sólo sobreescribe lo que el campo necesita
//     (prefixIcon, suffixIcon, errorStyle).
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
    final tt = Theme.of(context);
    final secondaryColor = TrazaThemeTokens.textSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Usa textTheme en lugar de TrazaTextStyles hardcodeado
        Text(label, style: tt.textTheme.labelMedium),
        const SizedBox(height: TrazaSpacing.xs + 2),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          // ✅ bodyLarge viene del textTheme ya adaptado al modo
          style: tt.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            // ✅ Sólo especificamos lo que el theme no cubre:
            //    prefixIcon, suffixIcon, errorStyle.
            //    fill, fillColor y borders se heredan de inputDecorationTheme.
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TrazaSpacing.md + 2,
              ),
              child: Icon(icon, size: 17, color: secondaryColor),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: TrazaSpacing.md),
                    child: IconTheme(
                      // ✅ suffixIcon hereda color secundario adaptativo
                      data: IconThemeData(color: secondaryColor, size: 18),
                      child: suffixIcon!,
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 44),
            errorStyle: tt.textTheme.labelSmall?.copyWith(
              color: tt.colorScheme.error,
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
    // ✅ brand es igual en dark y light, pero usamos el token por consistencia
    final brandColor = TrazaThemeTokens.brand(context);

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: isLoading ? brandColor.withOpacity(0.6) : brandColor,
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
    final tt = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          // ✅ cardTheme.color = bgCard adaptativo
          color: tt.cardTheme.color,
          borderRadius: TrazaRadius.button,
          border: Border.all(
            color: tt.dividerTheme.color ?? TrazaColors.border,
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(label, style: tt.textTheme.labelLarge),
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
    final tt = Theme.of(context);
    // ✅ Divider hereda color del dividerTheme automáticamente
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TrazaSpacing.md),
          child: Text(label, style: tt.textTheme.labelMedium),
        ),
        const Expanded(child: Divider()),
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
    final tt          = Theme.of(context);
    final brandColor  = TrazaThemeTokens.brand(context);
    final brandSub    = TrazaThemeTokens.brandSub(context);
    final borderColor = tt.dividerTheme.color ?? TrazaColors.border;

    return Row(
      children: roles.map((role) {
        final isSelected = role.value == selected;
        final isLast     = role == roles.last;

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
                // ✅ Adaptativo: brandSub o cardTheme.color
                color: isSelected ? brandSub : tt.cardTheme.color,
                borderRadius: TrazaRadius.card,
                border: Border.all(
                  color: isSelected
                      ? brandColor.withOpacity(0.5)
                      : borderColor,
                  width: isSelected ? 1.0 : 0.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    role.icon,
                    size: 20,
                    color: isSelected
                        ? brandColor
                        : TrazaThemeTokens.textSecondary(context),
                  ),
                  const SizedBox(height: TrazaSpacing.xs + 2),
                  Text(
                    role.label,
                    style: tt.textTheme.titleSmall?.copyWith(
                      color: isSelected
                          ? brandColor
                          : TrazaThemeTokens.textSecondary(context),
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