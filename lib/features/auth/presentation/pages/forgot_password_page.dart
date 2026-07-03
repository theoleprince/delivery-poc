import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/features/auth/presentation/providers/auth_providers.dart';
import 'package:poc_uber/shared/widgets/input_field.dart';
import 'package:poc_uber/shared/widgets/primary_button.dart';

class ForgotPasswordPage extends HookConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();

    ref.listen(resetPasswordControllerProvider, (previous, next) {
      if (next.isLoading) return;
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      } else if (previous?.isLoading == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email de réinitialisation envoyé.')),
        );
      }
    });

    final resetState = ref.watch(resetPasswordControllerProvider);

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      await ref
          .read(resetPasswordControllerProvider.notifier)
          .resetPassword(email: emailController.text.trim());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
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
              const SizedBox(height: Spacing.lg),
              PrimaryButton(
                label: 'Envoyer le lien de réinitialisation',
                isLoading: resetState.isLoading,
                onPressed: submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
