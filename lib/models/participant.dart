class Participant {
  final String name;
  final String rollNumber;
  final AttendanceStatus status;

  Participant({
    required this.name,
    required this.rollNumber,
    required this.status,
  });
}

enum AttendanceStatus { present, absent, unmarked }
