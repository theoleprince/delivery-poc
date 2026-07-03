import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/core/constants/app_routes.dart';
import 'package:poc_uber/features/delivery/domain/entities/package_entity.dart';
import 'package:poc_uber/features/delivery/presentation/providers/delivery_draft_provider.dart';
import 'package:poc_uber/shared/widgets/input_field.dart';
import 'package:poc_uber/shared/widgets/primary_button.dart';

/// Étape 2 du flux de création : informations sur le colis (nom,
/// description, poids, dimensions, valeur, instructions particulières).
class PackageInfoPage extends HookConsumerWidget {
  const PackageInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final weightController = useTextEditingController();
    final lengthController = useTextEditingController();
    final widthController = useTextEditingController();
    final heightController = useTextEditingController();
    final valueController = useTextEditingController();
    final instructionsController = useTextEditingController();

    String? requiredValidator(String? value) =>
        (value == null || value.trim().isEmpty) ? 'Champ requis' : null;

    String? positiveNumberValidator(String? value) {
      final double? parsed = double.tryParse(value ?? '');
      if (parsed == null || parsed <= 0) return 'Nombre invalide';
      return null;
    }

    void submit() {
      if (!formKey.currentState!.validate()) return;

      final PackageEntity package = PackageEntity(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        weightKg: double.parse(weightController.text),
        dimensions: PackageDimensions(
          lengthCm: double.parse(lengthController.text),
          widthCm: double.parse(widthController.text),
          heightCm: double.parse(heightController.text),
        ),
        declaredValue: double.parse(valueController.text),
        specialInstructions: instructionsController.text.trim().isEmpty
            ? null
            : instructionsController.text.trim(),
      );

      ref.read(deliveryDraftControllerProvider.notifier).setPackage(package);
      context.push(AppRoutes.deliveryRecipient);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Informations colis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              InputField(
                label: 'Nom du colis',
                controller: nameController,
                validator: requiredValidator,
              ),
              const SizedBox(height: Spacing.md),
              InputField(
                label: 'Description',
                controller: descriptionController,
                validator: requiredValidator,
              ),
              const SizedBox(height: Spacing.md),
              InputField(
                label: 'Poids (kg)',
                controller: weightController,
                keyboardType: TextInputType.number,
                validator: positiveNumberValidator,
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: <Widget>[
                  Expanded(
                    child: InputField(
                      label: 'Longueur (cm)',
                      controller: lengthController,
                      keyboardType: TextInputType.number,
                      validator: positiveNumberValidator,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: InputField(
                      label: 'Largeur (cm)',
                      controller: widthController,
                      keyboardType: TextInputType.number,
                      validator: positiveNumberValidator,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: InputField(
                      label: 'Hauteur (cm)',
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      validator: positiveNumberValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              InputField(
                label: 'Valeur déclarée',
                controller: valueController,
                keyboardType: TextInputType.number,
                validator: positiveNumberValidator,
              ),
              const SizedBox(height: Spacing.md),
              InputField(
                label: 'Instructions particulières (optionnel)',
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
