import 'package:flutter/material.dart';
import '../utils/validators.dart';
import '../utils/helpers.dart';

class FinalizeTripDialog extends StatefulWidget {
  final int tripId;
  final Function(int tripId, double distance) onTripFinalized;

  const FinalizeTripDialog({
    super.key,
    required this.tripId,
    required this.onTripFinalized,
  });

  @override
  State<FinalizeTripDialog> createState() => _FinalizeTripDialogState();
}

class _FinalizeTripDialogState extends State<FinalizeTripDialog> {
  final _formKey = GlobalKey<FormState>();
  final _distanciaController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _distanciaController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final distance = Helpers.parseDouble(_distanciaController.text) ?? 0.0;
      widget.onTripFinalized(widget.tripId, distance);
      
      if (mounted) {
        Navigator.pop(context);
        Helpers.showSuccessSnackBar(context, 'Viagem finalizada com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Erro ao finalizar viagem: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Finalizar Viagem'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _distanciaController,
          decoration: const InputDecoration(labelText: 'Distância Total (km)'),
          keyboardType: TextInputType.number,
          validator: Validators.validateDistance,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Finalizar'),
        ),
      ],
    );
  }

  static Future<void> show({
    required BuildContext context,
    required int tripId,
    required Function(int tripId, double distance) onTripFinalized,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => FinalizeTripDialog(
        tripId: tripId,
        onTripFinalized: onTripFinalized,
      ),
    );
  }
}

