import 'package:flutter/material.dart';
import '../models/cost.dart';
import '../models/vehicle.dart';
import '../utils/validators.dart';
import '../utils/helpers.dart';

class StandaloneCostDialog extends StatefulWidget {
  final List<Vehicle> vehicles;
  final Function(Cost) onCostAdded;

  const StandaloneCostDialog({
    super.key,
    required this.vehicles,
    required this.onCostAdded,
  });

  @override
  State<StandaloneCostDialog> createState() => _StandaloneCostDialogState();
}

class _StandaloneCostDialogState extends State<StandaloneCostDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  CostType? _selectedCostType;
  Vehicle? _selectedVehicle;
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
        tripId: null, // Custos avulsos não têm viagem associada
        tipoCusto: _selectedCostType!,
        descricao: _descricaoController.text.trim(),
        valor: Helpers.parseDouble(_valorController.text) ?? 0.0,
        vehicleId: _selectedVehicle!.id,
      );

      widget.onCostAdded(cost);
      
      if (mounted) {
        Navigator.pop(context);
        Helpers.showSuccessSnackBar(context, 'Custo avulso adicionado com sucesso!');
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
      title: const Text('Adicionar Custo Avulso'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Seleção de Veículo
              DropdownButtonFormField<Vehicle>(
                value: _selectedVehicle,
                decoration: const InputDecoration(
                  labelText: 'Veículo',
                  border: OutlineInputBorder(),
                ),
                items: widget.vehicles.map((vehicle) {
                  return DropdownMenuItem<Vehicle>(
                    value: vehicle,
                    child: Text(vehicle.name),
                  );
                }).toList(),
                onChanged: (vehicle) {
                  setState(() {
                    _selectedVehicle = vehicle;
                  });
                },
                validator: (value) => value == null ? 'Selecione um veículo' : null,
              ),
              const SizedBox(height: 16),
              
              // Tipo de Custo
              DropdownButtonFormField<CostType>(
                value: _selectedCostType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Custo',
                  border: OutlineInputBorder(),
                ),
                items: CostType.values.map((type) {
                  return DropdownMenuItem<CostType>(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (type) {
                  setState(() {
                    _selectedCostType = type;
                  });
                },
                validator: (value) => value == null ? 'Selecione o tipo de custo' : null,
              ),
              const SizedBox(height: 16),
              
              // Descrição
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Almoço, Pedágio, Estacionamento...',
                ),
                validator: (value) => value == null || value.trim().isEmpty 
                    ? 'Descrição é obrigatória' 
                    : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              
              // Valor
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => Validators.validatePositiveNumber(value, 'Valor'),
                enabled: !_isLoading,
              ),
            ],
          ),
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
    required List<Vehicle> vehicles,
    required Function(Cost) onCostAdded,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => StandaloneCostDialog(
        vehicles: vehicles,
        onCostAdded: onCostAdded,
      ),
    );
  }
}
