import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/core/constants/app_routes.dart';
import 'package:poc_uber/features/delivery/domain/entities/recipient_entity.dart';
import 'package:poc_uber/features/delivery/presentation/providers/delivery_draft_provider.dart';
import 'package:poc_uber/shared/widgets/input_field.dart';
import 'package:poc_uber/shared/widgets/primary_button.dart';

/// Étape 3 du flux de création : coordonnées du destinataire.
class RecipientInfoPage extends HookConsumerWidget {
  const RecipientInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final phoneController = useTextEditingController();
    final addressController = useTextEditingController();
    final instructionsController = useTextEditingController();

    String? requiredValidator(String? value) =>
        (value == null || value.trim().isEmpty) ? 'Champ requis' : null;

    void submit() {
      if (!formKey.currentState!.validate()) return;

      final RecipientEntity recipient = RecipientEntity(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        instructions: instructionsController.text.trim().isEmpty
            ? null
            : instructionsController.text.trim(),
      );

      ref
          .read(deliveryDraftControllerProvider.notifier)
          .setRecipient(recipient);
      context.push(AppRoutes.deliverySummary);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Destinataire')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              InputField(
                label: 'Nom',
                controller: nameController,
                validator: requiredValidator,
              ),
              const SizedBox(height: Spacing.md),
              InputField(
                label: 'Téléphone',
                controller: phoneController,
                keyboardType: TextInputType.phone,
                validator: requiredValidator,
              ),
              const SizedBox(height: Spacing.md),
              InputField(
                label: 'Adresse',
                controller: addressController,
                validator: requiredValidator,
              ),
              const SizedBox(height: Spacing.md),
              InputField(
                label: 'Instructions (optionnel)',
                controller: instructionsController,
              ),
              const SizedBox(height: Spacing.lg),
              PrimaryButton(label: 'Suivant', onPressed: submit),
            ],
          ),
        ),
      ),
    );
  }
}
