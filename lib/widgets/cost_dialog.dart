import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/cost.dart';
import '../utils/validators.dart';
import '../utils/helpers.dart';
import '../services/api_service.dart';
import 'image_picker_dialog.dart';

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
        tripId: widget.tripId,
        tipoCusto: _selectedCostType!,
        descricao: _descricaoController.text.trim(),
        valor: Helpers.parseDouble(_valorController.text) ?? 0.0,
        vehicleId: widget.vehicleId,
        fotoComprovante: imagePath,
      );

      print('💰 Enviando custo de viagem para o backend...');
      print('📋 Dados do custo: ${cost.toJson()}');

      // Enviar para o backend
      await ApiService().addCost(cost);
      
      // Não chamar widget.onCostAdded(cost) aqui para evitar duplicação
      // O custo já foi enviado para o backend acima
      
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
      title: const Text('Adicionar Custo'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<CostType>(
                value: _selectedCostType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Custo',
                  border: OutlineInputBorder(),
                ),
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
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateDescription,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.validateCost,
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

