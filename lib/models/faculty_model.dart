class FacultyModel {
  String uid;
  String firstName;
  String lastName;
  String surName;
  String phoneNumber;
  String email;
  String profileImageUrl;

  FacultyModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.surName,
    required this.phoneNumber,
    required this.email,
    required this.profileImageUrl,
  });

  factory FacultyModel.fromMap(Map<dynamic, dynamic> map) {
    return FacultyModel(
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
