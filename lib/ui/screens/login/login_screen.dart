import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sall_e_app/ui/widgets/primary_text_fields.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/password_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/form_validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      // no navegues manualmente: el redirect del router te manda a /app/dashboard
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error de autenticación')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final spacing = 16.0;
    final bigSpacing = 24.0;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final cardWidth = maxW > 700 ? 420.0 : double.infinity;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: cardWidth),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            const Center(child: AppLogo(size: 64)),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                'Ingresa a tu cuenta',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Center(
                              child: Text(
                                'Para ver el dashboard de tu vehículo',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            SizedBox(height: bigSpacing),
                            PrimaryTextField(
                              controller: _emailCtrl,
                              label: 'Correo electrónico',
                              hint: 'tu@correo.com',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icons.email,
                              validator: FormValidators.email,
                            ),
                            SizedBox(height: spacing),
                            PasswordField(
                              controller: _passCtrl,
                              label: 'Contraseña',
                              hint: '••••••••',
                              validator: (v) =>
                              FormValidators.requiredField(v, fieldName: 'Contraseña') ??
                                  FormValidators.minLength(v, 6, fieldName: 'Contraseña'),
                            ),
                            SizedBox(height: spacing),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // Aquí luego iría "olvidé mi contraseña"
                                },
                                child: const Text('¿Olvidaste tu contraseña?'),
                              ),
                            ),
                            SizedBox(height: spacing),
                            PrimaryButton(
                              label: 'Entrar',
                              icon: Icons.arrow_forward_rounded,
                              isLoading: _isLoading,
                              onPressed: _submit,
                            ),
                            SizedBox(height: bigSpacing),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '¿No tienes cuenta?',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Aquí luego iría registro
                                  },
                                  child: const Text('Crear cuenta'),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
