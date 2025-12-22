class JenisPTKP {
  String? ptkpID;
  String namaGolongan;
  String deskripsi;
  int nilaiPTKP;

  JenisPTKP({
    this.ptkpID,
    required this.namaGolongan,
    required this.deskripsi,
    required this.nilaiPTKP,
  });

  factory JenisPTKP.fromMap(Map<String, dynamic> map) {
    return JenisPTKP(
      ptkpID: map['ptkpID']?.toString(),
      namaGolongan: map['namaGolongan'],
      deskripsi: map['deskripsi'],
      nilaiPTKP: map['nilaiPTKP'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namaGolongan': namaGolongan,
      'deskripsi': deskripsi,
      'nilaiPTKP': nilaiPTKP,
    };
  }
}
