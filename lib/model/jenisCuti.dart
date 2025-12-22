class jenisCuti {
  String? jenisCutiID;
  String namaCuti;

  jenisCuti({this.jenisCutiID, required this.namaCuti});

  factory jenisCuti.fromMap(Map<String, dynamic> Map) {
    return jenisCuti(
      jenisCutiID: Map['jenisCutiID']?.toString(),
      namaCuti: Map['namaCuti'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'namaCuti': namaCuti};
  }
}
