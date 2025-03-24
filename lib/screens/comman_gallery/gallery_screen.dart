import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('gallery');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gallery')),
      body: StreamBuilder(
        stream: _dbRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return Center(child: CircularProgressIndicator());
          }

          Map<dynamic, dynamic> images =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          List<String> imageList =
              images.values.map((data) => data['image'] as String).toList();

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: imageList.length,
            itemBuilder: (context, index) {
              String base64Image = imageList[index];
              return Image.memory(
                base64Decode(base64Image),
                fit: BoxFit.cover,
              );
            },
          );
        },
      ),
    );
  }
}
