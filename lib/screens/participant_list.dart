import 'package:flutter/material.dart';
import '../models/participant.dart';
import '../models/event.dart';
import 'event_page_home.dart';




class ParticipantListScreen extends StatefulWidget {
  final Event event;

  const ParticipantListScreen({Key? key, required this.event}) : super(key: key);

  @override
  _ParticipantListScreenState createState() => _ParticipantListScreenState();
}

class _ParticipantListScreenState extends State<ParticipantListScreen> {
  TextEditingController searchController = TextEditingController();
  List<Participant> filteredParticipants = [];
  Map<String, bool> checkedStates = {};
  bool sortAscending = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    filteredParticipants = widget.event.participants;
    for (var p in widget.event.participants) {
      checkedStates[p.rollNumber] = false;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _filterParticipants(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        filteredParticipants = widget.event.participants;
      } else {
        filteredParticipants = widget.event.participants
            .where((participant) =>
        participant.name.toLowerCase().contains(query.toLowerCase()) ||
            participant.rollNumber.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _sortParticipants() {
    setState(() {
      filteredParticipants.sort((a, b) =>
      sortAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
      sortAscending = !sortAscending;
    });
  }

  Color _getBackgroundColor(String roll) {
    return checkedStates[roll] == true ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2);
  }

  Color _getBorderColor(String roll) {
    return checkedStates[roll] == true ? Colors.green : Colors.red;
  }

  void _resetSearch() {
    setState(() {
      searchController.clear();
      isSearching = false;
      filteredParticipants = widget.event.participants;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Staff: ParticipantList I'),
        backgroundColor: Colors.blue[100],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.event.name} (${widget.event.status.name})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Venue: ${widget.event.venue}'),
                      Text('Timing: ${_formatTime(widget.event.startTime)} - ${_formatTime(widget.event.endTime)}'),
                      Text('Status: ${widget.event.status.name}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _sortParticipants,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text('Sort (A-Z)'),
                    ),
                    if (isSearching)
                      ElevatedButton(
                        onPressed: _resetSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text('Back'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: _filterParticipants,
                    decoration: const InputDecoration(
                      hintText: 'Search For Participants by Name or Roll',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                if (filteredParticipants.isEmpty)
                  const Center(child: Text('No match found')),
                ...filteredParticipants.map((participant) {
                  final roll = participant.rollNumber;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(roll),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getBorderColor(roll),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: checkedStates[roll] ?? false,
                          onChanged: (bool? value) {
                            setState(() {
                              checkedStates[roll] = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${participant.name}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Roll Number: ${participant.rollNumber}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => EventNamePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Text('Home', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
