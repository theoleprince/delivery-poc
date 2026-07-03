import 'package:flutter/material.dart';

/// Indicateur de chargement standard du Design System, centré dans son
/// parent.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
