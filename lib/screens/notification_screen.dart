import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for fetching data
import 'ProjectPost_Screen.dart';
import 'project_details_screen.dart';
import 'package:intl/intl.dart'; // For formatting dates

class PostsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Projects',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('projects').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No Projects Available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var project = snapshot.data!.docs[index];
              var title = project['title']?.toString() ?? 'No Title';
              var companyName = project['companyName']?.toString() ?? 'No Company';
              var workType = project['workType']?.toString() ?? 'Unknown';
              var duration = project['duration']?.toString() ?? 'No Duration';
              var timeCommitment = project['timeCommitment'];

              // Handle time commitment
              if (timeCommitment is int || timeCommitment is double) {
                timeCommitment = '${timeCommitment.toString()} hrs/week';
              } else if (timeCommitment is String) {
                timeCommitment = '$timeCommitment hrs/week';
              } else {
                timeCommitment = 'No Commitment';
              }

              // Handle createdAt
              var createdAt = project['createdAt'];
              if (createdAt is Timestamp) {
                createdAt = DateFormat('dd-MM-yyyy').format(createdAt.toDate());
              } else if (createdAt is int) {
                createdAt = DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(createdAt));
              } else if (createdAt is String) {
                createdAt = createdAt; // Assuming it's a valid date string.
              } else {
                createdAt = 'Unknown';
              }

              var isHiring = project['isHiring'];
              if (isHiring is String) {
                isHiring = (isHiring.toLowerCase() == 'true');
              } else if (isHiring is int) {
                isHiring = (isHiring == 1);
              } else {
                isHiring = false;
              }

              // Fetching additional fields
              var city = project['city']?.toString() ?? 'No City';
              var description = project['description']?.toString() ?? 'No Description';
              var email = project['email']?.toString() ?? 'No Email'; // Fetch email
              var phoneNumber = project['phoneNumber']?.toString() ?? 'No Phone Number'; // Fetch phone number
              var experienceLevel = project['experienceLevel']?.toString() ?? 'No Experience Level';
              var roles = project['roles'] ?? 'No Roles';
              var skills = project['skills'] ?? []; // Expecting skills to be a list

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.trending_up, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(
                            'Actively Hiring',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        companyName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.home_work_outlined, size: 20, color: Colors.orange),
                          SizedBox(width: 4),
                          Text(workType, style: TextStyle(fontSize: 16, color: Colors.black87)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 20, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(timeCommitment, style: TextStyle(fontSize: 16)),
                          SizedBox(width: 20),
                          Icon(Icons.calendar_today, size: 22, color: Colors.green),
                          SizedBox(width: 4),
                          Text(duration, style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 20, color: Colors.blue),
                              SizedBox(width: 4),
                              Text('Posted on $createdAt',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                            ],
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectDetailScreen(
                                    title: title,
                                    companyName: companyName,
                                    duration: duration,         // Pass duration
                                    timeCommitment: timeCommitment,
                                    workType: workType,
                                    roles: List<String>.from(project['roles'] ?? []), // Pass roles as a list
                                    city: city, // Pass city here
                                    experienceLevel: experienceLevel,
                                    description: description, // Pass the description
                                    postedOn: createdAt,  // Pass posted on date here
                                    skills: List<String>.from(skills), // Pass skills as a list
                                    email: email, // Pass email to the detail screen
                                    phoneNumber: phoneNumber, // Pass phone number to the detail screen
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Are you ready to team up?'),
                actions: <Widget>[
                  TextButton(
                    child: Text('No', ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectPostScreen(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Icon(
          Icons.edit,
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
