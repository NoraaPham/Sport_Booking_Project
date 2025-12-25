class User {
  String id;
  String name;
  String email;
  String accountType;
  String imageProfile;
  String? phoneNumber;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.accountType,
    required this.imageProfile,
    this.phoneNumber,
  });
}