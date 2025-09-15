import 'package:flutter/material.dart';
import '../models/cost.dart';
import '../utils/validators.dart';
import '../utils/helpers.dart';

class CostDialog extends StatefulWidget {
  final int tripId;
  final int vehicleId;
  final Function(Cost) onCostAdded;

  const CostDialog({
    super.key,
    required this.tripId,
    required this.vehicleId,
    required this.onCostAdded,
  });

  @override
  State<CostDialog> createState() => _CostDialogState();
}

class _CostDialogState extends State<CostDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  CostType? _selectedCostType;
  bool _isLoading = false;

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cost = Cost(
        tripId: widget.tripId,
        tipoCusto: _selectedCostType!,
        descricao: _descricaoController.text.trim(),
        valor: Helpers.parseDouble(_valorController.text) ?? 0.0,
        vehicleId: widget.vehicleId,
      );

      widget.onCostAdded(cost);
      
      if (mounted) {
        Navigator.pop(context);
        Helpers.showSuccessSnackBar(context, 'Custo adicionado com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Erro ao adicionar custo: $e');
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
      title: const Text('Adicionar Custo'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<CostType>(
              value: _selectedCostType,
              decoration: const InputDecoration(labelText: 'Tipo de Custo'),
              items: CostType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCostType = value;
                });
              },
              validator: (value) => value == null ? 'Selecione o tipo de custo' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              validator: Validators.validateDescription,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valorController,
              decoration: const InputDecoration(labelText: 'Valor (R\$)'),
              keyboardType: TextInputType.number,
              validator: Validators.validateCost,
            ),
          ],
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
              : const Text('Adicionar'),
        ),
      ],
    );
  }

  static Future<void> show({
    required BuildContext context,
    required int tripId,
    required int vehicleId,
    required Function(Cost) onCostAdded,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => CostDialog(
        tripId: tripId,
        vehicleId: vehicleId,
        onCostAdded: onCostAdded,
      ),
    );
  }
}
