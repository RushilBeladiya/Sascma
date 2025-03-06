class PdfDetail {
  final String id; // Add this line
  final String name;
  final String url;
  final String semester;
  final String subject;
  final String stream;

  PdfDetail({
    required this.id, // Add this line
    required this.name,
    required this.url,
    required this.semester,
    required this.subject,
    required this.stream,
  });
}
