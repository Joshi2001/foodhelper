import 'dart:convert';
import 'package:e_commerce/UI/Widgets/address/service_area_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServiceAreaProvider extends ChangeNotifier {
  List<ServiceCity> _serviceCities = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceCity> get serviceCities => _serviceCities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> fetchServiceAreas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://grocerrybackend.onrender.com/api/service-areas'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final serviceResponse = ServiceAreaResponse.fromJson(data);
        _serviceCities = serviceResponse.data.where((city) => city.active).toList();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to load service areas';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<String> getServiceableCities() {
    return _serviceCities.map((city) => city.city).toList();
  }

  bool isPincodeServiceable(String pincode) {
    for (final city in _serviceCities) {
      for (final area in city.areas) {
        if (area.active && area.pincode == pincode) {
          return true;
        }
      }
    }
    return false;
  }

  bool isLocationServiceable({
    String? city,
    String? pincode,
    String? address,
  }) {
    if (_serviceCities.isEmpty) return false;
    
    if (pincode != null && pincode.isNotEmpty) {
      if (isPincodeServiceable(pincode)) {
        return true;
      }
    }
  
    if (city != null && city.isNotEmpty) {
      for (final serviceCity in _serviceCities) {
        if (serviceCity.city.toLowerCase() == city.toLowerCase()) {
          return true;
        }
      }
    }
    
    if (address != null && address.isNotEmpty) {
      for (final serviceCity in _serviceCities) {
        if (address.toLowerCase().contains(serviceCity.city.toLowerCase())) {
          return true;
        }
        for (final area in serviceCity.areas) {
          if (area.active && address.toLowerCase().contains(area.name.toLowerCase())) {
            return true;
          }
        }
      }
    }
    
    return false;
  }

  bool isLocationServiceableByAddress({
    String? address,
    String? city,
    String? areaName,
    String? pincode,
  }) {
    if (_serviceCities.isEmpty) return false;
    
    for (final serviceCity in _serviceCities) {
      if (city != null && city.isNotEmpty &&
          serviceCity.city.toLowerCase() == city.toLowerCase()) {
      
        if (areaName != null && areaName.isNotEmpty) {
          for (final area in serviceCity.areas) {
            if (area.active && 
                area.name.toLowerCase() == areaName.toLowerCase()) {
              return true;
            }
          }
        }
        
        if (address != null && address.isNotEmpty) {
          for (final area in serviceCity.areas) {
            if (area.active && 
                address.toLowerCase().contains(area.name.toLowerCase())) {
              return true;
            }
          }
        }
        
        if ((areaName == null || areaName.isEmpty) && 
            (pincode == null || pincode.isEmpty)) {
          return true;
        }
      }
    
      if (pincode != null && pincode.isNotEmpty) {
        for (final area in serviceCity.areas) {
          if (area.active && area.pincode == pincode) {
            return true;
          }
        }
      }
      
      if (address != null && address.isNotEmpty) {
        for (final area in serviceCity.areas) {
          if (area.active && 
              address.toLowerCase().contains(area.name.toLowerCase())) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // New methods for delivery and handling charges
  double? getDeliveryChargeForLocation({
    String? city,
    String? pincode,
    String? areaName,
    String? address,
  }) {
    if (_serviceCities.isEmpty) return null;
    
    for (final serviceCity in _serviceCities) {
      if (city != null && city.isNotEmpty &&
          serviceCity.city.toLowerCase() == city.toLowerCase()) {
        
        if (areaName != null && areaName.isNotEmpty) {
          for (final area in serviceCity.areas) {
            if (area.active && 
                area.name.toLowerCase() == areaName.toLowerCase()) {
              return area.deliveryCharge;
            }
          }
        }
        
        if (serviceCity.areas.isNotEmpty) {
          return serviceCity.areas.first.deliveryCharge;
        }
      }
      
      if (pincode != null && pincode.isNotEmpty) {
        for (final area in serviceCity.areas) {
          if (area.active && area.pincode == pincode) {
            return area.deliveryCharge;
          }
        }
      }
      
      if (address != null && address.isNotEmpty) {
        for (final area in serviceCity.areas) {
          if (area.active && 
              address.toLowerCase().contains(area.name.toLowerCase())) {
            return area.deliveryCharge;
          }
        }
      }
    }
    return null;
  }

  double? getHandlingChargeForLocation({
    String? city,
    String? pincode,
    String? areaName,
    String? address,
  }) {
    if (_serviceCities.isEmpty) return null;
    
    for (final serviceCity in _serviceCities) {
      if (city != null && city.isNotEmpty &&
          serviceCity.city.toLowerCase() == city.toLowerCase()) {
        
        if (areaName != null && areaName.isNotEmpty) {
          for (final area in serviceCity.areas) {
            if (area.active && 
                area.name.toLowerCase() == areaName.toLowerCase()) {
              return area.handlingCharge;
            }
          }
        }
        
        if (serviceCity.areas.isNotEmpty) {
          return serviceCity.areas.first.handlingCharge;
        }
      }
      
      if (pincode != null && pincode.isNotEmpty) {
        for (final area in serviceCity.areas) {
          if (area.active && area.pincode == pincode) {
            return area.handlingCharge;
          }
        }
      }
      
      if (address != null && address.isNotEmpty) {
        for (final area in serviceCity.areas) {
          if (area.active && 
              address.toLowerCase().contains(area.name.toLowerCase())) {
            return area.handlingCharge;
          }
        }
      }
    }
    return null;
  }

  Map<String, double> getChargesForLocation({
    String? city,
    String? pincode,
    String? areaName,
    String? address,
  }) {
    return {
      'deliveryCharge': getDeliveryChargeForLocation(
        city: city,
        pincode: pincode,
        areaName: areaName,
        address: address,
      ) ?? 0.0,
      'handlingCharge': getHandlingChargeForLocation(
        city: city,
        pincode: pincode,
        areaName: areaName,
        address: address,
      ) ?? 0.0,
    };
  }

  ServiceArea? getServiceAreaByPincode(String pincode) {
    for (final city in _serviceCities) {
      for (final area in city.areas) {
        if (area.active && area.pincode == pincode) {
          return area;
        }
      }
    }
    return null;
  }
  
  String? getCityByPincode(String pincode) {
    for (final city in _serviceCities) {
      for (final area in city.areas) {
        if (area.active && area.pincode == pincode) {
          return city.city;
        }
      }
    }
    return null;
  }

  Map<String, String>? getMatchingServiceArea({
    String? address,
    String? city,
    String? areaName,
    String? pincode,
  }) {
    for (final serviceCity in _serviceCities) {
      if (city != null && city.isNotEmpty &&
          serviceCity.city.toLowerCase() == city.toLowerCase()) {
        for (final area in serviceCity.areas) {
          if (area.active) {
            if ((areaName != null && area.name.toLowerCase() == areaName.toLowerCase()) ||
                (pincode != null && area.pincode == pincode) ||
                (address != null && address.toLowerCase().contains(area.name.toLowerCase()))) {
              return {
                'city': serviceCity.city,
                'area': area.name,
                'pincode': area.pincode,
              };
            }
          }
        }
        return {
          'city': serviceCity.city,
          'area': serviceCity.areas.isNotEmpty ? serviceCity.areas.first.name : '',
          'pincode': '',
        };
      }
    
      if (pincode != null && pincode.isNotEmpty) {
        for (final area in serviceCity.areas) {
          if (area.active && area.pincode == pincode) {
            return {
              'city': serviceCity.city,
              'area': area.name,
              'pincode': area.pincode,
            };
          }
        }
      }
      
      if (address != null && address.isNotEmpty) {
        for (final area in serviceCity.areas) {
          if (area.active && address.toLowerCase().contains(area.name.toLowerCase())) {
            return {
              'city': serviceCity.city,
              'area': area.name,
              'pincode': area.pincode,
            };
          }
        }
      }
    }
    return null;
  }
}

// import 'dart:convert';
// import 'package:e_commerce/UI/Widgets/address/service_area_model.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class ServiceAreaProvider extends ChangeNotifier {
//   List<ServiceCity> _serviceCities = [];
//   bool _isLoading = false;
//   String? _error;

//   List<ServiceCity> get serviceCities => _serviceCities;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   Future<bool> fetchServiceAreas() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try { 
//       final response = await http.get(
//         Uri.parse('https://grocerrybackend.onrender.com/api/service-areas'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final serviceResponse = ServiceAreaResponse.fromJson(data);
//         _serviceCities = serviceResponse.data.where((city) => city.active).toList();
//         _isLoading = false;
//         notifyListeners();
//         return true;
//       } else {
//         _error = 'Failed to load service areas';
//         _isLoading = false;
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       _error = 'Error: $e';
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   List<String> getServiceableCities() {
//     return _serviceCities.map((city) => city.city).toList();
//   }

//   bool isPincodeServiceable(String pincode) {
//     for (final city in _serviceCities) {
//       for (final area in city.areas) {
//         if (area.active && area.pincode == pincode) {
//           return true;
//         }
//       }
//     }
//     return false;
//   }

//   bool isLocationServiceable({
//     String? city,
//     String? pincode,
//     String? address,
//   }) {
//     if (_serviceCities.isEmpty) return false;
    
//     if (pincode != null && pincode.isNotEmpty) {
//       if (isPincodeServiceable(pincode)) {
//         return true;
//       }
//     }
  
//     if (city != null && city.isNotEmpty) {
//       for (final serviceCity in _serviceCities) {
//         if (serviceCity.city.toLowerCase() == city.toLowerCase()) {
//           return true;
//         }
//       }
//     }
    
//     if (address != null && address.isNotEmpty) {
//       for (final serviceCity in _serviceCities) {
//         if (address.toLowerCase().contains(serviceCity.city.toLowerCase())) {
//           return true;
//         }
//         for (final area in serviceCity.areas) {
//           if (area.active && address.toLowerCase().contains(area.name.toLowerCase())) {
//             return true;
//           }
//         }
//       }
//     }
    
//     return false;
//   }

//   bool isLocationServiceableByAddress({
//     String? address,
//     String? city,
//     String? areaName,
//     String? pincode,
//   }) {
//     if (_serviceCities.isEmpty) return false;
    
//     for (final serviceCity in _serviceCities) {
//       if (city != null && city.isNotEmpty &&
//           serviceCity.city.toLowerCase() == city.toLowerCase()) {
      
//         if (areaName != null && areaName.isNotEmpty) {
//           for (final area in serviceCity.areas) {
//             if (area.active && 
//                 area.name.toLowerCase() == areaName.toLowerCase()) {
//               return true;
//             }
//           }
//         }
        
//         if (address != null && address.isNotEmpty) {
//           for (final area in serviceCity.areas) {
//             if (area.active && 
//                 address.toLowerCase().contains(area.name.toLowerCase())) {
//               return true;
//             }
//           }
//         }
        
//         if ((areaName == null || areaName.isEmpty) && 
//             (pincode == null || pincode.isEmpty)) {
//           return true;
//         }
//       }
    
//       if (pincode != null && pincode.isNotEmpty) {
//         for (final area in serviceCity.areas) {
//           if (area.active && area.pincode == pincode) {
//             return true;
//           }
//         }
//       }
      
//       if (address != null && address.isNotEmpty) {
//         for (final area in serviceCity.areas) {
//           if (area.active && 
//               address.toLowerCase().contains(area.name.toLowerCase())) {
//             return true;
//           }
//         }
//       }
//     }
//     return false;
//   }

//   ServiceArea? getServiceAreaByPincode(String pincode) {
//     for (final city in _serviceCities) {
//       for (final area in city.areas) {
//         if (area.active && area.pincode == pincode) {
//           return area;
//         }
//       }
//     }
//     return null;
//   }
  
//   String? getCityByPincode(String pincode) {
//     for (final city in _serviceCities) {
//       for (final area in city.areas) {
//         if (area.active && area.pincode == pincode) {
//           return city.city;
//         }
//       }
//     }
//     return null;
//   }

//   Map<String, String>? getMatchingServiceArea({
//     String? address,
//     String? city,
//     String? areaName,
//     String? pincode,
//   }) {
//     for (final serviceCity in _serviceCities) {
//       if (city != null && city.isNotEmpty &&
//           serviceCity.city.toLowerCase() == city.toLowerCase()) {
//         for (final area in serviceCity.areas) {
//           if (area.active) {
//             if ((areaName != null && area.name.toLowerCase() == areaName.toLowerCase()) ||
//                 (pincode != null && area.pincode == pincode) ||
//                 (address != null && address.toLowerCase().contains(area.name.toLowerCase()))) {
//               return {
//                 'city': serviceCity.city,
//                 'area': area.name,
//                 'pincode': area.pincode,
//               };
//             }
//           }
//         }
//         return {
//           'city': serviceCity.city,
//           'area': serviceCity.areas.isNotEmpty ? serviceCity.areas.first.name : '',
//           'pincode': '',
//         };
//       }
    
//       if (pincode != null && pincode.isNotEmpty) {
//         for (final area in serviceCity.areas) {
//           if (area.active && area.pincode == pincode) {
//             return {
//               'city': serviceCity.city,
//               'area': area.name,
//               'pincode': area.pincode,
//             };
//           }
//         }
//       }
      
//       if (address != null && address.isNotEmpty) {
//         for (final area in serviceCity.areas) {
//           if (area.active && address.toLowerCase().contains(area.name.toLowerCase())) {
//             return {
//               'city': serviceCity.city,
//               'area': area.name,
//               'pincode': area.pincode,
//             };
//           }
//         }
//       }
//     }
//     return null;
//   }
// }