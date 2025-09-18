enum CostType {
  pedagio('PEDAGIO', 'Pedágio'),
  alimentacao('ALIMENTACAO', 'Alimentação'),
  manutencao('MANUTENCAO', 'Manutenção'),
  estacionamento('ESTACIONAMENTO', 'Estacionamento'),
  lavagem('LAVAGEM', 'Lavagem'),
  hospedagem('HOSPEDAGEM', 'Hospedagem'),
  combustivel('COMBUSTIVEL', 'Combustível'),
  outros('OUTROS', 'Outros');

  const CostType(this.value, this.displayName);
  
  final String value;
  final String displayName;

  static CostType fromString(String value) {
    return CostType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CostType.outros,
    );
  }
}

class Cost {
  final int? id;
  final int? tripId; // Agora opcional para custos avulsos
  final CostType tipoCusto;
  final String descricao;
  final double valor;
  final int vehicleId;
  final String? fotoComprovante; // Nova propriedade para imagem

  Cost({
    this.id,
    this.tripId, // Removido required
    required this.tipoCusto,
    required this.descricao,
    required this.valor,
    required this.vehicleId,
    this.fotoComprovante, // Nova propriedade opcional
  });

  factory Cost.fromJson(Map<String, dynamic> json) {
    return Cost(
      id: json['id'],
      tripId: json['viagem_id'],
      tipoCusto: CostType.fromString(json['tipo_custo']),
      descricao: json['descricao'] ?? '',
      valor: (json['valor'] as num).toDouble(),
      vehicleId: json['vehicle_id'],
      fotoComprovante: json['foto_comprovante'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (tripId != null) 'viagem_id': tripId, // Só inclui se não for null
      'tipo_custo': tipoCusto.value,
      'descricao': descricao,
      'valor': valor,
      'vehicle_id': vehicleId,
      if (fotoComprovante != null) 'foto_path': fotoComprovante,
    };
  }

  @override
  String toString() {
    return 'Cost(id: $id, tripId: $tripId, type: ${tipoCusto.displayName}, description: $descricao, value: $valor)';
  }
}
