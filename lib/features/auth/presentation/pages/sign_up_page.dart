import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/features/auth/presentation/providers/auth_providers.dart';
import 'package:poc_uber/shared/widgets/input_field.dart';
import 'package:poc_uber/shared/widgets/primary_button.dart';

class SignUpPage extends HookConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    ref.listen(signUpControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    });

    final signUpState = ref.watch(signUpControllerProvider);

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      await ref
          .read(signUpControllerProvider.notifier)
          .signUp(
            email: emailController.text.trim(),
            password: passwordController.text,
            displayName: nameController.text.trim().isEmpty
                ? null
                : nameController.text.trim(),
          );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InputField(label: 'Nom', controller: nameController),
              const SizedBox(height: Spacing.md),
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
                autofillHints: const <String>[AutofillHints.newPassword],
                validator: (String? value) => (value == null || value.length < 6)
                    ? '6 caractères minimum'
                    : null,
              ),
              const SizedBox(height: Spacing.lg),
              PrimaryButton(
                label: "S'inscrire",
                isLoading: signUpState.isLoading,
                onPressed: submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
