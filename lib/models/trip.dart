class Trip {
  final int id;
  final String startCity;
  final String endCity;
  final String startDate;
  final String status;

  Trip({
    required this.id,
    required this.startCity,
    required this.endCity,
    required this.startDate,
    required this.status,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      startCity: json['start_city'] ?? '',
      endCity: json['end_city'] ?? '',
      startDate: json['start_date'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_city': startCity,
      'end_city': endCity,
      'start_date': startDate,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'Trip(id: $id, from: $startCity to: $endCity, date: $startDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Trip &&
        other.id == id &&
        other.startCity == startCity &&
        other.endCity == endCity &&
        other.startDate == startDate &&
        other.status == status;
  }

  @override
  int get hashCode => id.hashCode ^ startCity.hashCode ^ endCity.hashCode ^ startDate.hashCode ^ status.hashCode;
}

