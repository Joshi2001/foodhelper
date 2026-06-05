// Models/service_area.dart
class ServiceAreaResponse {
  final bool success;
  final List<ServiceCity> data;

  ServiceAreaResponse({
    required this.success,
    required this.data,
  });

  factory ServiceAreaResponse.fromJson(Map<String, dynamic> json) {
    return ServiceAreaResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((item) => ServiceCity.fromJson(item))
          .toList(),
    );
  }
}
// Add these fields to your ServiceCity class
class ServiceCity {
  final String city;
  final bool active;
  final List<ServiceArea> areas;
  final double? latitude; // Add this
  final double? longitude; // Add this

  ServiceCity({
    required this.city,
    required this.active,
    required this.areas,
    this.latitude,
    this.longitude,
  });

  factory ServiceCity.fromJson(Map<String, dynamic> json) {
    return ServiceCity(
      city: json['city'] ?? '',
      active: json['active'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      areas: (json['areas'] as List?)
          ?.map((area) => ServiceArea.fromJson(area))
          .toList() ?? [],
    );
  }
}

// Add latitude/longitude to ServiceArea class
class ServiceArea {
  final String name;
  final String pincode;
  final bool active;
  final double deliveryCharge;
  final double handlingCharge;
  final double? latitude; // Add this
  final double? longitude; // Add this

  ServiceArea({
    required this.name,
    required this.pincode,
    required this.active,
    required this.deliveryCharge,
    required this.handlingCharge,
    this.latitude,
    this.longitude,
  });

  factory ServiceArea.fromJson(Map<String, dynamic> json) {
    return ServiceArea(
      name: json['name'] ?? '',
      pincode: json['pincode'] ?? '',
      active: json['active'] ?? false,
      deliveryCharge: (json['deliveryCharge'] ?? 0).toDouble(),
      handlingCharge: (json['handlingCharge'] ?? 0).toDouble(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}
// // Models/service_area.dart
// class ServiceAreaResponse {
//   final bool success;
//   final List<ServiceCity> data;

//   ServiceAreaResponse({
//     required this.success,
//     required this.data,
//   });

//   factory ServiceAreaResponse.fromJson(Map<String, dynamic> json) {
//     return ServiceAreaResponse(
//       success: json['success'] ?? false,
//       data: (json['data'] as List? ?? [])
//           .map((item) => ServiceCity.fromJson(item))
//           .toList(),
//     );
//   }
// }

// class ServiceCity { 
//   final String id;
//   final String city;
//   final String state;
//   final bool active;
//   final List<ServiceArea> areas;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   ServiceCity({
//     required this.id,
//     required this.city,
//     required this.state,
//     required this.active,
//     required this.areas,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory ServiceCity.fromJson(Map<String, dynamic> json) {
//     return ServiceCity(
//       id: json['_id'] ?? '',
//       city: json['city'] ?? '',
//       state: json['state'] ?? '',
//       active: json['active'] ?? false,
//       areas: (json['areas'] as List? ?? [])
//           .map((area) => ServiceArea.fromJson(area))
//           .toList(),
//       createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
//       updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
//     );
//   }
// }

// class ServiceArea {
//   final String id;
//   final String name;
//   final String pincode;
//   final bool active;

//   ServiceArea({
//     required this.id,
//     required this.name,
//     required this.pincode,
//     required this.active,
//   });

//   factory ServiceArea.fromJson(Map<String, dynamic> json) {
//     return ServiceArea(
//       id: json['_id'] ?? '',
//       name: json['name'] ?? '',
//       pincode: json['pincode'] ?? '',
//       active: json['active'] ?? false,
//     );
//   }
// }