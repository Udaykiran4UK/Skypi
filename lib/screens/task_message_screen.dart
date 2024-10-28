import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:open_filex/open_filex.dart'; // For opening files
import 'package:intl/intl.dart'; // For date formatting

class TaskMessageScreen extends StatefulWidget {
  final String taskTitle;

  TaskMessageScreen({required this.taskTitle});

  @override
  _TaskMessageScreenState createState() => _TaskMessageScreenState();
}

class _TaskMessageScreenState extends State<TaskMessageScreen> {
  List<Task> tasks = [];
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('daily_tasks')
          .where('category', isEqualTo: widget.taskTitle)
          .get();

      List<Task> fetchedTasks = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Task(
          title: data['title'] ?? 'N/A',
          createdDate: data['createdDate'] ?? 'N/A',
          description: data['description'] ?? '',
          fileUrl: data['fileUrl'] ?? '',
        );
      }).toList();

      setState(() {
        tasks = fetchedTasks;
      });
    } catch (e) {
      print('Error fetching tasks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tasks')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });

      fetchTasksByDate(pickedDate);
    }
  }

  Future<void> fetchTasksByDate(DateTime date) async {
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('daily_tasks')
          .where('category', isEqualTo: widget.taskTitle)
          .get();

      List<Task> filteredTasks = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String taskDate = data['createdDate'] ?? 'N/A';

        if (taskDate.startsWith(formattedDate)) {
          return Task(
            title: data['title'] ?? 'N/A',
            createdDate: taskDate,
            description: data['description'] ?? '',
            fileUrl: data['fileUrl'] ?? '',
          );
        }
        return null;
      }).whereType<Task>().toList();

      setState(() {
        tasks = filteredTasks;
      });
    } catch (e) {
      print('Error fetching tasks by date: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tasks by date')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.taskTitle, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month_rounded, color: Colors.green),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text('Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: tasks.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskCard(
                    title: task.title,
                    createdDate: task.createdDate,
                    description: task.description,
                    fileUrl: task.fileUrl,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String createdDate;
  final String description;
  final String fileUrl;

  const TaskCard({
    required this.title,
    required this.createdDate,
    required this.description,
    required this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.task_alt_outlined, color: Colors.green, size: 40),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      createdDate,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(description, style: TextStyle(fontSize: 14)),
            SizedBox(height: 10),
            if (fileUrl.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Open file:', style: TextStyle(color: Colors.black)),
                  IconButton(
                    icon: Icon(Icons.open_in_new, color: Colors.blue),
                    onPressed: () => _openFile(fileUrl, context),
                  ),
                ],
              ),
          ],
        ),
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

        // Open the file after downloading
        OpenFilex.open(filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opened $fileName')),
        );
      }
    } catch (e) {
      print('Error opening file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }
}

class Task {
  final String title;
  final String createdDate;
  final String description;
  final String fileUrl;

  Task({
    required this.title,
    required this.createdDate,
    required this.description,
    required this.fileUrl,
  });
}
