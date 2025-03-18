class FeePayment {
  String id;
  String studentId;
  String studentName; // Add this field
  String amount;
  String status; // Paid or Unpaid
  String paymentId; // Add this field

  FeePayment({
    required this.id,
    required this.studentId,
    this.studentName = '', // Initialize with an empty string
    required this.amount,
    required this.status,
    this.paymentId = '', // Initialize with an empty string
  });

  factory FeePayment.fromMap(Map<dynamic, dynamic> map) {
    return FeePayment(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '', // Add this line
      amount: map['amount'] ?? '',
      status: map['status'] ?? '',
      paymentId: map['paymentId'] ?? '', // Add this line
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName, // Add this line
      'amount': amount,
      'status': status,
      'paymentId': paymentId, // Add this line
    };
  }
}
