import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sascma/core/utils/colors.dart';

class AdminGalleryScreen extends StatefulWidget {
  @override
  _AdminGalleryScreenState createState() => _AdminGalleryScreenState();
}

class _AdminGalleryScreenState extends State<AdminGalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('gallery');
  bool _isUploading = false;
  List<String> _selectedImages = [];

  // Upload Image to Firebase
  Future<void> _uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      File file = File(image.path);
      List<int> imageBytes = await file.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      DatabaseReference ref = _dbRef.push();

      await ref.set({
        'image': base64Image,
        'timestamp': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      print('Upload failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Delete Selected Images
  Future<void> _deleteSelectedImages() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No images selected')),
      );
      return;
    }

    bool confirmDelete = await _showConfirmationDialog();
    if (!confirmDelete) return;

    try {
      for (String key in _selectedImages) {
        await _dbRef.child(key).remove();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected images deleted successfully')),
      );

      setState(() {
        _selectedImages.clear();
      });
    } catch (e) {
      print('Delete failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed')),
      );
    }
  }

  // Show Confirmation Dialog
  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text(
                'Are you sure you want to delete ${_selectedImages.length} selected images?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.appBackGroundColor),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Gallery',
          style: TextStyle(color: Colors.white), // Text color set to white
        ),
        backgroundColor: AppColor.primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: _selectedImages.isNotEmpty
                ? _deleteSelectedImages
                : null, // Disable button if no selection
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primaryColor,
        onPressed: _uploadImage,
        child: Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: Column(
        children: [
          if (_isUploading) ...[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CircularProgressIndicator(
                color: AppColor.primaryColor,
              ),
            ),
          ],
          Expanded(
            child: StreamBuilder(
              stream: _dbRef.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data?.snapshot.value == null) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor, // Loader color updated
                    ),
                  );
                }

                Map<dynamic, dynamic> images =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                List<MapEntry<dynamic, dynamic>> imageList =
                    images.entries.toList();

                return GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: imageList.length,
                  itemBuilder: (context, index) {
                    String key = imageList[index].key;
                    String base64Image = imageList[index].value['image'];

                    bool isSelected = _selectedImages.contains(key);

                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          if (isSelected) {
                            _selectedImages.remove(key);
                          } else {
                            _selectedImages.add(key);
                          }
                        });
                      },
                      child: Stack(
                        children: [
                          // Image Display with Shadow & Border
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColor.primaryColor
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(3, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                base64Decode(base64Image),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),

                          // Checkmark for Selected Images
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(
                                Icons.check_circle,
                                color: AppColor.primaryColor,
                                size: 30,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
