class Refueling {
  final int? id;
  final int vehicleId;
  final int? tripId;
  final DateTime refuelDate;
  final double odometer;
  final double litersFilled;
  final double totalCost;
  final bool isFullTank;
  final String postoNome;
  final String cidade;
  final String? fotoBombaUrl;
  final String? fotoOdometroUrl;

  Refueling({
    this.id,
    required this.vehicleId,
    this.tripId,
    required this.refuelDate,
    required this.odometer,
    required this.litersFilled,
    required this.totalCost,
    required this.isFullTank,
    required this.postoNome,
    required this.cidade,
    this.fotoBombaUrl,
    this.fotoOdometroUrl,
  });

  factory Refueling.fromJson(Map<String, dynamic> json) {
    return Refueling(
      id: json['id'],
      vehicleId: json['vehicle_id'],
      tripId: json['viagem_id'],
      refuelDate: DateTime.parse(json['refuel_date']),
      odometer: (json['odometer'] as num).toDouble(),
      litersFilled: (json['liters_filled'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      isFullTank: json['is_full_tank'] ?? false,
      postoNome: json['posto_nome'] ?? '',
      cidade: json['cidade'] ?? '',
      fotoBombaUrl: json['foto_bomba'],
      fotoOdometroUrl: json['foto_odometro'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'vehicle_id': vehicleId,
      if (tripId != null) 'viagem_id': tripId,
      'refuel_date': refuelDate.toIso8601String(),
      'odometer': odometer,
      'liters_filled': litersFilled,
      'total_cost': totalCost,
      'is_full_tank': isFullTank,
      'posto_nome': postoNome,
      'cidade': cidade,
      if (fotoBombaUrl != null) 'foto_bomba': fotoBombaUrl,
      if (fotoOdometroUrl != null) 'foto_odometro': fotoOdometroUrl,
    };
  }

  @override
  String toString() {
    return 'Refueling(id: $id, vehicleId: $vehicleId, odometer: $odometer, liters: $litersFilled, cost: $totalCost)';
  }
}

