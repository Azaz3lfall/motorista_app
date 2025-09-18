import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/cost.dart';
import '../models/vehicle.dart';
import '../utils/validators.dart';
import '../utils/helpers.dart';
import '../services/api_service.dart';
import 'image_picker_dialog.dart';

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
  File? _selectedImage;
  Uint8List? _imageBytes;

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
      String? imagePath;
      
      // Upload da imagem se selecionada
      if (_selectedImage != null) {
        print('📸 Imagem selecionada, iniciando upload...');
        imagePath = await ApiService().uploadImage(_selectedImage!);
        print('✅ Upload concluído! Caminho: $imagePath');
      } else {
        print('ℹ️ Nenhuma imagem selecionada');
      }

      final cost = Cost(
        tripId: null, // Custos avulsos não têm viagem associada
        tipoCusto: _selectedCostType!,
        descricao: _descricaoController.text.trim(),
        valor: Helpers.parseDouble(_valorController.text) ?? 0.0,
        vehicleId: _selectedVehicle!.id,
        fotoComprovante: imagePath,
      );

      print('💰 Enviando custo para o backend...');
      print('📋 Dados do custo: ${cost.toJson()}');

      // Enviar para o backend usando a rota específica para custos avulsos
      await ApiService().addStandaloneCost(cost);
      
      // Não chamar widget.onCostAdded(cost) aqui para evitar duplicação
      // O custo já foi enviado para o backend acima
      
      if (mounted) {
        Navigator.pop(context);
        Helpers.showSuccessSnackBar(context, 'Custo avulso adicionado com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Erro ao adicionar custo avulso: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      await ImagePickerDialog.show(context, (File? image) async {
        if (image != null) {
          // Para web, precisamos ler os bytes da imagem
          if (kIsWeb) {
            final bytes = await image.readAsBytes();
            setState(() {
              _selectedImage = image;
              _imageBytes = bytes;
            });
          } else {
            setState(() {
              _selectedImage = image;
            });
          }
        }
      });
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Erro ao selecionar imagem: $e');
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
              const SizedBox(height: 16),
              
              // Upload de Imagem
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Foto do Comprovante (Opcional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _pickImage,
                              icon: const Icon(Icons.camera_alt),
                              label: Text(_selectedImage == null ? 'Selecionar Foto' : 'Alterar Foto'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade50,
                                foregroundColor: Colors.blue.shade700,
                              ),
                            ),
                          ),
                          if (_selectedImage != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _isLoading ? null : () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Remover foto',
                            ),
                          ],
                        ],
                      ),
                      if (_selectedImage != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb && _imageBytes != null
                                ? Image.memory(
                                    _imageBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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

}

