
import 'package:platchatapp/utils/assets_path/assets_path.dart'; // adjust import path

enum VehicleType {
  cityCar,
  van,
  suv,
  truck,
  camper,
  scooter,
  motorcycle,
  pickup,
  microCar,
  eScooter;

  String get displayName {
    switch (this) {
      case VehicleType.cityCar:
        return 'City car';
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
      case VehicleType.eScooter:
        return 'e-scooter';
    }
  }

  String get backendKey {
    switch (this) {
      case VehicleType.cityCar:
        return 'CITY_CAR';

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
      case VehicleType.eScooter:
        return 'E_SCOOTER';
    }
  }

  /// UI icon for dropdown
  String get icon {
    switch (this) {
      case VehicleType.cityCar:
        return AssetsPath.cityCar;

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
      case VehicleType.eScooter:
        return AssetsPath.eScooter;
    }
  }

  /// PNG shown when this type is the centered/selected item in the carousel.
  String get imageBlue {
    switch (this) {
      case VehicleType.cityCar:
        return AssetsPath.cityCarBlue;
      case VehicleType.van:
        return AssetsPath.vanBlue;
      case VehicleType.suv:
        return AssetsPath.suvBlue;
      case VehicleType.truck:
        return AssetsPath.truckBlue;
      case VehicleType.camper:
        return AssetsPath.camperBlue;
      case VehicleType.scooter:
        return AssetsPath.scooterBlue;
      case VehicleType.motorcycle:
        return AssetsPath.motoBlue;
      case VehicleType.pickup:
        return AssetsPath.pickupBlue;
      case VehicleType.microCar:
        return AssetsPath.microCarBlue;
      case VehicleType.eScooter:
        return AssetsPath.eScooterBlue;
    }
  }

  /// PNG shown when this type is a side/unselected item in the carousel.
  String get imageWhite {
    switch (this) {
      case VehicleType.cityCar:
        return AssetsPath.cityCarWhite;
      case VehicleType.van:
        return AssetsPath.vanWhite;
      case VehicleType.suv:
        return AssetsPath.suvWhite;
      case VehicleType.truck:
        return AssetsPath.truckWhite;
      case VehicleType.camper:
        return AssetsPath.camperWhite;
      case VehicleType.scooter:
        return AssetsPath.scooterWhite;
      case VehicleType.motorcycle:
        return AssetsPath.motoWhite;
      case VehicleType.pickup:
        return AssetsPath.pickupWhite;
      case VehicleType.microCar:
        return AssetsPath.microCarWhite;
      case VehicleType.eScooter:
        return AssetsPath.eScooterWhite;
    }
  }
}