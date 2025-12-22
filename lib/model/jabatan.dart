class Jabatan {
  String? jabatanID;
  String namaJabatan;

  Jabatan({this.jabatanID, required this.namaJabatan});

  factory Jabatan.fromMap(Map<String, dynamic> Map) {
    return Jabatan(
      jabatanID: Map['jabatanID']?.toString(),
      namaJabatan: Map['namaJabatan'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'namaJabatan': namaJabatan};
  }
}
