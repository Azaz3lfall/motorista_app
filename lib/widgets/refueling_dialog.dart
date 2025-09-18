import 'dart:io';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../models/refueling.dart';
import '../utils/validators.dart';
import '../utils/helpers.dart';
import 'image_picker_dialog.dart';

class RefuelingDialog extends StatefulWidget {
  final List<Vehicle> vehicles;
  final int? tripId;
  final Function(Refueling) onRefuelingAdded;

  const RefuelingDialog({
    super.key,
    required this.vehicles,
    this.tripId,
    required this.onRefuelingAdded,
  });

  @override
  State<RefuelingDialog> createState() => _RefuelingDialogState();
}

class _RefuelingDialogState extends State<RefuelingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _litersController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _postoController = TextEditingController();
  final _cidadeController = TextEditingController();

  int? _selectedVehicleId;
  File? _fotoBomba;
  File? _fotoOdometro;
  bool _isFullTank = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.vehicles.length == 1) {
      _selectedVehicleId = widget.vehicles.first.id;
    }
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _litersController.dispose();
    _totalCostController.dispose();
    _postoController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final refueling = Refueling(
        vehicleId: _selectedVehicleId!,
        tripId: widget.tripId,
        refuelDate: DateTime.now(),
        odometer: Helpers.parseDouble(_odometerController.text) ?? 0.0,
        litersFilled: Helpers.parseDouble(_litersController.text) ?? 0.0,
        totalCost: Helpers.parseDouble(_totalCostController.text) ?? 0.0,
        isFullTank: _isFullTank,
        postoNome: _postoController.text.trim(),
        cidade: _cidadeController.text.trim(),
        fotoBombaUrl: _fotoBomba != null ? 'uploaded_bomba' : null,
        fotoOdometroUrl: _fotoOdometro != null ? 'uploaded_odometro' : null,
      );

      widget.onRefuelingAdded(refueling);
      
      if (mounted) {
        Navigator.pop(context);
        Helpers.showSuccessSnackBar(context, 'Abastecimento registrado com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Erro ao registrar abastecimento: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool singleVehicle = widget.vehicles.length == 1;

    return AlertDialog(
      title: Text(widget.tripId != null ? 'Abastecimento em Viagem' : 'Abastecimento Avulso'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!singleVehicle) ...[
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Veículo'),
                  value: _selectedVehicleId,
                  items: widget.vehicles.map((vehicle) {
                    return DropdownMenuItem(
                      value: vehicle.id,
                      child: Text(vehicle.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedVehicleId = value;
                    });
                  },
                  validator: Validators.validateVehicleSelection,
                ),
                const SizedBox(height: 16),
              ] else ...[
                Text(
                  'Veículo: ${widget.vehicles.first.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _odometerController,
                decoration: const InputDecoration(labelText: 'Hodômetro (km)'),
                keyboardType: TextInputType.number,
                validator: Validators.validateOdometer,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _litersController,
                decoration: const InputDecoration(labelText: 'Litros'),
                keyboardType: TextInputType.number,
                validator: Validators.validateLiters,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _totalCostController,
                decoration: const InputDecoration(labelText: 'Valor Total (R\$)'),
                keyboardType: TextInputType.number,
                validator: Validators.validateCost,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _postoController,
                decoration: const InputDecoration(labelText: 'Nome do Posto'),
                validator: Validators.validatePostoName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cidadeController,
                decoration: const InputDecoration(labelText: 'Cidade'),
                validator: Validators.validateCity,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Tanque Cheio'),
                  Checkbox(
                    value: _isFullTank,
                    onChanged: (value) {
                      setState(() {
                        _isFullTank = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ImagePickerDialog.show(context, (File? image) {
                          setState(() {
                            _fotoBomba = image;
                          });
                        });
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: Text(_fotoBomba != null ? 'Foto Bomba OK' : 'Foto Bomba (opcional)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ImagePickerDialog.show(context, (File? image) {
                          setState(() {
                            _fotoOdometro = image;
                          });
                        });
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: Text(_fotoOdometro != null ? 'Foto Hodômetro OK' : 'Foto Hodômetro (opcional)'),
                    ),
                  ),
                ],
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
              : const Text('Registrar'),
        ),
      ],
    );
  }

  static Future<void> show({
    required BuildContext context,
    required List<Vehicle> vehicles,
    int? tripId,
    required Function(Refueling) onRefuelingAdded,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => RefuelingDialog(
        vehicles: vehicles,
        tripId: tripId,
        onRefuelingAdded: onRefuelingAdded,
      ),
    );
  }
}

