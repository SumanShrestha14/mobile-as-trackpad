import '../../domain/entities/device.dart';

class DeviceModel {
  final String id;
  final String name;
  final String address;

  const DeviceModel({required this.id, required this.name, required this.address});

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
    );
  }

  factory DeviceModel.fromEntity(Device d) => DeviceModel(id: d.id, name: d.name, address: d.address);

  Device toEntity() => Device(id: id, name: name, address: address);

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'address': address};
}
