import '../../domain/entities/device.dart';

class DeviceModel {
  final String id;
  final String name;
  final String address;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.address,
  });

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final name = map['name'];
    final address = map['address'];

    if (id is! String || name is! String || address is! String) {
      throw const FormatException('Invalid device payload');
    }

    return DeviceModel(id: id, name: name, address: address);
  }

  factory DeviceModel.fromEntity(Device d) =>
      DeviceModel(id: d.id, name: d.name, address: d.address);

  Device toEntity() => Device(id: id, name: name, address: address);

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'address': address};
}
