class tarifProgresif {
  String? tarifProgresifID;
  int penghasilanMinimal;
  int penghasilanMaksimal;
  double tarifPajak;

  tarifProgresif({
    this.tarifProgresifID,
    required this.penghasilanMinimal,
    required this.penghasilanMaksimal,
    required this.tarifPajak,
  });

  factory tarifProgresif.fromMap(Map<String, dynamic> map) {
    return tarifProgresif(
      tarifProgresifID: map['tarifProgresifID']?.toString(),
      penghasilanMinimal: map['penghasilanMinimal'] ?? 0,
      penghasilanMaksimal: map['penghasilanMaksimal'] ?? 0,
      tarifPajak: map['tarifPajak'] is int
          ? (map['tarifPajak'] as int).toDouble()
          : (map['tarifPajak'] as double? ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'penghasilanMinimal': penghasilanMinimal,
      'penghasilanMaksimal': penghasilanMaksimal,
      'tarifPajak': tarifPajak,
    };
  }
}
