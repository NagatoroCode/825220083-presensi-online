class userRole {
  String? roleID;
  String namaRole;

  userRole({this.roleID, required this.namaRole});

  factory userRole.fromMap(Map<String, dynamic> Map) {
    return userRole(
      roleID: Map['roleID']?.toString(),
      namaRole: Map['namaRole'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'namaRole': namaRole};
  }
}
