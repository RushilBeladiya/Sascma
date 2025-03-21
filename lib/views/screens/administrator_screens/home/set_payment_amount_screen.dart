import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SetPaymentAmountScreen extends StatefulWidget {
  @override
  _SetPaymentAmountScreenState createState() => _SetPaymentAmountScreenState();
}

class _SetPaymentAmountScreenState extends State<SetPaymentAmountScreen> {
  final TextEditingController amountController = TextEditingController();
  late DatabaseReference _streamsRef;
  String _selectedStream = 'BCA';
  String _selectedSemester = 'Semester 1';
  Map<String, dynamic> _amounts = {};

  @override
  void initState() {
    super.initState();
    _streamsRef = FirebaseDatabase.instance.ref().child('streams');
    _fetchAmounts();
  }

  /// ✅ Fetch Data from Firebase
  Future<void> _fetchAmounts() async {
    try {
      DatabaseEvent event = await _streamsRef.once();

      if (event.snapshot.value != null) {
        Map<String, dynamic> tempData = Map<String, dynamic>.from(
          event.snapshot.value as Map<dynamic, dynamic>,
        );

        setState(() {
          _amounts = tempData.map((stream, semesters) {
            return MapEntry(
              stream,
              Map<String, dynamic>.from(semesters as Map<dynamic, dynamic>),
            );
          });
        });
      }
    } catch (error) {
      print("Error fetching amounts: $error");
      Get.snackbar('Error', 'Failed to fetch amounts');
    }
  }

  /// ✅ Set or Update Amount
  Future<void> _setAmount() async {
    final amount = int.tryParse(amountController.text.trim()) ?? 0;

    if (amount > 0) {
      await _streamsRef.child(_selectedStream).child(_selectedSemester).set({
        'amount': amount,
      });

      Get.snackbar(
        'Success',
        'Amount updated successfully for $_selectedStream - $_selectedSemester',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      _fetchAmounts(); // Refresh the amounts
    } else {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Payment Amount'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// ✅ Stream Dropdown
            DropdownButtonFormField<String>(
              value: _selectedStream,
              items: ['BCA', 'B.COM', 'BBA'].map((String stream) {
                return DropdownMenuItem<String>(
                  value: stream,
                  child: Text(stream),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedStream = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Stream',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            /// ✅ Semester Dropdown
            DropdownButtonFormField<String>(
              value: _selectedSemester,
              items: List.generate(8, (index) => 'Semester ${index + 1}')
                  .map((String semester) {
                return DropdownMenuItem<String>(
                  value: semester,
                  child: Text(semester),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedSemester = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Semester',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            /// ✅ Amount Text Field
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Enter Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),

            /// ✅ Set Amount Button
            ElevatedButton(
              onPressed: _setAmount,
              child: const Text('Set Amount'),
            ),
            const SizedBox(height: 16.0),

            /// ✅ Display Amounts in Expandable List
            Expanded(
              child: ListView.builder(
                itemCount: _amounts.length,
                itemBuilder: (context, index) {
                  String stream = _amounts.keys.elementAt(index);
                  Map<String, dynamic> semesters = _amounts[stream];

                  return ExpansionTile(
                    title: Text(
                      stream,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: semesters.keys.map<Widget>((semester) {
                      int amount = semesters[semester]['amount'] ?? 0;

                      return ListTile(
                        title: Text('$semester: ₹$amount'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            setState(() {
                              _selectedStream = stream;
                              _selectedSemester = semester;
                              amountController.text = amount.toString();
                            });
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
