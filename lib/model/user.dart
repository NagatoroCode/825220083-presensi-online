class AppUser {
  String? userID;
  String email;
  String password;
  String roleID;

  AppUser({
    required this.userID,
    required this.email,
    required this.password,
    required this.roleID,
  });

  factory AppUser.fromMap(Map<String, dynamic> Map) {
    return AppUser(
      userID: Map['userID']?.toString(),
      email: Map['email'],
      password: Map['password'],
      roleID: Map['roleID'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'email': email,
      'password': password,
      'roleID': roleID,
    };
  }
}
