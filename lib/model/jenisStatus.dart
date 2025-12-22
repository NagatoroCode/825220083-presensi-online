class jenisStatus {
  String? statusID;
  String namaStatus;

  jenisStatus({this.statusID, required this.namaStatus});

  factory jenisStatus.fromMap(Map<String, dynamic> Map) {
    return jenisStatus(
      statusID: Map['statusID']?.toString(),
      namaStatus: Map['namaStatus'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'namaStatus': namaStatus};
  }
}
