class rangeLocation {
  String? rangeID;
  String? checkinID;
  double longitude_realtime;
  double latitude_realtime;
  String alamat_realtime;
  DateTime? tanggalDibuat;
  double jarak_radius;

  rangeLocation({
    this.rangeID,
    this.checkinID,
    required this.longitude_realtime,
    required this.latitude_realtime,
    required this.alamat_realtime,
    required this.jarak_radius,
    this.tanggalDibuat,
  });

  factory rangeLocation.fromMap(Map<String, dynamic> map) {
    return rangeLocation(
      rangeID: map['rangeID'] as String?,
      checkinID: map['checkinID'] as String?,
      longitude_realtime:
          (map['longitude_realtime'] as num?)?.toDouble() ?? 0.0,
      latitude_realtime: (map['latitude_realtime'] as num?)?.toDouble() ?? 0.0,
      alamat_realtime: map['alamat_realtime'] ?? "-",
      jarak_radius: (map['jarak_radius'] as num?)?.toDouble() ?? 0.0,
      tanggalDibuat: map['tanggalDibuat'] != null
          ? DateTime.parse(map['tanggalDibuat'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'checkinID': checkinID,
      'longitude_realtime': longitude_realtime,
      'latitude_realtime': latitude_realtime,
      'alamat_realtime': alamat_realtime,
      'jarak_radius': jarak_radius,
    };
  }
}
