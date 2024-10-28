import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skypi/screens/upload_project_screen.dart';
import 'package:skypi/screens/user_profile_screen.dart';
import 'notification_screen.dart';
import 'task_message_screen.dart';
import 'package:intl/intl.dart';

const String categoryName = 'Sample Category';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreenContent(),
    UploadProjectScreen(),
    Container(),
    PostsScreen(),
    UserProfileScreen(
      category: categoryName, // Pass categoryName here
      onProgressUpdated: (progress) {
        // Handle progress update if needed
      },
    ),
  ];

  void onTabTapped(int index) {
    if (index == 2) {
      Navigator.pushNamed(context, '/task');
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: onTabTapped,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.black,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.upload_outlined), label: 'Upload'),
            BottomNavigationBarItem(icon: Icon(null), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.join_inner), label: 'Posts'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/task');
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.task_alt_outlined, color: Colors.white, size: 32),
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  String? username = '';
  int todayTaskCount = 0;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsername();
    countTodayTasks();
  }

  void fetchUsername() async {
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        username = userDoc.data()!['username'];
      });
    }
  }

  void countTodayTasks() async {
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    var todayTasks = await FirebaseFirestore.instance
        .collection('daily_tasks')
        .where('createdDate', isGreaterThanOrEqualTo: currentDate)
        .where('createdDate', isLessThan: "$currentDate 23:59")
        .get();
    setState(() {
      todayTaskCount = todayTasks.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Welcome ${username ?? 'User'}..!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 0),
              const Text(
                'Transforming Minds, Enhancing Skills..! ',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    currentDate,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 180,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('daily_tasks')
                      .where('createdDate', isGreaterThanOrEqualTo: currentDate)
                      .where('createdDate', isLessThan: "$currentDate 23:59")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var tasks = snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return TaskCard(
                        title: data['title'] ?? 'No Title',
                        createdDate: data['createdDate'] ?? 'N/A',
                        description: data['description'] ?? '',
                        progress: (data['progress'] ?? 0.0).toDouble(),
                        teamMembers: List<String>.from(data['teamMembers'] ?? []),
                        downloads: data['downloads'] ?? 0,
                        category: data['category'] ?? 'No Category',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskMessageScreen(taskTitle: data['category']),
                            ),
                          );
                        },
                      );
                    }).toList();

                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: tasks,
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Tasks',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('daily_tasks').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var tasks = snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return TaskCard(
                      title: data['title'] ?? 'No Title',
                      createdDate: data['createdDate'] ?? 'N/A',
                      description: data['description'] ?? '',
                      progress: (data['progress'] ?? 0.0).toDouble(),
                      teamMembers: List<String>.from(data['teamMembers'] ?? []),
                      downloads: data['downloads'] ?? 0,
                      category: data['category'] ?? 'No Category',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskMessageScreen(taskTitle: data['category']),
                          ),
                        );
                      },
                    );
                  }).toList();

                  return ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: tasks,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String createdDate;
  final String description;
  final double progress;
  final List<String> teamMembers;
  final int downloads;
  final String category;
  final VoidCallback onTap;

  TaskCard({
    required this.title,
    required this.createdDate,
    required this.description,
    required this.progress,
    required this.teamMembers,
    required this.downloads,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.apps, color: Colors.green),
                ),
                const Spacer(),
                Text(
                  category,
                  style: TextStyle(fontSize: 18, color: Colors.green),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 3),
            Text(
              createdDate,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ...teamMembers.map((image) {
                  return Container(
                    margin: EdgeInsets.only(right: 8),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Downloads: $downloads',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Spacer(),
                Container(
                  child: Row(
                    children: [
                      Text('${(progress * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 14, color: Colors.green)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
