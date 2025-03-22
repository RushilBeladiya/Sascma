import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/colors.dart';

class SetPaymentAmountScreen extends StatefulWidget {
  @override
  _SetPaymentAmountScreenState createState() => _SetPaymentAmountScreenState();
}

class _SetPaymentAmountScreenState extends State<SetPaymentAmountScreen> {
  String? selectedStream;
  String? selectedSemester;
  final TextEditingController _amountController = TextEditingController();

  final List<String> streams = ['BCA', 'BCOM', 'BBA'];
  final List<String> semesters =
  List.generate(8, (index) => 'Semester ${index + 1}');

  final DatabaseReference _databaseRef =
  FirebaseDatabase.instance.ref().child('payments');

  Map<String, dynamic> paymentData = {};
  bool isSettingAmount = false;

  @override
  void initState() {
    super.initState();
    _fetchRealTimeData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _fetchRealTimeData() {
    _databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          paymentData = Map<String, dynamic>.from(data);
        });
      } else {
        setState(() {
          paymentData = {};
        });
      }
    });
  }

  Future<void> _savePayment() async {
    if (selectedStream != null &&
        selectedSemester != null &&
        _amountController.text.isNotEmpty) {
      setState(() => isSettingAmount = true);

      final newPayment = {
        "amount": _amountController.text,
        "timestamp": DateTime.now().toIso8601String(),
      };

      try {
        await _databaseRef
            .child(selectedStream!)
            .child('semesters')
            .child(selectedSemester!)
            .set(newPayment);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment data saved successfully!')),
        );

        setState(() {
          selectedStream = null;
          selectedSemester = null;
          _amountController.clear();
          isSettingAmount = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save data: $e')),
        );
        setState(() {
          isSettingAmount = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  Future<void> _deletePayment(String stream, String semester) async {
    try {
      await _databaseRef
          .child(stream)
      // .child('semesters')
          .child(semester)
          .remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment data deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Collection',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColor.primaryColor,
        elevation: 3,
      ),
      body: Container(
        color: AppColor.appBackGroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Stream Dropdown
              _buildDropdown(
                label: 'Select Stream',
                value: selectedStream,
                items: streams,
                onChanged: (value) => setState(() => selectedStream = value),
              ),
              const SizedBox(height: 15),

              /// Semester Dropdown
              _buildDropdown(
                label: 'Select Semester',
                value: selectedSemester,
                items: semesters,
                onChanged: (value) => setState(() => selectedSemester = value),
              ),
              const SizedBox(height: 15),

              /// Amount TextField
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Enter Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              /// Save Button
              ElevatedButton(
                onPressed: _savePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isSettingAmount
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Set Amount',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              /// Display payment data
              Expanded(
                child: paymentData.isEmpty
                    ? const Center(
                  child: Text('No Payment Data Available'),
                )
                    : ListView.builder(
                  itemCount: paymentData.length,
                  itemBuilder: (context, index) {
                    final stream = paymentData.keys.elementAt(index);
                    final semesters = paymentData[stream]['semesters']
                    as Map<dynamic, dynamic>?;

                    if (semesters == null) {
                      return const SizedBox
                          .shrink(); // Skip if semesters is null
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          'Stream: $stream',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        children: semesters.entries.map((entry) {
                          return ListTile(
                            title: Text(
                              'Semester: ${entry.key}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Amount: ₹${entry.value['amount']}',
                                  style: const TextStyle(
                                      color: Colors.green, fontSize: 16),
                                ),
                                Text(
                                  'Timestamp: ${entry.value['timestamp']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () => _deletePayment(
                                  stream, entry.key.toString()),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}