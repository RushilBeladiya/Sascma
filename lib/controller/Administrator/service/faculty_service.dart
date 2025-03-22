import 'package:firebase_database/firebase_database.dart';
import 'package:sascma/models/faculty_model.dart';

class FacultyService {
  static Future<List<FacultyModel>> getFacultyList() async {
    List<FacultyModel> facultyList = [];

    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref("faculty");

      DatabaseEvent event = await ref.once();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          facultyList
              .add(FacultyModel.fromJson(Map<String, dynamic>.from(value)));
        });
      }
    } catch (e) {
      print("Error fetching faculty list: $e");
    }

    return facultyList;
  }
}
