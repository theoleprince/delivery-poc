import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/core/constants/app_routes.dart';
import 'package:poc_uber/features/auth/presentation/providers/auth_providers.dart';
import 'package:poc_uber/shared/widgets/input_field.dart';
import 'package:poc_uber/shared/widgets/primary_button.dart';
import 'package:poc_uber/shared/widgets/secondary_button.dart';

class SignInPage extends HookConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    ref.listen(signInControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    });

    final signInState = ref.watch(signInControllerProvider);

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      await ref
          .read(signInControllerProvider.notifier)
          .signIn(
            email: emailController.text.trim(),
            password: passwordController.text,
          );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InputField(
                label: 'Email',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const <String>[AutofillHints.email],
                validator: (String? value) => (value == null || !value.contains('@'))
                    ? 'Email invalide'
                    : null,
              ),
              const SizedBox(height: Spacing.md),
              InputField(
                label: 'Mot de passe',
                controller: passwordController,
                obscureText: true,
                autofillHints: const <String>[AutofillHints.password],
                validator: (String? value) => (value == null || value.length < 6)
                    ? '6 caractères minimum'
                    : null,
              ),
              const SizedBox(height: Spacing.lg),
              PrimaryButton(
                label: 'Se connecter',
                isLoading: signInState.isLoading,
                onPressed: submit,
              ),
              const SizedBox(height: Spacing.sm),
              SecondaryButton(
                label: 'Mot de passe oublié ?',
                onPressed: () => context.push(AppRoutes.forgotPassword),
              ),
              const SizedBox(height: Spacing.sm),
              SecondaryButton(
                label: 'Créer un compte',
                onPressed: () => context.push(AppRoutes.signUp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
