import '../../data/datasources/device_location_datasource.dart';
import '../entities/device_position.dart';

class GetCurrentPositionUseCase {
  final DeviceLocationDataSource dataSource;
  GetCurrentPositionUseCase({required this.dataSource});
  Future<DevicePosition> call() => dataSource.getCurrentPosition();
}
