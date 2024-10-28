import 'package:flutter/material.dart';
import 'package:skypi/screens/apply_project_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String title;
  final String companyName;
  final String duration;
  final String timeCommitment;
  final String workType;
  final String postedOn;
  final String description;
  final List<String> skills;
  final List<String> roles;
  final String city;
  final String experienceLevel;
  final String email; // New field for email
  final String phoneNumber; // New field for phone number

  ProjectDetailScreen({
    required this.title,
    required this.companyName,
    required this.duration,
    required this.timeCommitment,
    required this.workType,
    required this.postedOn,
    required this.description,
    required this.skills,
    required this.roles,
    required this.city,
    required this.experienceLevel,
    required this.email, // Accept email
    required this.phoneNumber, // Accept phone number
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Stack( // Use Stack to allow floating button over the content
          children: [
            SingleChildScrollView( // Make the entire screen scrollable
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Navigate back
                          },
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Project Details',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[200],
                                child: const Icon(Icons.work, size: 40, color: Colors.green),
                              ),
                              const SizedBox(height: 10),
                              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              Text(companyName, style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Chip(
                                    label: const Text('Fulltime',style: TextStyle(color: Colors.blue)),
                                    backgroundColor: Colors.grey[200],
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            JobInfoCard(
                              icon: Icons.location_city,
                              title: 'City',
                              subtitle: city,
                            ),
                            JobInfoCard(
                              icon: Icons.work,
                              title: 'Work Type',
                              subtitle: workType,
                            ),
                            JobInfoCard(
                              icon: Icons.person_outline,
                              title: 'Level',
                              subtitle: experienceLevel,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            JobInfoCard(
                              icon: Icons.timer,
                              title: 'Duration',
                              subtitle: duration,
                            ),
                            JobInfoCard(
                              icon: Icons.timer,
                              title: 'Posted On',
                              subtitle: postedOn,
                            ),
                            JobInfoCard(
                              icon: Icons.access_time,
                              title: 'Commitment',
                              subtitle: timeCommitment,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        DefaultTabController(
                          length: 4, // Updated to have 4 tabs
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TabBar(
                                indicatorColor: Colors.green,
                                labelColor: Colors.green,
                                unselectedLabelColor: Colors.black,
                                tabs: [
                                  Tab(text: 'Description'),
                                  Tab(text: 'Requirement'),
                                  Tab(text: 'Roles'),
                                  Tab(text: 'Contact Info'), // New Tab for Contact Info
                                ],
                              ),
                              SizedBox(
                                height: 250, // Adjust height if needed
                                child: TabBarView(
                                  children: [
                                    SingleChildScrollView( // Scrollable description tab
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Job Description:\n\n$description',
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Job Requirements:\n\n',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          ...skills.map((skill) => Text('- $skill')).toList(),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Job Roles:\n\n',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          ...roles.map((role) => Text('- $role')).toList(),
                                        ],
                                      ),
                                    ),
                                    Padding( // Contact Info Tab content
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Contact Information:',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 10),
                                          Text('Email: $email', // Display email
                                              style: const TextStyle(fontSize: 16)),
                                          const SizedBox(height: 5),
                                          Text('Phone: $phoneNumber', // Display phone number
                                              style: const TextStyle(fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80), // Add extra space for floating button at the bottom
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApplyProjectScreen(
                        receiverEmail: email, // Pass email to apply screen
                        receiverPhone: phoneNumber, // Pass phone number to apply screen
                        projectName: title,
                        skills: skills,
                        roles: roles,
                      ),
                    ),
                  );
                },
                backgroundColor: Colors.green,
                label: const Text('Apply Now', style: TextStyle(fontSize: 16,color: Colors.white)),
                icon: const Icon(Icons.send,color: Colors.white,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  JobInfoCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
