import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffLandingScreen extends StatefulWidget {
  @override
  _StaffLandingScreenState createState() => _StaffLandingScreenState();
}

class _StaffLandingScreenState extends State<StaffLandingScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFF4ABFA8),
                    child: Text(
                      'Harish'[0], // Automatically takes the first letter
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harish',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'ACM Volunteer',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color(0xFFB0B0B0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF64D7BE), Color(0xFF4ABFA8)],
                    begin: Alignment.topLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  style: GoogleFonts.poppins(color: Color(0xFF757575)),
                  cursorColor: Color(0xFF757575),
                  decoration: InputDecoration(
                    hintText: 'Search for Events',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Color(0xFF757575)),
                  ),
                ),
              ),
              SizedBox(height: 23),

              // Tab bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTab('Ongoing', 0),
                  Text('|', style: TextStyle(color: Color(0xFFB0B0B0))),
                  _buildTab('Upcoming', 1),
                  Text('|', style: TextStyle(color: Color(0xFFB0B0B0))),
                  _buildTab('Past', 2),
                ],
              ),
              SizedBox(height: 20),

              // Event list
              Expanded(
                child: ListView(
                  children: [
                    _buildEventCard('Hackathon','DD/MM/YYYY', 'HH:MM:SS', true, false),
                    SizedBox(height: 12),
                    _buildEventCard('Workshop','DD/MM/YYYY', 'HH:MM:SS', false, true),
                    SizedBox(height: 12),
                    _buildEventCard('Award ceremony','DD/MM/YYYY', 'HH:MM:SS', false, true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF64D7BE), Color(0xFF4ABFA8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF4ABFA8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.home, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    bool isSelected = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve:Curves.bounceIn ,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [Color(0xFF64D7BE), Color(0xFF4ABFA8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 90,
              offset: Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Color(0xFF757575),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(String eventName,String date, String time, bool canScan, bool isLocked) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white70],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF4ABFA8), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Date : $date',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Event : $time',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF4ABFA8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF64D7BE), width: 1),
                  ),
                  child: Text(
                    'Get Participant List',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              if (canScan)
                Column(
                  children: [
                    Icon(Icons.qr_code_scanner, color: Colors.black, size: 30),
                    SizedBox(height: 4),

                  ],
                ),
              if (isLocked)
                Column(
                  children: [
                    Icon(Icons.lock, color: Colors.black, size: 30),
                    SizedBox(height: 4),


                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}