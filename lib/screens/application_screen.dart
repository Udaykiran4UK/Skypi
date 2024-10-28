import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:open_filex/open_filex.dart'; // For opening files
import 'package:intl/intl.dart'; // For formatting the date

class ApplicationScreen extends StatelessWidget {
  final String userEmail; // Receive email from SettingsScreen

  ApplicationScreen({required this.userEmail}); // Constructor

  // Method to format Firestore timestamp into a readable date string
  String formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('dd-MM-yyyy').format(date); // Formatting date to "dd-MM-yyyy"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications',style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold,
            color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Applications to: $userEmail', // Display the user's email
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              // Fetch applications where receiverEmail is equal to userEmail
              stream: FirebaseFirestore.instance
                  .collection('project_applications')
                  .where('receiverEmail', isEqualTo: userEmail)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No Applications Available',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                // Fetching data from Firestore
                final applications = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    var application = applications[index];
                    var fullName = application['fullName']?.toString() ?? 'No Name';
                    var email = application['email']?.toString() ?? 'No Email';
                    var projectName = application['projectName']?.toString() ?? 'No Project Name';
                    var selectedRole = application['selectedRole']?.toString() ?? 'No Role';
                    var selectedSkill = application['selectedSkill']?.toString() ?? 'No Skill';
                    var portfolio = application['portfolio']?.toString() ?? 'No Portfolio';
                    var cvUrl = application['cvUrl']?.toString() ?? 'No CV URL';
                    var createdAtTimestamp = application['createdAt'] as Timestamp?;
                    var createdAt = createdAtTimestamp != null
                        ? formatDate(createdAtTimestamp)
                        : 'No Date';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.email, color: Colors.green),
                                const SizedBox(width: 8),
                                Text('Email: $email'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.business, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text('Project: $projectName'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.person_outline, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text('Role: $selectedRole'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.wordpress_rounded, color: Colors.purple),
                                const SizedBox(width: 8),
                                Text('Skill: $selectedSkill'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.description, color: Colors.teal),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _openFile(cvUrl, context),
                                  child: Text(
                                    'Resume',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.av_timer_rounded, color: Colors.blueAccent),
                                const SizedBox(width: 8),
                                Text('Applied on: $createdAt'),
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
          ),
        ],
      ),
    );
  }

  Future<void> _openFile(String url, BuildContext context) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: 'skypi-8a884.appspot.com');
      Reference ref = storage.refFromURL(url);
      String fileName = ref.name;
      String extension = path.extension(fileName).toLowerCase();

      Directory? saveDir;

      if (Platform.isAndroid || Platform.isIOS) {
        saveDir = await getApplicationDocumentsDirectory();
      }

      if (saveDir != null) {
        String filePath = path.join(saveDir.path, fileName);
        File file = File(filePath);

        // Check if file already exists locally
        if (!await file.exists()) {
          await ref.writeToFile(file);
        }

        // Check file extension and handle accordingly
        if (['.pdf', '.jpg', '.jpeg', '.png'].contains(extension)) {
          // Open the file after downloading
          OpenFilex.open(filePath).then((result) {
            if (result.type != ResultType.done) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not open $fileName: ${result.message}')),
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unsupported file type: $fileName')),
          );
        }
      }
    } catch (e) {
      print('Error opening file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }
}
