import 'vehicle.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'associated_vehicles': associatedVehicles.map((v) => v.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'DriverProfile(id: $id, name: $name, vehicles: ${associatedVehicles.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DriverProfile &&
        other.id == id &&
        other.name == name &&
        other.associatedVehicles.length == associatedVehicles.length;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ associatedVehicles.length.hashCode;
}
