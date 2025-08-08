import 'package:flutter/material.dart';
import 'participant_list.dart';

enum AttendanceStatus { present, absent, unmarked }

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


enum EventStatus { ongoing, past, upcoming }

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


class EventPageHome extends StatelessWidget {
  EventPageHome({Key? key}) : super(key: key);

  final sampleEvent = Event(
    name: 'Hackathon',
    venue: 'Amrita Auditorium',
    startTime: DateTime.now(),
    endTime: DateTime.now().add(const Duration(hours: 2)),
    status: EventStatus.ongoing,
    participants: [
      Participant(name: 'Harish', rollNumber: 'CSE23517', status: AttendanceStatus.unmarked),
      Participant(name: 'Harinie', rollNumber: 'CSE23516', status: AttendanceStatus.present),
      Participant(name: 'Kanishthika', rollNumber: 'CSE23520', status: AttendanceStatus.absent),
      Participant(name: 'Anuj', rollNumber: 'CSE23507', status: AttendanceStatus.absent),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event Home")),
      body: Center(
        child: ElevatedButton(
          child: const Text('View Participants'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ParticipantListScreen(event: sampleEvent),
              ),
            );
          },
        ),
      ),
    );
  }
}