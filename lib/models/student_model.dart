class StudentModel {
  String uid;
  String firstName;
  String lastName;
  String surName;
  String spid;
  String phoneNumber;
  String email;
  String stream;
  String semester;
  String division;
  String profileImageUrl;
  List<Map<String, dynamic>> attendance;
  String status; // Add this field

  StudentModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.surName,
    required this.spid,
    required this.phoneNumber,
    required this.email,
    required this.stream,
    required this.semester,
    required this.division,
    required this.profileImageUrl,
    required this.attendance,
    this.status = '', // Initialize with an empty string
  });

  factory StudentModel.fromMap(Map<dynamic, dynamic> map) {
    return StudentModel(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      surName: map['surName'] ?? '',
      spid: map['spid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      stream: map['stream'] ?? '',
      semester: map['semester'] ?? '',
      division: map['division'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      attendance: map['attendance'] != null
          ? List<Map<String, dynamic>>.from(map['attendance'])
          : [],
      status: map['status'] ?? '', // Add this line
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'surName': surName,
      'spid': spid,
      'phoneNumber': phoneNumber,
      'email': email,
      'stream': stream,
      'semester': semester,
      'division': division,
      'profileImageUrl': profileImageUrl,
      'attendance': attendance,
      'status': status, // Add this line
    };
  }
}
