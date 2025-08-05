import 'participant.dart'; // Add this import at the top

class Event {
  final String name;
  final String venue;
  final DateTime startTime;
  final DateTime endTime;
  final EventStatus status;
  final List<Participant> participants;

  Event({
    required this.name,
    required this.venue,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.participants,
  });
}

enum EventStatus { ongoing, past, upcoming }
