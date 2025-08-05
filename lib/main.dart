import 'package:flutter/material.dart';
import 'screens/participant_list.dart';
import 'models/event.dart';
import 'models/participant.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Event sampleOngoingEvent = Event(
      name: 'Hackathon',
      venue: 'Amrita Auditorium',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(Duration(hours: 2)),
      status: EventStatus.ongoing,
      participants: [
        Participant(name: 'Harish', rollNumber: 'CSE23517', status: AttendanceStatus.unmarked),
        Participant(name: 'Harinie', rollNumber: 'CSE23516', status: AttendanceStatus.present),
        Participant(name: 'Kanishthika', rollNumber: 'CSE23520', status: AttendanceStatus.absent),
      ],
    );

    return MaterialApp(
      title: 'Attendex',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ParticipantListScreen(event: sampleOngoingEvent),
    );
  }
}
