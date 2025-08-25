import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

// Definição dos modelos de dados para Veículo e Motorista
class Vehicle {
  final int id;
  final String name;

  Vehicle({required this.id, required this.name});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      name: json['name'],
    );
  }
}

class DriverProfile {
  final int id;
  final String name;
  final List<Vehicle> associatedVehicles;

  DriverProfile({
    required this.id,
    required this.name,
    required this.associatedVehicles,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    var vehiclesJson = json['associated_vehicles'] as List;
    List<Vehicle> vehicles = vehiclesJson.map((v) => Vehicle.fromJson(v)).toList();

    return DriverProfile(
      id: json['id'],
      name: json['name'],
      associatedVehicles: vehicles,
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final String _baseUrl = 'http://104.251.211.91:3666';
  Future<List<dynamic>>? _openTrips;
  DriverProfile? _driverProfile;

  @override
  void initState() {
    super.initState();
    _fetchDriverProfile().then((_) {
      _openTrips = _fetchOpenTrips();
    });
  }

  // Busca as informações do motorista, incluindo os veículos associados.
  Future<void> _fetchDriverProfile() async {
    final url = Uri.parse('$_baseUrl/app/motorista/profile');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _driverProfile = DriverProfile.fromJson(data);
          });
        }
      } else {
        if (response.statusCode == 401 && mounted) {
           _logout();
        }
        print('Erro ao buscar perfil do motorista: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar perfil do motorista: $e');
    }
  }

  // Busca todas as viagens com o status "Em Andamento".
  Future<List<dynamic>> _fetchOpenTrips() async {
    final cleanToken = widget.token.trim();
    if (cleanToken.isEmpty) {
        _logout();
        return [];
    }

    final url = Uri.parse('$_baseUrl/app/motorista/trips?status=Em%20Andamento');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        print('Erro 401: Token inválido ou não autorizado');
        _logout();
        return [];
      } else {
          throw Exception('Falha ao carregar as viagens: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
      throw Exception('Erro de conexão ao buscar viagens: ${e.toString()}');
    }
  }

  // Função para limpar o token e redirecionar para a tela de login.
  void _logout() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
          );
      }
  }

  // Função para fazer upload de uma imagem com a URL correta.
  Future<String?> _uploadImage(File imageFile) async {
    // Altera a URL para a rota específica do motorista que espera JWT.
    final url = Uri.parse('$_baseUrl/app/motorista/upload');
    try {
      // Obtém a extensão do arquivo para o tipo de mídia.
      String extension = p.extension(imageFile.path).toLowerCase();
      MediaType mediaType = MediaType('image', extension.isNotEmpty ? extension.substring(1) : 'jpeg');

      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer ${widget.token}'
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: mediaType,
        ));

      var response = await request.send();

      // TRATAMENTO DE ERRO: Se o token for inválido, faz o logout.
      if (response.statusCode == 401) {
        _logout();
        return null;
      }

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        return data['filePath'];
      } else {
        print('Erro no upload da imagem: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro de conexão no upload: $e');
      return null;
    }
  }

  // Função para adicionar um registro de abastecimento na API.
  Future<void> _addRefueling({
    required int vehicleId,
    int? tripId,
    required double odometer,
    required double litersFilled,
    required double totalCost,
    required bool isFullTank,
    required String postoNome,
    required String cidade,
    String? fotoBombaUrl,
    String? fotoOdometroUrl,
  }) async {
    final url = Uri.parse('$_baseUrl/app/motorista/refuelings');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'vehicle_id': vehicleId,
          'refuel_date': DateTime.now().toIso8601String(),
          'odometer': odometer,
          'liters_filled': litersFilled,
          'total_cost': totalCost,
          'is_full_tank': isFullTank,
          'posto_nome': postoNome,
          'cidade': cidade,
          'foto_bomba': fotoBombaUrl,
          'foto_odometro': fotoOdometroUrl,
          if (tripId != null) 'viagem_id': tripId,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abastecimento registrado com sucesso!')),
        );
        if (mounted) {
          setState(() {
            _openTrips = _fetchOpenTrips();
          });
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorDialog(context, errorData['error'] ?? 'Falha ao registrar abastecimento');
      }
    } catch (e) {
      _showErrorDialog(context, 'Erro de conexão: ${e.toString()}');
    }
  }

  // Função para mostrar o diálogo de escolha de fonte da imagem (câmera ou galeria).
  Future<void> _showImageSourceDialog(BuildContext context, Function(File?) onImagePicked) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Escolher Imagem'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                onTap: () async {
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    onImagePicked(File(pickedFile.path));
                  }
                  if (mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () async {
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    onImagePicked(File(pickedFile.path));
                  }
                  if (mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Diálogo de abastecimento unificado e aprimorado.
  void _showRefuelingDialog({required BuildContext context, int? tripId}) {
    if (_driverProfile == null || _driverProfile!.associatedVehicles.isEmpty) {
      _showErrorDialog(context, 'Nenhum veículo associado ao seu perfil.');
      return;
    }
    
    final bool singleVehicle = _driverProfile!.associatedVehicles.length == 1;
    final int? defaultVehicleId = singleVehicle ? _driverProfile!.associatedVehicles.first.id : null;
    
    int? selectedVehicleId = defaultVehicleId;
    File? fotoBomba;
    File? fotoOdometro;

    final formKey = GlobalKey<FormState>();
    final odometerController = TextEditingController();
    final litersController = TextEditingController();
    final totalCostController = TextEditingController();
    final postoController = TextEditingController();
    final cidadeController = TextEditingController();
    bool isFullTank = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(tripId != null ? 'Abastecimento em Viagem' : 'Abastecimento Avulso'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!singleVehicle) ...[
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(labelText: 'Veículo'),
                          value: selectedVehicleId,
                          items: _driverProfile!.associatedVehicles.map((vehicle) {
                            return DropdownMenuItem(
                              value: vehicle.id,
                              child: Text(vehicle.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedVehicleId = value;
                            });
                          },
                          validator: (value) => value == null ? 'Selecione um veículo' : null,
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        Text('Veículo: ${_driverProfile!.associatedVehicles.first.name}', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: odometerController,
                        decoration: const InputDecoration(labelText: 'Hodômetro (km)'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Insira o hodômetro' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: litersController,
                        decoration: const InputDecoration(labelText: 'Litros'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Insira os litros' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: totalCostController,
                        decoration: const InputDecoration(labelText: 'Valor Total (R\$)'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Insira o valor total' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: postoController,
                        decoration: const InputDecoration(labelText: 'Nome do Posto'),
                        validator: (value) => value!.isEmpty ? 'Insira o nome do posto' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: cidadeController,
                        decoration: const InputDecoration(labelText: 'Cidade'),
                        validator: (value) => value!.isEmpty ? 'Insira a cidade' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Tanque Cheio'),
                          Checkbox(
                            value: isFullTank,
                            onChanged: (value) {
                              setState(() {
                                isFullTank = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      // CORREÇÃO: Botões de upload de imagens com Expanded para evitar overflow.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _showImageSourceDialog(context, (File? image) {
                                  setState(() {
                                    fotoBomba = image;
                                  });
                                });
                              },
                              icon: const Icon(Icons.camera_alt),
                              label: Text(fotoBomba != null ? 'Foto Bomba OK' : 'Foto Bomba (opcional)'),
                            ),
                          ),
                          const SizedBox(width: 8), 
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _showImageSourceDialog(context, (File? image) {
                                  setState(() {
                                    fotoOdometro = image;
                                  });
                                });
                              },
                              icon: const Icon(Icons.camera_alt),
                              label: Text(fotoOdometro != null ? 'Foto Hodômetro OK' : 'Foto Hodômetro (opcional)'),
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final fotoBombaUrl = fotoBomba != null ? await _uploadImage(fotoBomba!) : null;
                      final fotoOdometroUrl = fotoOdometro != null ? await _uploadImage(fotoOdometro!) : null;
                      
                      if ((fotoBomba != null && fotoBombaUrl == null) || (fotoOdometro != null && fotoOdometroUrl == null)) {
                        _showErrorDialog(context, 'Falha ao fazer upload de uma ou mais fotos.');
                        return;
                      }

                      _addRefueling(
                        vehicleId: selectedVehicleId!,
                        tripId: tripId,
                        odometer: double.tryParse(odometerController.text) ?? 0.0,
                        litersFilled: double.tryParse(litersController.text) ?? 0.0,
                        totalCost: double.tryParse(totalCostController.text) ?? 0.0,
                        isFullTank: isFullTank,
                        postoNome: postoController.text,
                        cidade: cidadeController.text,
                        fotoBombaUrl: fotoBombaUrl,
                        fotoOdometroUrl: fotoOdometroUrl,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Registrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // O diálogo de adicionar custo agora é mais simples e não inclui abastecimento.
  void _showAddCostDialog(BuildContext context, int tripId) {
    final formKey = GlobalKey<FormState>();
    final descricaoController = TextEditingController();
    final valorController = TextEditingController();
    String? tipoCusto;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Custo'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: tipoCusto,
                  decoration: const InputDecoration(labelText: 'Tipo de Custo'),
                  items: const [
                    DropdownMenuItem(value: 'PEDAGIO', child: Text('Pedágio')),
                    DropdownMenuItem(value: 'ALIMENTACAO', child: Text('Alimentação')),
                    DropdownMenuItem(value: 'MANUTENCAO', child: Text('Manutenção')),
                    DropdownMenuItem(value: 'OUTROS', child: Text('Outros')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tipoCusto = value;
                    });
                  },
                  validator: (value) => value == null ? 'Selecione o tipo de custo' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descricaoController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  validator: (value) => value!.isEmpty ? 'Insira a descrição' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: valorController,
                  decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Insira o valor' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                     _addCost(
                        widget.token,
                        tripId,
                        tipoCusto!,
                        descricaoController.text,
                        double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0.0,
                        _driverProfile!.associatedVehicles.first.id
                      );
                    Navigator.pop(context);
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }
  
  // Função para adicionar outros custos (sem abastecimento).
  Future<void> _addCost(String token, int tripId, String tipoCusto, String descricao, double valor, int vehicleId) async {
    final url = Uri.parse('$_baseUrl/app/motorista/custos');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'viagem_id': tripId,
          'tipo_custo': tipoCusto,
          'descricao': descricao,
          'valor': valor,
          'vehicle_id': vehicleId,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Custo adicionado com sucesso!')),
        );
        if (mounted) {
          setState(() {
            _openTrips = _fetchOpenTrips();
          });
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorDialog(context, errorData['error'] ?? 'Falha ao adicionar custo');
      }
    } catch (e) {
      _showErrorDialog(context, 'Erro de conexão: ${e.toString()}');
    }
  }

  // Diálogo para finalizar a viagem.
  void _showFinalizeTripDialog(BuildContext context, int tripId) {
    final formKey = GlobalKey<FormState>();
    final distanciaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Finalizar Viagem'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: distanciaController,
              decoration: const InputDecoration(labelText: 'Distância Total (km)'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Insira a distância total' : null,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _finalizeTrip(
                    widget.token,
                    tripId,
                    double.tryParse(distanciaController.text.replaceAll(',', '.')) ?? 0.0,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Finalizar'),
            ),
          ],
        );
      },
    );
  }

  // Função para finalizar uma viagem na API.
  Future<void> _finalizeTrip(String token, int tripId, double distanciaTotal) async {
    final url = Uri.parse('$_baseUrl/app/motorista/trips/$tripId/finalizar');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'distancia_total': distanciaTotal,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viagem finalizada com sucesso!')),
        );
        if (mounted) {
          setState(() {
            _openTrips = _fetchOpenTrips();
          });
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorDialog(context, errorData['error'] ?? 'Erro ao finalizar viagem: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog(context, 'Erro de conexão: ${e.toString()}');
    }
  }

  // Função genérica para exibir diálogos de erro.
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Viagens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _openTrips,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _driverProfile == null) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nenhuma viagem em andamento.'),
                  if (_driverProfile!.associatedVehicles.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showRefuelingDialog(context: context),
                      icon: const Icon(Icons.local_gas_station),
                      label: const Text('Adicionar Abastecimento Avulso'),
                    ),
                  ] else ...[
                     const SizedBox(height: 16),
                    const Text('Nenhum veículo associado ao seu perfil.'),
                  ],
                ],
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final trip = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Viagem para ${trip['end_city']}'),
                    subtitle: Text('Iniciada em: ${trip['start_date']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botão de abastecimento dedicado
                        IconButton(
                          icon: const Icon(Icons.local_gas_station, color: Colors.blue),
                          onPressed: () => _showRefuelingDialog(context: context, tripId: trip['id']),
                        ),
                        // Botão de adicionar outros custos
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: () => _showAddCostDialog(context, trip['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => _showFinalizeTripDialog(context, trip['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}