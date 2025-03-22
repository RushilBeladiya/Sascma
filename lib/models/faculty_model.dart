class FacultyModel {
  String uid;
  String firstName;
  String lastName;
  String surName;
  String phoneNumber;
  String email;
  String position;
  String profileImageUrl;

  FacultyModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.surName,
    required this.phoneNumber,
    required this.email,
    required this.position,
    required this.profileImageUrl,
  });

  factory FacultyModel.fromJson(Map<dynamic, dynamic> json) {
    return FacultyModel(
      uid: json['uid'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      surName: json['surName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      position: json['position'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
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
      'position': position,
      'profileImageUrl': profileImageUrl,
    };
  }
}
