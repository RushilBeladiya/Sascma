class AdminModel {
  String uid;
  String firstName;
  String lastName;
  String surName;
  String phoneNumber;
  String email;
  String profileImageUrl;

  AdminModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.surName,
    required this.phoneNumber,
    required this.email,
    required this.profileImageUrl,
  });

  factory AdminModel.fromMap(Map<dynamic, dynamic> map) {
    return AdminModel(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      surName: map['surName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'surName': surName,
      'phoneNumber': phoneNumber,
      'email': email,
      'profileImageUrl': profileImageUrl,
    };
  }
}
