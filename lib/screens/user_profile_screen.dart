import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/task.dart' as custom_task; // Aliasing the custom Task model
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String category;
  final Function(double) onProgressUpdated;

  const UserProfileScreen({
    required this.category,
    required this.onProgressUpdated,
    Key? key,
  }) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  List<custom_task.Task> completedTasks = [];
  double skillAccuracy = 0.0; // Skill accuracy value
  String? profileImageUrl;
  bool isLoading = true;  // Track loading state

  @override
  void initState() {
    super.initState();
    fetchProfileImage(); // Fetch profile picture
    fetchUserData();      // Fetch user data (including tasks) on init
  }

  // Fetch tasks from Firestore collection 'completed_task'
  Future<void> fetchCompletedTasks(String email) async {
    try {
      QuerySnapshot completedTaskSnapshot = await FirebaseFirestore.instance
          .collection('completed_task')
          .where('user_name', isEqualTo: email)
          .get();

      if (completedTaskSnapshot.docs.isNotEmpty) {
        List<custom_task.Task> fetchedTasks = completedTaskSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Check the percentage field exists and handle conversion
          double percentage = 0.0;
          if (data['percentage'] != null) {
            if (data['percentage'] is num) {
              percentage = (data['percentage'] as num).toDouble();
            } else if (data['percentage'] is String) {
              // Handle percentage as string (e.g., '86.00%')
              String percentageStr = data['percentage'];
              percentageStr = percentageStr.replaceAll('%', '').trim();
              percentage = double.tryParse(percentageStr) ?? 0.0;
            } else {
              print('Error: percentage field is not a num or String');
            }
          } else {
            print('Warning: percentage field is missing in document ${doc.id}');
          }

          return custom_task.Task(
            taskName: data['task_name'] ?? 'Unnamed Task',
            category: data['category'] ?? 'Uncategorized',
            feedback: data['feedback'] ?? 'No feedback',
            percentage: percentage,
          );
        }).toList();

        setState(() {
          completedTasks = fetchedTasks;
          skillAccuracy = _calculateTotalPercentage(fetchedTasks); // Update skill accuracy
        });

        // Update the parent screen with the total progress
        widget.onProgressUpdated(skillAccuracy / 100);

        // Push skill accuracy, completed tasks, and username to Firestore
        await _saveSkillAccuracyToFirestore(email);
      } else {
        print('No completed tasks found for the user.');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching completed tasks: $e')),
      );
    }
  }

  // Function to save total skill accuracy, completed tasks, and username to Firestore
  Future<void> _saveSkillAccuracyToFirestore(String email) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDataSnapshot.exists) {
          var userData = userDataSnapshot.data() as Map<String, dynamic>;
          String username = userData['username'] ?? 'Username';

          await FirebaseFirestore.instance.collection('user_skill_accuracy').doc(user.uid).set({
            'username': username,
            'email': email,
            'completed_tasks': completedTasks.length,
            'skill_accuracy': '${skillAccuracy.toStringAsFixed(1)}%',
            'last_updated': FieldValue.serverTimestamp(),
          });

          print('User skill accuracy saved successfully!');
        }
      }
    } catch (e) {
      print('Error saving skill accuracy to Firestore: $e');
    }
  }

  // Fetch user profile picture from Firebase Storage
  Future<void> fetchProfileImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: 'skypi-8a884.appspot.com');
        Reference ref = storage.ref().child('users').child('${user.uid}/profile_picture.jpg');
        String downloadUrl = await ref.getDownloadURL();

        setState(() {
          profileImageUrl = downloadUrl;
        });
      }
    } catch (e) {
      print('Error fetching profile image: $e');
      setState(() {
        profileImageUrl = null; // Set to null if fetching fails
      });
    }
  }

  // Calculate the total percentage of all tasks
  double _calculateTotalPercentage(List<custom_task.Task> tasks) {
    if (tasks.isEmpty) return 0.0;

    double total = tasks.fold(0, (sum, task) => sum + task.percentage);
    return total / tasks.length;
  }

  // Build task card with category, task name, feedback, and percentage
  Widget _buildTaskCard(custom_task.Task task) {
    return Card(
      child: ListTile(
        title: Text(
          task.taskName, // Display the task name
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${task.category}'), // Display the task category
            Text('Feedback: ${task.feedback}'), // Display feedback
          ],
        ),
        trailing: CircularPercentIndicator(
          radius: 25.0,
          lineWidth: 5.0,
          percent: task.percentage / 100.0, // Use percentage
          center: Text(
            '${task.percentage}%',
            style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
          ),
          progressColor: Colors.green,
        ),
      ),
    );
  }

  // Fetch user data from Firestore and trigger task fetching
  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDataSnapshot.exists) {
          var userData = userDataSnapshot.data() as Map<String, dynamic>;
          String email = userData['email'] ?? '';

          // Fetch tasks after getting user data
          await fetchCompletedTasks(email);
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loading once data is fetched
      });
    }
  }

  // Fetch user data from Firestore for FutureBuilder
  Future<DocumentSnapshot> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
  }

  void _updateUserData() {
    setState(() {}); // Force rebuild to reflect profile updates
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Your Profile', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold, color: Colors.green)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.green),
            onPressed: () {
              User? currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(userId: currentUser.uid), // Pass userId here
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.green),
            onPressed: () {
              getUserData().then((snapshot) {
                var userData = snapshot.data() as Map<String, dynamic>;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      onProfileUpdated: _updateUserData, // Pass callback for updating UI
                    ),
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Display loading spinner
          : FutureBuilder<DocumentSnapshot>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No user data found.'));
          } else {
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            String username = userData['username'] ?? 'Username';
            String bio = userData['bio'] ?? 'Bio';
            String email = userData['email'] ?? 'No email provided';
            String location = userData['location'] ?? 'Location not available';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl!) // Display the fetched profile image
                            : AssetImage('assets/images/default_profile.png') as ImageProvider, // Default profile image
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bio,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            location,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: skillAccuracy / 100, // Skill accuracy value
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                              strokeWidth: 8,
                            ),
                            Center(
                              child: Text(
                                '${skillAccuracy.toStringAsFixed(1)}%', // Display skill accuracy
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Skill Accuracy',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Completed Tasks: ${completedTasks.length}',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: completedTasks.length,
                      itemBuilder: (context, index) {
                        custom_task.Task task = completedTasks[index];
                        return _buildTaskCard(task); // Build a task card
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
