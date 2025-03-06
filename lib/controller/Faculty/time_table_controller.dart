import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/time_table_model.dart';

class TimetableController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  var timetables = <Timetable>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTimetables();
  }
  Future<void> fetchTimetables() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await firestore.collection('timetables').get();
        timetables.assignAll(snapshot.docs.map((doc) {
          return Timetable(
            id: doc.id,
            subject: doc['subject'],
            day: doc['day'],
            time: doc['time'],
            instructor: doc['instructor'],
          );
        }).toList());
      } catch (e) {
        print('Error fetching timetables: $e');
      }
    } else {
      // Handle user not authenticated case
      print('User is not authenticated');
    }
  }


  Future<void> addTimetable(Timetable timetable) async {
    try {
      DocumentReference docRef = await firestore.collection('timetables').add({
        'subject': timetable.subject,
        'day': timetable.day,
        'time': timetable.time,
        'instructor': timetable.instructor,
      });
      timetable.id = docRef.id; // Get the document ID
      timetables.add(timetable);
    } catch (e) {
      print('Error adding timetable: $e');
    }
  }

  Future<void> updateTimetable(Timetable timetable) async {
    try {
      await firestore.collection('timetables').doc(timetable.id).update({
        'subject': timetable.subject,
        'day': timetable.day,
        'time': timetable.time,
        'instructor': timetable.instructor,
      });
      fetchTimetables(); // Refresh timetable list
    } catch (e) {
      print('Error updating timetable: $e');
    }
  }

  Future<void> removeTimetable(String id) async {
    try {
      await firestore.collection('timetables').doc(id).delete();
      timetables.removeWhere((timetable) => timetable.id == id);
    } catch (e) {
      print('Error removing timetable: $e');
    }
  }
}
