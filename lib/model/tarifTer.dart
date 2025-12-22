class tarifTer {
  String? tarifTerID;
  String ptkpID;
  int penghasilanMinimal;
  int penghasilanMaksimal;
  double tarifPajak;

  tarifTer({
    this.tarifTerID,
    required this.ptkpID,
    required this.penghasilanMinimal,
    required this.penghasilanMaksimal,
    required this.tarifPajak,
  });

  factory tarifTer.fromMap(Map<String, dynamic> Map) {
    return tarifTer(
      tarifTerID: Map['tarifTerID']?.toString(),
      ptkpID: Map['ptkpID'],
      penghasilanMinimal: Map['penghasilanMinimal'],
      penghasilanMaksimal: Map['penghasilanMaksimal'],
      tarifPajak: Map['tarifPajak'] is int
          ? (Map['tarifPajak'] as int).toDouble()
          : Map['tarifPajak'] as double? ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ptkpID': ptkpID,
      'penghasilanMinimal': penghasilanMinimal,
      'penghasilanMaksimal': penghasilanMaksimal,
      'tarifPajak': tarifPajak,
    };
  }
}
