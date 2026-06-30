
import 'package:platchatapp/utils/assets_path/assets_path.dart'; // adjust import path

enum VehicleType {
  van,
  suv,
  truck,
  camper,
  scooter,
  motorcycle,
  pickup,
  microCar,
  cityCar,
  eScooter;

  String get displayName {
    switch (this) {
      case VehicleType.van:
        return 'Van';
      case VehicleType.suv:
        return 'SUV';
      case VehicleType.truck:
        return 'Truck';
      case VehicleType.camper:
        return 'Camper';
      case VehicleType.scooter:
        return 'Scooter';
      case VehicleType.motorcycle:
        return 'Motorcycle';
      case VehicleType.pickup:
        return 'Pickup';
      case VehicleType.microCar:
        return 'Micro car';
      case VehicleType.cityCar:
        return 'City car';
      case VehicleType.eScooter:
        return 'e-scooter';
    }
  }

  String get backendKey {
    switch (this) {
      case VehicleType.van:
        return 'VAN';
      case VehicleType.suv:
        return 'SUV';
      case VehicleType.truck:
        return 'TRUCK';
      case VehicleType.camper:
        return 'CAMPER';
      case VehicleType.scooter:
        return 'SCOOTER';
      case VehicleType.motorcycle:
        return 'MOTORCYCLE';
      case VehicleType.pickup:
        return 'PICKUP';
      case VehicleType.microCar:
        return 'MICRO_CAR';
      case VehicleType.cityCar:
        return 'CITY_CAR';
      case VehicleType.eScooter:
        return 'E_SCOOTER';
    }
  }

  /// UI icon for dropdown
  String get icon {
    switch (this) {
      case VehicleType.van:
        return AssetsPath.van;
      case VehicleType.suv:
        return AssetsPath.suv;
      case VehicleType.truck:
        return AssetsPath.truck;
      case VehicleType.camper:
        return AssetsPath.camper;
      case VehicleType.scooter:
        return AssetsPath.scooter;
      case VehicleType.motorcycle:
        return AssetsPath.motorcycle;
      case VehicleType.pickup:
        return AssetsPath.pickup;
      case VehicleType.microCar:
        return AssetsPath.microCar;
      case VehicleType.cityCar:
        return AssetsPath.cityCar;
      case VehicleType.eScooter:
        return AssetsPath.eScooter;
    }
  }
}